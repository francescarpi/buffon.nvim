local api = require("buffon.api")

local M = {}

---@class UIState
---@field content_buf number | nil
---@field content_win number | nil
local state = {
	content_buf = nil,
	content_win = nil,
}

local update_content = function()
	assert(state.content_buf, "buf must to be created")

	local lines = {}
	for _, buffer in ipairs(api.get_buffers_list()) do
		table.insert(lines, buffer.name)
	end

	vim.api.nvim_buf_set_lines(state.content_buf, 0, -1, false, lines)
end

local keymap = function(shortcut, callback)
	vim.keymap.set("n", shortcut, callback, {
		buffer = state.content_buf,
		silent = true,
	})
end

local register_keymaps = function()
	keymap("q", function()
		M.close()
	end)

	keymap("esc", function()
		M.close()
	end)

	keymap("<cr>", function()
		local line_num = vim.fn.line(".")
		local buffer = api.get_buffer_by_index(line_num)
		if buffer then
			M.close()
			vim.api.nvim_set_current_buf(buffer.id)
		end
	end)
end

M.close = function()
	vim.api.nvim_win_close(state.content_win, true)
	state.content_win = nil
end

M.show = function()
	if state.content_win and vim.api.nvim_win_is_valid(state.content_win) == false then
		state.content_win = nil
	end

	if state.content_win ~= nil then
		M.close()
		return
	end

	if state.content_buf == nil then
		state.content_buf = vim.api.nvim_create_buf(false, true)
		register_keymaps()
	end

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")
	local opts = {
		title = " Buffon ",
		title_pos = "center",
		relative = "editor",
		width = math.floor(width * 0.5),
		height = math.floor(height * 0.5),
		col = math.floor(width * 0.25),
		row = math.floor(height * 0.25),
		style = "minimal",
		border = "single",
	}
	state.content_win = vim.api.nvim_open_win(state.content_buf, true, opts)
	update_content()
end

return M
