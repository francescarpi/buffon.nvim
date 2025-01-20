local api = require("buffon.api")

local M = {}

local keymap = function(m, shortcut, callback)
	vim.keymap.set("n", shortcut, callback, {
		buffer = m.content_buf,
		silent = true,
	})
end

M.register = function(m)
	keymap(m, "q", function()
		m.close()
	end)

	keymap(m, "esc", function()
		m.close()
	end)

	keymap(m, "<cr>", function()
		local line_num = vim.fn.line(".")
		local buffer = api.get_buffer_by_index(line_num)
		if buffer then
			m.close()
			vim.api.nvim_set_current_buf(buffer.id)
		end
	end)
end

return M
