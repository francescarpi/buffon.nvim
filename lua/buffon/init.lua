local api_buffers = require("buffon.api.buffers")
local config = require("buffon.config")
local keybindings = require("buffon.keybindings")
local main_win = require("buffon.ui.main")
local help_win = require("buffon.ui.help")
local storage = require("buffon.storage")
local actions = require("buffon.actions")
local log = require("buffon.log")

local M = {}

---@type BuffonState
local state = {
  buf_will_rename = nil,
  storage = nil,
  buffer_active = nil,
}

---@return number | nil
local buffer_active_index = function()
  local buffer_id = vim.api.nvim_get_current_buf()
  local buffer_name = vim.api.nvim_buf_get_name(buffer_id)
  local index_group = api_buffers.get_index_and_group_by_name(buffer_name)
  if index_group then
    return index_group.index
  end
end

---@type table<string, function>
local events = {
  BufAdd = function(buf)
    if buf and buf.match ~= "" then
      api_buffers.add_buffer(buf.match, buf.buf, state.buffer_active)
      main_win.refresh()
    end
  end,
  BufDelete = function(buf)
    if buf and buf.match ~= "" then
      api_buffers.del.delete_buffer(buf.match)
      main_win.refresh()
    end
  end,
  BufEnter = function()
    main_win.refresh()
  end,
  VimEnter = function()
    main_win.check_open()
  end,
  VimResized = function()
    main_win.refresh()
  end,
  BufFilePre = function(buf)
    state.buf_will_rename = buf.match
  end,
  BufFilePost = function(buf)
    assert(state.buf_will_rename, "new buffer name is required")
    api_buffers.rename_buffer(state.buf_will_rename, buf.match)
  end,
  ExitPre = function(buf)
    api_buffers.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
    assert(state.storage, "storage is required")
    local buffers_to_store = api_buffers.get_groups()
    state.storage:save(buffers_to_store)
  end,
  BufLeave = function(buf)
    api_buffers.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
    actions.save_last_used(buf.match)
    state.buffer_active = buffer_active_index()
  end,
  BufModifiedSet = function()
    main_win.refresh()
  end,
}

--- Sets up the Buffon plugin with the provided options.
--- Initializes configuration, API, UI, and keybindings.
--- Registers autocommands for buffer and UI events.
---@param opts table The options to configure the Buffon plugin.
M.setup = function(opts)
  log.debug("==== initial setup ====")

  local cfg = config.setup(opts)

  state.storage = storage.Storage:new(vim.fn.getcwd())
  state.storage:init()
  local loaded_buffers = state.storage:load()

  actions.setup()
  api_buffers.setup(cfg, loaded_buffers)
  keybindings.setup(cfg)
  main_win.setup(cfg)
  help_win.setup()

  local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
  for event, callback in pairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = callback,
    })
  end
end

return M
