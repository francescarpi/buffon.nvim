local api = require("buffon.api")
local config = require("buffon.config")
local keybindings = require("buffon.keybindings")
local ui = require("buffon.ui")

local M = {}

--- Registers autocommands for buffer and UI events.
---@param group any The augroup to which the autocommands will be added.
local register_autocommands = function(group)
    vim.api.nvim_create_autocmd("BufAdd", {
        group = group,
        callback = function(buf)
            if buf and buf.match ~= "" then
                api.add_buffer(buf.match, buf.buf)
                ui.refresh()
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        callback = function(buf)
            if buf and buf.match ~= "" then
                api.delete_buffer(buf.match)
                ui.refresh()
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
            ui.refresh()
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function()
            ui.refresh()
        end,
    })
end

--- Sets up the Buffon plugin with the provided options.
--- Initializes configuration, API, UI, and keybindings.
--- Registers autocommands for buffer and UI events.
---@param opts table The options to configure the Buffon plugin.
M.setup = function(opts)
    config.setup(opts)
    local plugin_opts = config.opts()

    api.setup(plugin_opts)
    ui.setup(plugin_opts)
    keybindings.setup(plugin_opts)
    keybindings.register()

    local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
    register_autocommands(group)
end

return M
