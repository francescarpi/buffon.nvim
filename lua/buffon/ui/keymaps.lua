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
		-- sort buffers
		local buffers = api.get_buffers_list()
		local lines = vim.api.nvim_buf_get_lines(buffer_id, 0, -1, false)
		if #lines == #buffers then
			api.sort_buffers_by_list(lines)
		end

		-- close unexistent buffers
		if #lines < #buffers then
			local group_lines = {}
			for _, line in ipairs(lines) do
				group_lines[line] = true
			end

			for _, buffer in ipairs(buffers) do
				if group_lines[buffer.name] == nil then
					vim.api.nvim_buf_delete(buffer.id, { force = false })
				end
			end
		end

		-- open selected buffer
		local line_num = vim.fn.line(".")
		local buffer = api.get_buffer_by_index(line_num)
		if buffer then
			vim.api.nvim_set_current_buf(buffer.id)
		end

		-- close modal
		close()
	end)
end

return M
