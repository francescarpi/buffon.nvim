local api = require("buffon.api")
local config = require("buffon.config")
local utils = require("buffon.utils")
local keybindings = require("buffon.keybindings")

local M = {}

local register_autocommands = function(group)
	vim.api.nvim_create_autocmd("BufNew", {
		group = group,
		callback = function(buf)
			api.add_buffer(utils.format_buffer_name(buf.match), buf.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(buf)
			api.delete_buffer(utils.format_buffer_name(buf.match))
		end,
	})
end

M.setup = function(opts)
	config.setup(opts)
	local plugin_opts = config.opts()
	api.setup(plugin_opts)
	keybindings.register(plugin_opts.leader_key, plugin_opts.buffer_mappings_chars)

	local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
	register_autocommands(group)
end

return M
