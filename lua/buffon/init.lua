local api = require("buffon.api")
local config = require("buffon.config")
local keybindings = require("buffon.keybindings")
local ui = require("buffon.ui.main")
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
      api.add_buffer(buf.match, buf.buf)
      ui.refresh()
    end
  end,
  BufDelete = function(buf)
    if buf and buf.match ~= "" then
      api.delete_buffer(buf.match)
      ui.refresh()
    end
  end,
  BufEnter = function()
    ui.refresh()
    ui.check_open()
  end,
  VimResized = function()
    ui.refresh()
  end,
  BufFilePre = function(buf)
    state.buf_will_rename = buf.match
  end,
  BufFilePost = function(buf)
    assert(state.buf_will_rename, "new buffer name is required")
    api.rename_buffer(state.buf_will_rename, buf.match)
  end,
  ExitPre = function(buf)
    api.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
    assert(state.storage, "storage is required")
    local buffers = api.get_buffers()
    state.storage:save(buffers)
  end,
  BufLeave = function(buf)
    api.update_cursor(buf.match, vim.api.nvim_win_get_cursor(0))
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
  local buffers = state.storage:load()

  actions.setup()
  api.setup(cfg, buffers)
  ui.setup(cfg)
  keybindings.setup(cfg)

  local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
  for event, callback in pairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = callback,
    })
  end
end

return M
