local api = require("buffon.api")
local keybindings = require("buffon.keybindings")

local M = {}

---@type BuffonHelpState
local state = {
  buf = nil,
  win = nil,
}

---@param keymaps table<BuffonKeybinding>
local render_content = function(keymaps)
  local lines = {}
  local max_lhs_length = 0

  for _, kb in ipairs(keymaps) do
    if #kb.lhs > max_lhs_length then
      max_lhs_length = #kb.lhs
    end
  end

  for _, kb in ipairs(keymaps) do
    local lhs_padded = kb.lhs .. string.rep(" ", max_lhs_length - #kb.lhs)
    table.insert(lines, string.format("%s  %s", lhs_padded, kb.help))
  end

  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  for index, _ in ipairs(keymaps) do
    vim.api.nvim_buf_add_highlight(state.buf, -1, "Constant", index - 1, 0, max_lhs_length)
  end
end

M.update_row = function()
  if not state.win then
    return
  end

  local wincfg = vim.api.nvim_win_get_config(state.win)
  wincfg.row = #api.get_buffers() + 2
  vim.api.nvim_win_set_config(state.win, wincfg)
end

M.show = function()
  local keymaps = keybindings.keybindings()
  local width = 28
  local editor_width = vim.api.nvim_get_option("columns")
  local window_options = {
    footer = " Buffon Help ",
    footer_pos = "right",
    relative = "editor",
    width = width,
    height = #keymaps,
    col = editor_width - (1 + width + 1),
    row = 1,
    style = "minimal",
    border = "single",
    zindex = 1,
    focusable = false,
  }
  state.buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(state.buf, false, window_options)
  M.update_row()
  render_content(keymaps)
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
