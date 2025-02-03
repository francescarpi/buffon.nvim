local buffers = require("buffon.buffers")
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
}

---@type table<string, function>
local events = {
  BufAdd = function(buf)
    if buf and buf.match ~= "" then
      buffers.add_buffer(buf.match, buf.buf)
      main_win.refresh()
    end
  end,
  BufDelete = function(buf)
    if buf and buf.match ~= "" then
      buffers.delete_buffer(buf.match)
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
    buffers.rename_buffer(state.buf_will_rename, buf.match)
  end,
  ExitPre = function(buf)
    buffers.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
    assert(state.storage, "storage is required")
    local buffers_to_store = buffers.get_buffers()
    state.storage:save(buffers_to_store)
  end,
  BufLeave = function(buf)
    buffers.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
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
  buffers.setup(cfg, loaded_buffers)
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
