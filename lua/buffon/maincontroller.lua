-- luacheck: ignore unused self

local log = require("buffon.log")
local mainwindow = require("buffon.ui.mainwindow")
local helpwindow = require("buffon.ui.help")
local buffer = require("buffon.buffer")
local utils = require("buffon.utils")

local M = {}

--- Sets a keymap with the given parameters.
---@param lhs string The left-hand side of the keymap.
---@param rhs function | string The right-hand side of the keymap.
---@param help string The description of the keymap.
local set_keymap = function(lhs, rhs, help)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = "Buffon: " .. help })
end

---@class BuffonMainController
---@field config BuffonConfig
---@field main_window BuffonMainWindow
---@field help_window BuffonHelpWindow
---@field group integer
---@field page_controller BuffonPageController
---@field storage BuffonStorage
---@field index_buffer_active number | nil
---@field previous_used string | nil
---@field buffer_will_be_renamed string | nil
---@field active_buffer_by_page table<number>
---@field recently_closed BuffonRecentlyClosed
local MainController = {}

---@param cfg BuffonConfig
---@param page_controller BuffonPageController
function MainController:new(cfg, page_controller, stg)
  local o = {
    config = cfg,
    main_window = mainwindow.MainWindow:new(cfg, page_controller),
    help_window = helpwindow.HelpWindow:new(),
    group = vim.api.nvim_create_augroup("Buffon", { clear = true }),
    page_controller = page_controller,
    storage = stg,
    index_buffer_active = nil,
    previous_used = nil,
    buffer_will_be_renamed = nil,
    active_buffer_by_page = {},
    recently_closed = utils.RecentlyClosed:new(),
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

---@class BuffonAction
---@field shortcut? string
---@field vimevent? string
---@field help? string
---@field method? function
---@field method_post_refresh? function
---@field require_match? boolean

---@return table<BuffonAction>
function MainController:get_shortcuts()
  return {
    {
      shortcut = self.config.keybindings.toggle_buffon_window,
      help = "Show/hide buffer list",
      method = self.action_show_hide_buffon_window,
    },
    {
      shortcut = self.config.keybindings.goto_next_buffer,
      help = "Next buffer",
      method = self.action_goto_next,
    },
    {
      shortcut = self.config.keybindings.goto_previous_buffer,
      help = "Previous buffer",
      method = self.action_goto_previous,
    },
    {
      shortcut = self.config.keybindings.next_page,
      help = "Next page",
      method = self.action_next_page,
      method_post_refresh = self.action_select_buffer,
    },
    {
      shortcut = self.config.keybindings.previous_page,
      help = "Previous page",
      method = self.action_previous_page,
      method_post_refresh = self.action_select_buffer,
    },
    {
      shortcut = self.config.keybindings.move_to_next_page,
      help = "Buffer to next page",
      method = self.action_buffer_to_next_page,
    },
    {
      shortcut = self.config.keybindings.move_to_previous_page,
      help = "Buffer to previous page",
      method = self.action_buffer_to_previous_page,
    },
    {
      shortcut = self.config.keybindings.move_buffer_up,
      help = "Move buffer up",
      method = self.action_move_buffer_up,
    },
    {
      shortcut = self.config.keybindings.move_buffer_down,
      help = "Move buffer down",
      method = self.action_move_buffer_down,
    },
    {
      shortcut = self.config.keybindings.move_buffer_top,
      help = "Move buffer to top",
      method = self.action_move_buffer_top,
    },
    {
      shortcut = self.config.keybindings.move_buffer_bottom,
      help = "Move buffer to bottom",
      method = self.action_move_buffer_bottom,
    },
    {
      shortcut = self.config.keybindings.close_buffer,
      help = "Close buffer",
      method = self.action_close_buffer,
    },
    {
      shortcut = self.config.keybindings.close_buffers_above,
      help = "Close buffers above",
      method = self.action_close_buffers_above,
    },
    {
      shortcut = self.config.keybindings.close_buffers_below,
      help = "Close buffers below",
      method = self.action_close_buffers_below,
    },
    {
      shortcut = self.config.keybindings.close_all_buffers,
      help = "Close all",
      method = self.action_close_buffers_all,
    },
    {
      shortcut = self.config.keybindings.close_others,
      help = "Close others",
      method = self.action_close_buffers_other,
    },
    {
      shortcut = self.config.keybindings.switch_previous_used_buffer,
      help = "Last used buffer",
      method = self.action_switch_previous_used,
    },
    {
      shortcut = self.config.keybindings.reopen_recent_closed_buffer,
      help = "Restore closed buffer",
      method = self.action_reopen_recent_closed,
    },
  }
end

---@return table<BuffonAction>
function MainController:get_events()
  return {
    {
      vimevent = "BufAdd",
      method = self.action_add_buffer,
      require_match = true,
    },
    {
      vimevent = "BufDelete",
      method = self.action_remove_buffer,
      require_match = true,
    },
    {
      vimevent = "VimEnter",
      method = self.action_buffon_window_needs_open,
    },
    {
      vimevent = "BufEnter",
      require_match = true,
      method = self.action_check_activate_page,
    },
    {
      vimevent = "BufNew",
      require_match = true,
      method = self.action_check_activate_page,
    },
    {
      vimevent = "VimResized",
    },
    {
      vimevent = "ExitPre",
      method = self.action_before_exit,
    },
    {
      vimevent = "BufLeave",
      method = self.action_before_buf_leave,
      require_match = true,
    },
    {
      vimevent = "BufModifiedSet",
    },
    {
      vimevent = "BufFilePre",
      method = self.action_buffer_will_rename,
    },
    {
      vimevent = "BufFilePost",
      method = self.action_rename_buffer,
    },
  }
end

function MainController:register_shortcuts()
  for _, action in ipairs(self:get_shortcuts()) do
    set_keymap(action.shortcut, function()
      self:dispatch(action)
    end, action.help)
  end

  for idx = 1, #self.config.keybindings.buffer_mapping.mapping_chars do
    local char = self.config.keybindings.buffer_mapping.mapping_chars:sub(idx, idx)
    set_keymap(";" .. char, function()
      self:action_open_buffer_by_index(idx)
    end, "Goto to buffer " .. idx)
  end

  set_keymap(self.config.keybindings.show_help, function()
    self:action_show_help()
  end, "Show the help window")

  log.debug("shortcuts registered")
end

function MainController:register_events()
  for _, action in ipairs(self:get_events()) do
    vim.api.nvim_create_autocmd(action.vimevent, {
      group = self.group,
      callback = function(buf)
        self:dispatch(action, buf)
      end,
    })
  end
  log.debug("events registered")
end

---@param action BuffonAction
function MainController:dispatch(action, buf)
  if action.require_match and buf and buf.event and buf.match == "" then
    return
  end

  if buf and buf.event and buf.match ~= "" then
    log.debug(buf.event, ":", buf.match)
  end

  if action.method then
    action.method(self, buf)
  end

  self.main_window:refresh()

  if action.method_post_refresh then
    action.method_post_refresh(self, buf)
  end
end

--------------------------------------------------------------------------------------------
--- ↓ Actions starts here ↓
--------------------------------------------------------------------------------------------

function MainController:action_show_hide_buffon_window()
  self.main_window:toggle()
end

function MainController:action_add_buffer(buf)
  local existent_buf, num_page = self.page_controller:get_buffer_and_page(buf.match)
  log.debug("adding ", buf.match, ", this buffer is in page:", num_page)

  -- if num_page is not nil, it means the buffer already exists. in that case, it should be activated
  if num_page and existent_buf then
    self.page_controller:set_page(num_page)
    existent_buf.id = buf.buf
  else
    self.page_controller:add_buffer_to_active_page(buffer.Buffer:new(buf.buf, buf.match), self.index_buffer_active)
  end
end

function MainController:action_buffon_window_needs_open()
  local should_open = self.config.open.by_default
  local buffer_ignored = vim.tbl_contains(self.config.open.ignore_ft, vim.bo.filetype)

  if should_open and not buffer_ignored then
    self.main_window:open()
  end
end

function MainController:action_before_exit(buf)
  self.page_controller:get_active_page().bufferslist:update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
  self.storage:save(self.page_controller:get_data())
end

function MainController:action_before_buf_leave(buf)
  self.page_controller:get_active_page().bufferslist:update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
  self.previous_used = buf.match
  self.index_buffer_active = self.page_controller:get_active_page().bufferslist:get_index(buf.match)
end

function MainController:action_remove_buffer(buf)
  self.page_controller:remove_buffer_from_active_page(buf.match)
end

---@param index number
function MainController:action_open_buffer_by_index(index)
  local buf = self.page_controller:get_active_page().bufferslist.buffers[index]
  if buf then
    self:action_open_or_activate_buffer(buf)
  end
end

---@param buf BuffonBuffer
function MainController:action_open_or_activate_buffer(buf)
  log.debug("open", buf.name, "with id", buf.id)
  if buf.id then
    vim.api.nvim_set_current_buf(buf.id)
  else
    vim.api.nvim_command("edit " .. buf.name)
    buf.id = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_cursor(0, buf.cursor)
    vim.cmd("normal! zz")
  end
end

function MainController:action_goto_next()
  local next_buffer = self.page_controller:get_active_page().bufferslist:get_next_buffer(utils.get_buffer_name())
  if next_buffer then
    self:action_open_or_activate_buffer(next_buffer)
  end
end

function MainController:action_goto_previous()
  local previous_buffer =
    self.page_controller:get_active_page().bufferslist:get_previous_buffer(utils.get_buffer_name())
  if previous_buffer then
    self:action_open_or_activate_buffer(previous_buffer)
  end
end

function MainController:action_next_page()
  local idx = self.page_controller:get_active_page().bufferslist:get_index(utils.get_buffer_name())
  self.active_buffer_by_page[self.page_controller.active] = idx
  self.page_controller:next_page()
end

function MainController:action_previous_page()
  local idx = self.page_controller:get_active_page().bufferslist:get_index(utils.get_buffer_name())
  self.active_buffer_by_page[self.page_controller.active] = idx
  self.page_controller:previous_page()
end

function MainController:action_move_buffer_up()
  self.page_controller:get_active_page().bufferslist:move_up(utils.get_buffer_name())
end

function MainController:action_move_buffer_down()
  self.page_controller:get_active_page().bufferslist:move_down(utils.get_buffer_name())
end

function MainController:action_move_buffer_top()
  self.page_controller:get_active_page().bufferslist:move_top(utils.get_buffer_name())
end

function MainController:action_move_buffer_bottom()
  self.page_controller:get_active_page().bufferslist:move_bottom(utils.get_buffer_name())
end

---@param buffers_to_close table<BuffonBuffer>
function MainController:close_buffers(buffers_to_close)
  for _, buf in ipairs(buffers_to_close) do
    if buf.id then
      vim.api.nvim_buf_delete(buf.id, { force = false })
    else
      self.page_controller:get_active_page().bufferslist:remove(buf.name)
    end
    self.recently_closed:add(buf.name)
  end
end

function MainController:action_close_buffer()
  local buf = self.page_controller:get_active_page().bufferslist:get_by_name(utils.get_buffer_name())
  self:close_buffers({ buf })
end

function MainController:action_close_buffers_above()
  local buffers = self.page_controller:get_active_page().bufferslist:get_buffers_above(utils.get_buffer_name())
  self:close_buffers(buffers)
end

function MainController:action_close_buffers_below()
  local buffers = self.page_controller:get_active_page().bufferslist:get_buffers_below(utils.get_buffer_name())
  self:close_buffers(buffers)
end

function MainController:action_close_buffers_all()
  local buffers = self.page_controller:get_active_page():get_buffers()
  self:close_buffers(buffers)
end

function MainController:action_close_buffers_other()
  local buffers = self.page_controller:get_active_page().bufferslist:get_other_buffers(utils.get_buffer_name())
  self:close_buffers(buffers)
end

function MainController:action_buffer_to_next_page()
  self.page_controller:move_to_next_page(utils.get_buffer_name())
end

function MainController:action_buffer_to_previous_page()
  self.page_controller:move_to_previous_page(utils.get_buffer_name())
end

function MainController:action_switch_previous_used()
  if self.previous_used then
    local buf, num_page = self.page_controller:get_buffer_and_page(self.previous_used)
    if buf and num_page then
      self.page_controller:set_page(num_page)
      self:action_open_or_activate_buffer(buf)
    end
  end
end

function MainController:action_buffer_will_rename(buf)
  self.buffer_will_be_renamed = buf.match
end

function MainController:action_rename_buffer(buf)
  assert(self.buffer_will_be_renamed, "new buffer name is required")
  for _, page in ipairs(self.page_controller.pages) do
    page.bufferslist:rename(self.buffer_will_be_renamed, buf.match)
  end
end

function MainController:action_select_buffer()
  local idx = self.active_buffer_by_page[self.page_controller.active]
  local buf = self.page_controller:get_active_page().bufferslist.buffers[idx]
  if buf then
    self:action_open_or_activate_buffer(buf)
  end
end

function MainController:action_reopen_recent_closed()
  local filename = self.recently_closed:get_last()
  if filename then
    vim.api.nvim_command("edit " .. filename)
  end
end

function MainController:action_show_help()
  self.help_window:toggle(self:get_shortcuts())
end

--- When a buffer is activated, it is necessary to check if the user has
--- the buffer's page activated; if not, it needs to be activated.
function MainController:action_check_activate_page(buf)
  local _, num_page = self.page_controller:get_buffer_and_page(buf.match)
  log.debug("bufer", buf.match, "exists in page", num_page, "and active page is", self.page_controller.active)
  if num_page and num_page ~= self.page_controller.active then
    self.page_controller:set_page(num_page)
  end
end

M.MainController = MainController

return M
