-- luacheck: ignore unused self

local log = require("buffon.log")
local mainwindow = require("buffon.ui.mainwindow")
local helpwindow = require("buffon.ui.help")
local buffer = require("buffon.buffer")
local utils = require("buffon.utils")

local M = {}

---@type table<string, boolean>
local configurable_disabled_actions = {
  goto_next_buffer = true,
  goto_previous_buffer = true,
  move_buffer_up = true,
  move_buffer_down = true,
  move_buffer_top = true,
  move_buffer_bottom = true,
  switch_previous_used_buffer = true,
  close_buffer = true,
  close_buffers_above = true,
  close_buffers_below = true,
  close_all_buffers = true,
  close_others = true,
  reopen_recent_closed_buffer = true,
}

---@type table<string, boolean>
local pagination_actions = {
  next_page = true,
  previous_page = true,
  move_to_next_page = true,
  move_to_previous_page = true,
}

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
---@field buffer_will_be_renamed string | nil
---@field active_buffer_by_page table<number>
---@field recently_closed BuffonRecentlyClosed
---@field buffers_will_close table<BuffonBuffer>
local MainController = {}

---@param cfg BuffonConfig
---@param page_controller BuffonPageController
function MainController:new(cfg, page_controller, stg)
  local o = {
    config = cfg,
    main_window = mainwindow.MainWindow:new(cfg, page_controller),
    help_window = helpwindow.HelpWindow:new(cfg),
    group = vim.api.nvim_create_augroup("Buffon", { clear = true }),
    page_controller = page_controller,
    storage = stg,
    index_buffer_active = nil,
    buffer_will_be_renamed = nil,
    active_buffer_by_page = {},
    recently_closed = utils.RecentlyClosed:new(),
    buffers_will_close = {},
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
  ---@type table<BuffonAction>
  local shortcuts = {
    {
      shortcut = "toggle_buffon_window",
      help = "Show/hide buffer list",
      method = self.action_show_hide_buffon_window,
    },
    {
      shortcut = "toggle_buffon_window_position",
      help = "Toggle window position",
      method = self.action_toggle_window_position,
    },
    {
      shortcut = "goto_next_buffer",
      help = "Next buffer",
      method = self.action_goto_next,
    },
    {
      shortcut = "goto_previous_buffer",
      help = "Previous buffer",
      method = self.action_goto_previous,
    },
    {
      shortcut = "next_page",
      help = "Next page",
      method = self.action_next_page,
      method_post_refresh = self.action_select_buffer,
    },
    {
      shortcut = "previous_page",
      help = "Previous page",
      method = self.action_previous_page,
      method_post_refresh = self.action_select_buffer,
    },
    {
      shortcut = "move_to_next_page",
      help = "Buffer to next page",
      method = self.action_buffer_to_next_page,
    },
    {
      shortcut = "move_to_previous_page",
      help = "Buffer to previous page",
      method = self.action_buffer_to_previous_page,
    },
    {
      shortcut = "move_buffer_up",
      help = "Move buffer up",
      method = self.action_move_buffer_up,
    },
    {
      shortcut = "move_buffer_down",
      help = "Move buffer down",
      method = self.action_move_buffer_down,
    },
    {
      shortcut = "move_buffer_top",
      help = "Move buffer to top",
      method = self.action_move_buffer_top,
    },
    {
      shortcut = "move_buffer_bottom",
      help = "Move buffer to bottom",
      method = self.action_move_buffer_bottom,
    },
    {
      shortcut = "close_buffer",
      help = "Close buffer",
      method = self.action_close_buffer,
    },
    {
      shortcut = "close_buffers_above",
      help = "Close buffers above",
      method = self.action_close_buffers_above,
    },
    {
      shortcut = "close_buffers_below",
      help = "Close buffers below",
      method = self.action_close_buffers_below,
    },
    {
      shortcut = "close_all_buffers",
      help = "Close all",
      method = self.action_close_buffers_all,
    },
    {
      shortcut = "close_others",
      help = "Close others",
      method = self.action_close_buffers_other,
    },
    {
      shortcut = "switch_previous_used_buffer",
      help = "Last used buffer",
      method = self.action_switch_previous_used,
    },
    {
      shortcut = "reopen_recent_closed_buffer",
      help = "Restore closed buffer",
      method = self.action_reopen_recent_closed,
    },
  }

  ---@type table<BuffonAction>
  local valid_shortcuts = {}
  for _, action in ipairs(shortcuts) do
    local action_can_be_disabled = configurable_disabled_actions[action.shortcut]
    local action_is_disabled = self.config.keybindings[action.shortcut] == "false"
    local is_pagination_action = pagination_actions[action.shortcut]
    local one_page = self.config.num_pages == 1

    if (action_can_be_disabled and action_is_disabled) or (one_page and is_pagination_action) then
      -- continue
      log.debug("action ignored", action.shortcut)
    else
      table.insert(valid_shortcuts, action)
    end
  end
  return valid_shortcuts
end

---@return table<BuffonAction>
function MainController:get_events()
  return {
    {
      vimevent = "BufAdd",
      method = self.event_add_buffer,
      require_match = true,
    },
    {
      vimevent = "BufDelete",
      method = self.event_remove_buffer,
      require_match = true,
    },
    {
      vimevent = "VimEnter",
      method = self.event_buffon_window_needs_open,
    },
    {
      vimevent = "BufEnter",
      method = self.event_buf_enter,
      require_match = true,
    },
    {
      vimevent = "VimResized",
    },
    {
      vimevent = "ExitPre",
      method = self.event_before_exit,
    },
    {
      vimevent = "BufLeave",
      method = self.event_before_buf_leave,
      require_match = true,
    },
    {
      vimevent = "BufModifiedSet",
    },
    {
      vimevent = "BufFilePre",
      method = self.event_buffer_will_rename,
    },
    {
      vimevent = "BufFilePost",
      method = self.event_rename_buffer,
    },
    {
      vimevent = "WinClosed",
      method = self.event_win_closed,
    },
  }
end

function MainController:register_shortcuts()
  for _, action in ipairs(self:get_shortcuts()) do
    local shortcut = utils.replace_leader(self.config, self.config.keybindings[action.shortcut])
    log.debug("registering shortcut", shortcut, "for", action.shortcut)
    set_keymap(shortcut, function()
      self:dispatch(action)
    end, action.help)
  end

  for idx = 1, #self.config.mapping_chars do
    local char = self.config.mapping_chars:sub(idx, idx)
    set_keymap(self.config.leader_key .. char, function()
      self:action_open_buffer_by_index(idx)
    end, "Goto to buffer " .. idx)
  end

  set_keymap(utils.replace_leader(self.config, self.config.keybindings.show_help), function()
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
    log.debug("event:", buf.event, "on", vim.fn.fnamemodify(buf.match, ":t"))
  end

  if action.method then
    action.method(self, buf)
  end

  self.main_window:refresh()

  if action.method_post_refresh then
    action.method_post_refresh(self, buf)
  end
end

---=========================================================================================
--- ↓ Actions starts here ↓
---=========================================================================================

function MainController:action_show_hide_buffon_window()
  self.main_window:toggle()
end

function MainController:action_toggle_window_position()
  self.main_window.window:toggle_position_between_top_right_bottom_right()
end

function MainController:event_add_buffer(buf)
  local existent_buf, num_page = self.page_controller:get_buffer_and_page(buf.match)
  log.debug("add", vim.fn.fnamemodify(buf.match, ":t"), "in page", num_page)

  -- if num_page is not nil, it means the buffer already exists. in that case, it should be activated
  if num_page and existent_buf then
    self.page_controller:set_page(num_page)
    existent_buf.id = buf.buf
  else
    self.page_controller:add_buffer_to_active_page(buffer.Buffer:new(buf.buf, buf.match), self.index_buffer_active)
  end
end

function MainController:event_buffon_window_needs_open()
  local should_open = self.config.open.by_default
  local buffer_ignored = vim.tbl_contains(self.config.open.ignore_ft, vim.bo.filetype)

  if should_open and not buffer_ignored then
    self.main_window:open()
  end
end

function MainController:event_before_exit(buf)
  self.page_controller:get_active_page().bufferslist:update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
  self.storage:save(self.page_controller:get_data())
end

function MainController:event_before_buf_leave(buf)
  self.page_controller:get_active_page().bufferslist:update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
  self.index_buffer_active = self.page_controller:get_active_page().bufferslist:get_index(buf.match)

  -- Save the current view (scroll position, cursor, etc) of the window
  vim.b.view = vim.fn.winsaveview()
end

function MainController:event_buf_enter()
  -- Restore the previously saved view (scroll position, cursor, etc) if it exists
  if vim.b.view then
    vim.fn.winrestview(vim.b.view)
    vim.b.view = nil
  end
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
  log.debug("open", buf.filename, "with id", buf.id)

  if buf.id then
    pcall(vim.api.nvim_set_current_buf, buf.id)
  else
    vim.api.nvim_command("edit " .. buf.name)
    buf.id = vim.api.nvim_get_current_buf()

    local set_cursor_success = pcall(vim.api.nvim_win_set_cursor, 0, buf.cursor)
    if not set_cursor_success then
      vim.api.nvim_win_set_cursor(0, { 1, 1 })
    end
  end
end

--------------------------------------------------------------------------------------------
--- ↓ Actions related with the navigation ↓
--------------------------------------------------------------------------------------------

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

--- Jump to previous used buffer
function MainController:action_switch_previous_used()
  local buffers = {}
  local current_name = utils.get_buffer_name()

  -- Add in buffers table the opened ones, ignoring invalids or current buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" and name ~= current_name then
      table.insert(buffers, { lastused = vim.fn.getbufinfo(buf)[1].lastused, name = vim.api.nvim_buf_get_name(buf) })
    end
  end

  -- Sort buffers by lastused
  table.sort(buffers, function(a, b)
    return a.lastused > b.lastused
  end)

  -- Get the buffer and page and activate it
  local previous_used = buffers[1]
  if not previous_used then
    return
  end

  local buf, num_page = self.page_controller:get_buffer_and_page(previous_used.name)
  if buf and num_page then
    self.page_controller:set_page(num_page)
    self:action_open_or_activate_buffer(buf)
  end
end

--------------------------------------------------------------------------------------------
--- ↓ Actions related with buffers movement  ↓
--------------------------------------------------------------------------------------------

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

function MainController:action_buffer_to_next_page()
  self.page_controller:move_to_next_page(utils.get_buffer_name())
end

function MainController:action_buffer_to_previous_page()
  self.page_controller:move_to_previous_page(utils.get_buffer_name())
end

--------------------------------------------------------------------------------------------
--- ↓ Actions related with close buffers  ↓
--------------------------------------------------------------------------------------------

function MainController:event_remove_buffer(buf)
  self.page_controller:remove_buffer_from_active_page(buf.match)
end

function MainController:close_buffer()
  log.debug(#self.buffers_will_close, "buffers will be deleted")

  local buf = table.remove(self.buffers_will_close)
  if not buf then
    return
  end

  log.debug("deleting", buf.filename, "with id", buf.id)
  if buf.id then
    if vim.api.nvim_buf_is_valid(buf.id) then
      vim.api.nvim_buf_delete(buf.id, { force = false })
    end
  else
    self.page_controller:remove_buffer_from_active_page(buf.name)
  end

  log.debug("buffer", buf.filename, "was deleted")
  self.recently_closed:add(buf.name)
  self:close_buffer()
end

function MainController:action_close_buffer()
  local buf = self.page_controller:get_active_page().bufferslist:get_by_name(utils.get_buffer_name())
  table.insert(self.buffers_will_close, buf)
  self:close_buffer()
end

function MainController:action_close_buffers_above()
  local buffers = self.page_controller:get_active_page().bufferslist:get_buffers_above(utils.get_buffer_name())
  utils.table_add(self.buffers_will_close, buffers)
  self:close_buffer()
end

function MainController:action_close_buffers_below()
  local buffers = self.page_controller:get_active_page().bufferslist:get_buffers_below(utils.get_buffer_name())
  utils.table_add(self.buffers_will_close, buffers)
  self:close_buffer()
end

function MainController:action_close_buffers_all()
  local buffers = self.page_controller:get_active_page():get_buffers()
  utils.table_add(self.buffers_will_close, buffers)
  self:close_buffer()
end

function MainController:action_close_buffers_other()
  local buffers = self.page_controller:get_active_page().bufferslist:get_other_buffers(utils.get_buffer_name())
  utils.table_add(self.buffers_will_close, buffers)
  self:close_buffer()
end

--------------------------------------------------------------------------------------------
--- ↓ Other actions  ↓
--------------------------------------------------------------------------------------------

function MainController:event_buffer_will_rename(buf)
  if buf.match == "" then
    return
  end

  log.debug("buffer will be renamed", vim.fn.fnamemodify(buf.match, ":t"))
  self.buffer_will_be_renamed = buf.match
end

function MainController:event_rename_buffer(buf)
  if not self.buffer_will_be_renamed or self.buffer_will_be_renamed == buf.match then
    return
  end

  log.debug("set new name", vim.fn.fnamemodify(buf.match, ":t"))
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

function MainController:event_win_closed(win)
  if tonumber(win.match) == self.main_window.window.win_id then
    log.debug("someone closed the buffon window")
    self.main_window.window:clear_ids()
  end
end

M.MainController = MainController

return M
