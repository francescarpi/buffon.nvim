local keybindings = require("buffon.keybindings")

local M = {}

---@type BuffonHelpState
local state = {
  buf = nil,
  win = nil,
}

---@param keymaps table<BuffonKeybinding>
---@return [number, number] Returns [content width, number of lines]
local render_content = function(keymaps)
  local lines = {}
  local max_lhs_length = 0
  local width = 0

  for _, kb in ipairs(keymaps) do
    if #kb.lhs > max_lhs_length then
      max_lhs_length = #kb.lhs
    end
  end

  for _, kb in ipairs(keymaps) do
    local lhs_padded = kb.lhs .. string.rep(" ", max_lhs_length - #kb.lhs)
    local line = string.format("%s %s", lhs_padded, kb.help)
    table.insert(lines, line)

    if #line > width then
      width = #line
    end
  end

  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  for index, _ in ipairs(keymaps) do
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Constant", index - 1, 0, max_lhs_length)
  end

  return { width, #lines }
end

---@param rows number
---@param width number
local update_dimensions = function(width, rows)
  if not state.win then
    return
  end

  local editor_width = vim.api.nvim_get_option("columns")
  local editor_lines = vim.api.nvim_get_option("lines")
  local wincfg = vim.api.nvim_win_get_config(state.win)

  wincfg.width = width
  wincfg.col = editor_width - (1 + width + 1)
  wincfg.row = editor_lines - (1 + rows + 1) - 2

  vim.api.nvim_win_set_config(state.win, wincfg)
end

M.show = function()
  local keymaps = keybindings.keybindings()
  local window_options = {
    title = " Buffon Help ",
    title_pos = "right",
    relative = "editor",
    width = 1,
    height = #keymaps,
    col = 1,
    row = 1,
    style = "minimal",
    border = "single",
    zindex = 1,
    focusable = false,
  }
  state.buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(state.buf, false, window_options)
  local render_response = render_content(keymaps)
  update_dimensions(render_response[1], render_response[2])
end

M.close = function()
  vim.api.nvim_buf_delete(state.buf, { force = true })
  state.win = nil
  state.buf = nil
end

---@return boolean
M.is_open = function()
  if state.win then
    return true
  end
  return false
end

M.toggle = function()
  if not M.is_open() then
    M.show()
  else
    M.close()
  end
end

return M
