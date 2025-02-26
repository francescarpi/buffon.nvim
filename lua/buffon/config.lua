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
    ignore_ft = {
      "gitcommit",
      "gitrebase",
    },
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
    switch_previous_used_buffer = "<buffonleader><buffonleader>",
    close_buffer = "<buffonleader>d",
    close_buffers_above = "<buffonleader>v",
    close_buffers_below = "<buffonleader>b",
    close_all_buffers = "<buffonleader>cc",
    close_others = "<buffonleader>cd",
    reopen_recent_closed_buffer = "<buffonleader>t",
    show_help = "<buffonleader>h",
    previous_page = "<s-tab>",
    next_page = "<tab>",
    move_to_previous_page = "<buffonleader>a",
    move_to_next_page = "<buffonleader>s",
  },
}

---@class BuffonConfigOpen
---@field by_default boolean
---@field ignore_ft table<string>

---@class BuffonConfigKeyBinding
---@field goto_next_buffer string
---@field goto_previous_buffer string
---@field move_buffer_up string
---@field move_buffer_down string
---@field move_buffer_top string
---@field toggle_buffon_window string
---@field switch_previous_used_buffer string
---@field close_buffer string
---@field close_buffers_above string
---@field close_buffers_below string
---@field close_all_buffers string
---@field close_others string
---@field restore_last_closed_buffer string
---@field show_help string
---@field next_page string
---@field previous_page string
---@field move_to_previous_page string
---@field move_to_next_page string

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
  local o = vim.tbl_deep_extend("force", default, opts or {})
  setmetatable(o, self)
  self.__index = self
  return o
end

M.Config = Config

return M
