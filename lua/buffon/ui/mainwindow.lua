local window = require("buffon.ui.window")
local utils = require("buffon.utils")

local M = {}

---@class BuffonMainWindow
---@field window BuffonWindow
---@field page_controller BuffonPageController
---@field config BuffonConfig
local MainWindow = {}

---@param config BuffonConfig
---@param page_controller BuffonPageController
function MainWindow:new(config, page_controller)
  local title = " Buffon (" .. utils.replace_leader(config, config.keybindings.show_help) .. ") "
  local o = {
    window = window.Window:new(title, window.WIN_POSITIONS.TOP_RIGHT),
    page_controller = page_controller,
    config = config,
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

function MainWindow:toggle()
  self.window:toggle()
end

function MainWindow:open()
  self.window:show()
end

---@return string
function MainWindow:footer()
  local footer = ""
  for i = 1, self.config.num_pages do
    if i == self.page_controller.active then
      footer = footer .. "●"
    else
      footer = footer .. "○"
    end
  end
  return footer
end

function MainWindow:refresh()
  if not self.window:is_open() then
    return
  end

  local render = self.page_controller:get_active_page():render()
  self.window:set_content(render.content)
  self.window:set_highlight(render.highlights)
  if self.config.num_pages > 1 then
    self.window:set_footer(self:footer())
  end
  self.window:refresh_dimensions()
end

M.MainWindow = MainWindow

return M
