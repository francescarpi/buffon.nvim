local window = require("buffon.ui.window")

local M = {}

---@class BuffonHelpWindow
---@field window BuffonWindow
---@field content_set boolean
local HelpWindow = {}

function HelpWindow:new()
  local o = {
    window = window.Window:new(" Buffon Help ", window.WIN_POSITIONS.BOTTOM_RIGHT),
    content_set = false,
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

---@param actions table<BuffonAction>
function HelpWindow:toggle(actions)
  if not self.content_set then
    self.content_set = true

    local max_length = 0
    local highlight = { Constant = {} }

    for _, action in ipairs(actions) do
      if #action.shortcut > max_length then
        max_length = #action.shortcut
      end
    end

    local content = {}
    for idx, action in ipairs(actions) do
      local shortcut_padded = action.shortcut .. string.rep(" ", max_length - #action.shortcut)
      local line = string.format("%s %s", shortcut_padded, action.help)
      table.insert(content, line)
      table.insert(highlight.Constant, { line = idx - 1, col_start = 0, col_end = max_length })
    end

    self.window:set_content(content)
    self.window:set_highlight(highlight)
  end

  self.window:toggle()
end

M.HelpWindow = HelpWindow

return M
