local M = {}

local default = {
  cyclic_navigation = true,
  --- possible values:
  ---   "start": buffers are added at the begginning of the buffers list
  ---   "end": buffers are added at the end of the list
  ---   "after": are added after the active buffer
  new_buffer_position = "end",
  num_pages = 2,
  open = {
    by_default = true,
    offset = {
      x = 0,
      y = 0,
    },
    ignore_ft = {
      "gitcommit",
      "gitrebase",
    },
  },
  --- Buffers that should be ignored by buffon
  --- It accepts a list of regex patterns
  ignore_buff_names = {
    "diffpanel_",
  },
  sort_buffers_by_loaded_status = false,
  theme = {
    unloaded_buffer = "#404040",
    shortcut = "#CC7832",
    active = "#51afef",
    unsaved_indicator = "#f70067",
  },
  leader_key = ";",
  mapping_chars = "qweryuiop",
  keybindings = {
    goto_next_buffer = "<s-j>",
    goto_previous_buffer = "<s-k>",
    move_buffer_up = "<s-l>",
    move_buffer_down = "<s-h>",
    move_buffer_top = "<s-t>",
    move_buffer_bottom = "<s-b>",
    toggle_buffon_window = "<buffonleader>n",
    --- Toggle window position allows moving the main window position
    --- between top-right and bottom-right positions
    toggle_buffon_window_position = "<buffonleader>nn",
    switch_previous_used_buffer = "<buffonleader><buffonleader>",
    close_buffer = "<buffonleader>d",
    close_buffers_above = "<buffonleader>v",
    close_buffers_below = "<buffonleader>b",
    close_all_buffers = "<buffonleader>cc",
    close_others = "<buffonleader>cd",
    reopen_recent_closed_buffer = "<buffonleader>t",
    show_help = "<buffonleader>h",
    previous_page = "<buffonleader>z",
    next_page = "<buffonleader>x",
    move_to_previous_page = "<buffonleader>a",
    move_to_next_page = "<buffonleader>s",
  },
}

---@class BuffonConfigOpen
---@field by_default boolean
---@field ignore_ft table<string>
---@field offset Vector2

---@class BuffonConfigKeyBinding
---@field goto_next_buffer string
---@field goto_previous_buffer string
---@field move_buffer_up string|false
---@field move_buffer_down string|false
---@field move_buffer_top string|false
---@field move_buffer_bottom string|false
---@field toggle_buffon_window string
---@field toggle_buffon_window_position string
---@field switch_previous_used_buffer string|false
---@field close_buffer string|false
---@field close_buffers_above string|false
---@field close_buffers_below string|false
---@field close_all_buffers string|false
---@field close_others string|false
---@field reopen_recent_closed_buffer string|false
---@field show_help string
---@field next_page string
---@field previous_page string
---@field move_to_previous_page string
---@field move_to_next_page string

---@class BuffonTheme
---@field unloaded_buffer string
---@field shortcut string
---@field active string
---@field unsaved_indicator string

---@class BuffonConfig
---@field cyclic_navigation boolean -- If true, navigation between buffers will wrap around (cyclic navigation).
---@field num_pages number
---@field new_buffer_position "start" | "end" | "after"
---@field open BuffonConfigOpen
---@field keybindings BuffonConfigKeyBinding
---@field leader_key string -- Leader key used as a prefix for buffer mappings (';' creates mappings ';q', ';w', etc.)
---@field mapping_chars string -- Each character maps to a buffer ("qwer" maps 'q' to buffer 1, 'w' to buffer 2, etc.)
local Config = {}

---@param opts any
function Config:new(opts)
  local cfg = vim.tbl_deep_extend("force", default, opts or {})
  if cfg.num_pages < 1 or cfg.num_pages > 4 then
    cfg.num_pages = 1
  end
  setmetatable(cfg, self)
  self.__index = self

  cfg:load_theme()

  return cfg
end

---@param name string
---@param color string
local set_hl = function(name, color)
  local ns = vim.api.nvim_get_hl_ns({})
  local hl = vim.api.nvim_get_hl(ns, { name = name })
  if hl.fg == nil then
    vim.api.nvim_set_hl(0, name, { fg = color })
  end
end

function Config:load_theme()
  set_hl("BuffonUnloadedBuffer", self.theme.unloaded_buffer)
  set_hl("BuffonShortcut", self.theme.shortcut)
  set_hl("BuffonLineActive", self.theme.active)
  set_hl("BuffonUnsavedIndicator", self.theme.unsaved_indicator)
end

M.Config = Config

return M
