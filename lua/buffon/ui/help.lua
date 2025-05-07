local window = require("buffon.ui.window")
local utils = require("buffon.utils")

local M = {}

---@class BuffonHelpWindow
---@field config BuffonConfig
---@field window BuffonWindow
local HelpWindow = {}

---@param cfg BuffonConfig
function HelpWindow:new(cfg)
  local o = {
    config = cfg,
    window = window.Window:new(" Buffon Help ", window.WIN_POSITIONS.BOTTOM_RIGHT),
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

---@param actions table<BuffonAction>
function HelpWindow:toggle(actions)
  if self.window:is_open() then
    self.window:hide()
    return
  end

  local max_length = 0
  local highlight = { BuffonShortcut = {} }

  for _, action in ipairs(actions) do
    local action_len = #utils.replace_leader(self.config, self.config.keybindings[action.shortcut])
    if action_len > max_length then
      max_length = action_len
    end
  end

  local content = {}
  for idx, action in ipairs(actions) do
    local shortcut = utils.replace_leader(self.config, self.config.keybindings[action.shortcut])
		if shortcut == "" then
			goto continue
		end
    local shortcut_padded = shortcut .. string.rep(" ", max_length - #shortcut)
    local line = string.format("%s %s", shortcut_padded, action.help)
    table.insert(content, line)
    table.insert(highlight.BuffonShortcut, { line = idx - 1, col_start = 0, col_end = max_length })

		::continue::
  end

  self.window:show()
  self.window:set_content(content)
  self.window:set_highlight(highlight)
  self.window:refresh_dimensions()
end

M.HelpWindow = HelpWindow

return M
