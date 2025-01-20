local api = require("buffon.api")

local M = {}

local keymap = function(buffer_id, shortcut, callback)
	vim.keymap.set("n", shortcut, callback, {
		buffer = buffer_id,
		silent = true,
	})
end

---@param buffer_id number
---@param close function
M.register = function(buffer_id, close)
	keymap(buffer_id, "q", function()
		close()
	end)

	keymap(buffer_id, "esc", function()
		close()
	end)

	keymap(buffer_id, "<cr>", function()
		api.sort_buffers_by_list(vim.api.nvim_buf_get_lines(buffer_id, 0, -1, false))

		local line_num = vim.fn.line(".")
		local buffer = api.get_buffer_by_index(line_num)
		if buffer then
			vim.api.nvim_set_current_buf(buffer.id)
		end
		close()
	end)
end

return M
