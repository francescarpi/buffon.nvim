local api = require("buffon.api")
local keymaps = require("buffon.ui.keymaps")

local M = {}

---@class UIState
---@field content_buf number | nil
---@field content_win number | nil
---@field container_win number | nil
---@field container_buf number | nil
local state = {
	content_buf = nil,
	content_win = nil,
	container_win = nil,
	container_buf = nil,
}

local update_content = function()
	assert(state.content_buf, "buf must to be created")

	local content_lines = {}
	local container_lines = {}
	for index, buffer in ipairs(api.get_buffers_list()) do
		table.insert(content_lines, buffer.name)
		table.insert(container_lines, string.format("%2d", index))
	end

	vim.api.nvim_buf_set_lines(state.content_buf, 0, -1, false, content_lines)
	vim.api.nvim_buf_set_lines(state.container_buf, 0, -1, false, container_lines)

	for line = 0, #container_lines do
		vim.api.nvim_buf_add_highlight(state.container_buf, -1, "Constant", line, 0, -1)
	end
end

M.close = function()
	vim.api.nvim_win_close(state.content_win, true)
	vim.api.nvim_win_close(state.container_win, true)
	state.content_win = nil
	state.container_win = nil
end

M.show = function()
	if state.content_win and vim.api.nvim_win_is_valid(state.content_win) == false then
		state.content_win = nil
		state.container_win = nil
	end

	if state.content_win ~= nil then
		M.close()
		return
	end

	if state.content_buf == nil then
		state.content_buf = vim.api.nvim_create_buf(false, true)
		state.container_buf = vim.api.nvim_create_buf(false, true)
		keymaps.register(state.content_buf, M.close)
	end

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	local opts_container = {
		title = " Buffon ",
		title_pos = "center",
		relative = "editor",
		width = math.floor(width * 0.5),
		height = math.floor(height * 0.5),
		col = math.floor(width * 0.25),
		row = math.floor(height * 0.25),
		style = "minimal",
		border = "single",
		zindex = 1,
	}

	local opts_content = {
		relative = "editor",
		width = math.floor(width * 0.5) - 3,
		height = math.floor(height * 0.5),
		col = math.floor(width * 0.25) + 4,
		row = math.floor(height * 0.25) + 1,
		style = "minimal",
		zindex = 2,
	}

	state.content_win = vim.api.nvim_open_win(state.content_buf, true, opts_content)
	state.container_win = vim.api.nvim_open_win(state.container_buf, false, opts_container)
	update_content()
end

return M
