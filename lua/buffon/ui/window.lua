local log = require("buffon.log")
local utils = require("buffon.utils")

local M = {}

---@enum win_position
local WIN_POSITION = {
	TOP_RIGHT = "top_right",
	BOTTOM_RIGHT = "bottom_right",
}

---@class Vector2
---@field x integer
---@field y integer

---@class BuffonWindow
---@field title string
---@field win_id number | nil
---@field buf_id number | nil
---@field position win_position
---@field offset Vector2
local Window = {
	title = "",
	footer = "",
	win_id = nil,
	buf_id = nil,
	position = WIN_POSITION.TOP_RIGHT,
	offset = {
		x = 0,
		y = 0,
	},
}

---@param title string
---@param position win_position
---@param offset Vector2
---@return BuffonWindow
function Window:new(title, position, offset)
	local o = {
		title = title,
		win_id = nil,
		buf_id = nil,
		position = position,
		offset = offset,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Window:show()
	if self.win_id then
		return
	end
	self.buf_id = vim.api.nvim_create_buf(false, true)
	self.win_id = vim.api.nvim_open_win(self.buf_id, false, {
		title = self.title,
		title_pos = "right",
		footer = self.footer,
		footer_pos = "center",
		relative = "editor",
		width = 10,
		height = 2,
		col = 1,
		row = 0,
		style = "minimal",
		border = "single",
		zindex = 21,
		focusable = false,
	})
	self:refresh_dimensions()
end

function Window:is_open()
	return self.win_id ~= nil
end

function Window:hide()
	if self.win_id and not vim.api.nvim_win_is_valid(self.win_id) then
		self:clear_ids()
	end

	if not self.win_id then
		return
	end

	vim.api.nvim_win_close(self.win_id, false)
	self:clear_ids()
end

function Window:clear_ids()
	self.win_id = nil
	self.buf_id = nil
end

function Window:toggle()
	if self.win_id then
		self:hide()
	else
		self:show()
	end
end

---@param content table<string>
function Window:set_content(content)
	if not self.buf_id then
		log.debug("set_content aborted because there is not a buffer")
		return
	end
	vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, content)
end

---@param text string
function Window:set_footer(text)
	self.footer = " " .. text .. " "
end

---@class BuffonWindowHighlight
---@field line number
---@field col_start number
---@field col_end number

---@alias BuffonWindowHighlights table<string, table<BuffonWindowHighlight>>

--- The highlight parameter is a dictionary where the key is hl_group and the
--- value a table of tuples with the values [line, col_start, col_end]
---@param highlights BuffonWindowHighlights
function Window:set_highlight(highlights)
	if not self.buf_id then
		log.debug("set_highlight aborted because there is not a buffer")
		return
	end
	for hl_group, lines_info in pairs(highlights) do
		for _, line_info in ipairs(lines_info) do
			vim.api.nvim_buf_add_highlight(self.buf_id, -1, hl_group, line_info.line, line_info.col_start, line_info.col_end)
		end
	end
end

function Window:refresh_dimensions()
	if not self.win_id or not vim.api.nvim_win_is_valid(self.win_id) then
		return
	end

	local editor_columns = vim.api.nvim_get_option("columns")
	local editor_lines = vim.api.nvim_get_option("lines")
	local lines = vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, false)
	local height = #lines
	local max_width = utils.calc_max_length(vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, false))
	local row = 1
	local col = 0

	if self.position == WIN_POSITION.TOP_RIGHT then
		row = 0
		col = editor_columns - (1 + max_width + 1)
	elseif self.position == WIN_POSITION.BOTTOM_RIGHT then
		row = editor_lines - (1 + #lines + 1) - 2
		col = editor_columns - (1 + max_width + 1)
	end

	col = col + self.offset.x
	row = row + self.offset.y

	if max_width == 0 then
		max_width = 20
	end

	local cfg = vim.api.nvim_win_get_config(self.win_id)
	cfg.width = max_width
	cfg.height = height
	cfg.col = col
	cfg.row = row
	cfg.footer = self.footer
	cfg.footer_pos = "center"

	vim.api.nvim_win_set_config(self.win_id, cfg)
end

function Window:toggle_position_between_top_right_bottom_right()
	if self.position == WIN_POSITION.TOP_RIGHT then
		self.position = WIN_POSITION.BOTTOM_RIGHT
	else
		self.position = WIN_POSITION.TOP_RIGHT
	end
end

M.Window = Window
M.WIN_POSITIONS = WIN_POSITION

return M
