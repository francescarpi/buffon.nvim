local keybindings = require("buffon.keybindings")
local window = require("buffon.ui.window")

local M = {}

---@type BuffonHelpState
local state = {
  content_rendered = false,
}

---@param win Window
local set_content = function(win)
  local lines = {}
  local max_lhs_length = 0
  local bindings = keybindings.keybindings()
  local highlight = { Constant = {} }

  for _, kb in ipairs(bindings) do
    if #kb.lhs > max_lhs_length then
      max_lhs_length = #kb.lhs
    end
  end

  for index, kb in ipairs(bindings) do
    local lhs_padded = kb.lhs .. string.rep(" ", max_lhs_length - #kb.lhs)
    local line = string.format("%s %s", lhs_padded, kb.help)
    table.insert(lines, line)
    table.insert(highlight.Constant, { index - 1, 0, max_lhs_length })
  end

  win:set_content(lines)
  win:set_highlight(highlight)
end

M.setup = function()
  state.window = window.Window:new(" Buffon Help ", window.WIN_POSITIONS.bottom_right)
end

M.toggle = function()
  if not state.content_rendered then
    set_content(state.window)
    state.content_rendered = true
  end
  state.window:toggle()
end

return M
