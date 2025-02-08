local log = require("buffon.log")

local M = {}

---@enum win_position
local WIN_POSITION = {
  top_right = 0,
  bottom_right = 1,
}

---@class Window
---@field title string
---@field win_id number | nil
---@field buf_id number | nil
---@field position win_position
local Window = {
  title = "",
  footer = "",
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
    footer = self.footer,
    footer_pos = "center",
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
  self:refresh_dimensions()
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

---@param text string
function Window:set_footer(text)
  self.footer = " " .. text .. " "
end

--- The highlight parameter is a dictionary where the key is hl_group and the
--- value a table of tuples with the values [line, col_start, col_end]
---@param highlight table<string, table<[number, number, number]>>
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

---@return number
function Window:get_max_width()
  local lines = vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, false)
  local max_width = 0
  for _, line in ipairs(lines) do
    local line_length = vim.fn.strdisplaywidth(line)
    if line_length > max_width then
      max_width = line_length
    end
  end
  return max_width
end

function Window:refresh_dimensions()
  if not self.win_id then
    return
  end

  local editor_columns = vim.api.nvim_get_option("columns")
  local editor_lines = vim.api.nvim_get_option("lines")
  local lines = vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, false)
  local height = #lines
  local max_width = self:get_max_width()
  local row = 1
  local col = 0

  if self.position == WIN_POSITION.top_right then
    row = 0
    col = editor_columns - (1 + max_width + 1)
  elseif self.position == WIN_POSITION.bottom_right then
    row = editor_lines - (1 + #lines + 1) - 2
    col = editor_columns - (1 + max_width + 1)
  end

  if max_width == 0 then
    max_width = 20
  end

  local cfg = vim.api.nvim_win_get_config(self.win_id)
  cfg.width = max_width
  cfg.height = height
  cfg.col = col
  cfg.row = row
  cfg.footer = self.footer

  vim.api.nvim_win_set_config(self.win_id, cfg)
end

M.Window = Window
M.WIN_POSITIONS = WIN_POSITION

return M
