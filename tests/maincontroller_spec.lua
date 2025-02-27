local eq = assert.are.same
local config = require("buffon.config")
local pagecontroller = require("buffon.pagecontroller")
local maincontroller = require("buffon.maincontroller")
local storage = require("buffon.storage")

---@param shortcuts table<BuffonAction>
---@param to_compare table<string>
local compare_shortcuts = function(shortcuts, to_compare)
  eq(#shortcuts, #to_compare)
  for i, action in ipairs(shortcuts) do
    eq(action.shortcut, to_compare[i])
  end
end

local default_shortcuts = {
  "toggle_buffon_window",
  "goto_next_buffer",
  "goto_previous_buffer",
  "next_page",
  "previous_page",
  "move_to_next_page",
  "move_to_previous_page",
  "move_buffer_up",
  "move_buffer_down",
  "move_buffer_top",
  "move_buffer_bottom",
  "close_buffer",
  "close_buffers_above",
  "close_buffers_below",
  "close_all_buffers",
  "close_others",
  "switch_previous_used_buffer",
  "reopen_recent_closed_buffer",
}

describe("maincontrolelr", function()
  it("default get_shortcuts", function()
    local cfg = config.Config:new({})
    local stg = storage.Storage:new("/foo/boo")
    local pagectrl = pagecontroller.PageController:new(cfg)
    local ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
    local shortcuts = ctrl:get_shortcuts()
    compare_shortcuts(shortcuts, default_shortcuts)
  end)

  it("disable close actions", function()
    local cfg = config.Config:new({
      keybindings = {
        close_buffer = "false",
        close_buffers_above = "false",
        close_buffers_below = "false",
        close_all_buffers = "false",
        close_others = "false",
      },
    })
    local stg = storage.Storage:new("/foo/boo")
    local pagectrl = pagecontroller.PageController:new(cfg)
    local ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
    local shortcuts = ctrl:get_shortcuts()
    compare_shortcuts(shortcuts, {
      "toggle_buffon_window",
      "goto_next_buffer",
      "goto_previous_buffer",
      "next_page",
      "previous_page",
      "move_to_next_page",
      "move_to_previous_page",
      "move_buffer_up",
      "move_buffer_down",
      "move_buffer_top",
      "move_buffer_bottom",
      "switch_previous_used_buffer",
      "reopen_recent_closed_buffer",
    })
  end)

  it("try disable unauthorized keybinding", function()
    local cfg = config.Config:new({
      keybindings = {
        goto_next_buffer = "false",
      },
    })
    local stg = storage.Storage:new("/foo/boo")
    local pagectrl = pagecontroller.PageController:new(cfg)
    local ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
    local shortcuts = ctrl:get_shortcuts()
    compare_shortcuts(shortcuts, default_shortcuts)
  end)

  it("if num_pages is 1, keybindings related with pagination are disabled", function()
    local cfg = config.Config:new({ num_pages = 1 })
    local stg = storage.Storage:new("/foo/boo")
    local pagectrl = pagecontroller.PageController:new(cfg)
    local ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
    local shortcuts = ctrl:get_shortcuts()
    compare_shortcuts(shortcuts, {
      "toggle_buffon_window",
      "goto_next_buffer",
      "goto_previous_buffer",
      "move_buffer_up",
      "move_buffer_down",
      "move_buffer_top",
      "move_buffer_bottom",
      "close_buffer",
      "close_buffers_above",
      "close_buffers_below",
      "close_all_buffers",
      "close_others",
      "switch_previous_used_buffer",
      "reopen_recent_closed_buffer",
    })
  end)
end)
