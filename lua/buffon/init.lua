local api = require("buffon.api")
local config = require("buffon.config")

local M = {}

local register_autocommands = function(group)
	vim.api.nvim_create_autocmd("BufNew", {
		group = group,
		callback = function(buf)
			api.add_buffer(buf.file, buf.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(buf)
			api.delete_buffer(buf.match)
		end,
	})
end

M.setup = function(opts)
	config.setup(opts)
	api.setup(config.opts())

	local group = vim.api.nvim_create_augroup("Buffon", { clear = true })
	register_autocommands(group)
end

return M
