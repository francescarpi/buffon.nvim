local log = require("buffon.log")

local M = {}

---@enum win_position
local WIN_POSITION = {
  top_right = 0,
  bottom_right = 1,
}

---@param win_id number
---@param buf_id number
---@param position win_position
local update_position_and_dimensions = function(win_id, buf_id, position)
  local editor_columns = vim.api.nvim_get_option("columns")
  local editor_lines = vim.api.nvim_get_option("lines")
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local height = #lines
  local width = 0
  local row = 1
  local col = 0

  for _, line in ipairs(lines) do
    if #line > width then
      width = #line
    end
  end

  if position == WIN_POSITION.top_right then
    row = 0
    col = editor_columns - (1 + width + 1)
  elseif position == WIN_POSITION.bottom_right then
    row = editor_lines - (1 + #lines + 1) - 2
    col = editor_columns - (1 + width + 1)
  end

  local cfg = vim.api.nvim_win_get_config(win_id)
  cfg.width = width
  cfg.height = height
  cfg.col = col
  cfg.row = row

  vim.api.nvim_win_set_config(win_id, cfg)
end

---@class Window
---@field title string
---@field win_id number | nil
---@field buf_id number | nil
---@field position win_position
local Window = {
  title = "",
  win_id = nil,
  buf_id = nil,
  position = WIN_POSITION.top_right,
}

---@param title string
---@param position win_position
---@return Window
function Window:new(title, position)
  local o = {
    title = title,
    win_id = nil,
    buf_id = vim.api.nvim_create_buf(false, true),
    position = position,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Window:show()
  if self.win_id then
    return
  end
  self.win_id = vim.api.nvim_open_win(self.buf_id, false, {
    title = self.title,
    title_pos = "right",
    relative = "editor",
    width = 10,
    height = 2,
    col = 1,
    row = 0,
    style = "minimal",
    border = "single",
    zindex = 1,
    focusable = false,
  })
  update_position_and_dimensions(self.win_id, self.buf_id, self.position)
end

function Window:hide()
  if not self.win_id then
    return
  end
  vim.api.nvim_win_close(self.win_id, true)
  self.win_id = nil
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

---@param highlight table<string, table<[number, number, number]>> Dictionary where the key is hl_group and the value a
---                                                                table of tuples with the values [line, col_start, col_end]
function Window:set_highlight(highlight)
  if not self.buf_id then
    log.debug("set_highlight aborted because there is not a buffer")
    return
  end
  for hl_group, lines_info in pairs(highlight) do
    for _, line_info in ipairs(lines_info) do
      vim.api.nvim_buf_add_highlight(self.buf_id, -1, hl_group, line_info[1], line_info[2], line_info[3])
    end
  end
end

M.Window = Window
M.WIN_POSITIONS = WIN_POSITION

return M
