local api = require("buffon.api")
local config = require("buffon.config")
local keybindings = require("buffon.keybindings")
local ui = require("buffon.ui")
local storage = require("buffon.storage")
local actions = require("buffon.actions")
local log = require("buffon.log")

local M = {}

---@type string | nil
local buf_will_rename = nil

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
    buf_will_rename = buf.match
  end,
  BufFilePost = function(buf)
    assert(buf_will_rename, "new buffer name is required")
    api.rename_buffer(buf_will_rename, buf.match)
  end,
}

--- Sets up the Buffon plugin with the provided options.
--- Initializes configuration, API, UI, and keybindings.
--- Registers autocommands for buffer and UI events.
---@param opts table The options to configure the Buffon plugin.
M.setup = function(opts)
  log.debug("==== initial setup ====")
  config.setup(opts)
  local plugin_opts = config.opts()

  local stg = storage.Storage:new(vim.fn.getcwd())
  stg:init()

  actions.setup()
  api.setup(plugin_opts, stg)
  ui.setup(plugin_opts)
  keybindings.setup(plugin_opts)
  keybindings.register()

  local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
  for event, callback in pairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = callback,
    })
  end
end

return M
