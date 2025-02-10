local M = {}

local default = {
  cyclic_navigation = true,
  --- possible values:
  ---   "start": buffers are added at the begginning of the buffers list
  ---   "end": buffers are added at the end of the list
  ---   "after": are added after the active buffer
  new_buffer_position = "after",
  num_pages = 2,
  open = {
    by_default = true,
    ignore_ft = {
      "gitcommit",
      "gitrebase",
    },
  },
  keybindings = {
    goto_next_buffer = "<s-j>",
    goto_previous_buffer = "<s-k>",
    move_buffer_up = "<s-l>",
    move_buffer_down = "<s-h>",
    move_buffer_top = "<s-t>",
    move_buffer_bottom = "<s-b>",
    toggle_buffon_window = ";n",
    switch_previous_used_buffer = ";;",
    close_buffer = ";d",
    close_buffers_above = ";v",
    close_buffers_below = ";b",
    close_all_buffers = ";cc",
    close_others = ";cd",
    reopen_recent_closed_buffer = ";t",
    buffer_mapping = {
      mapping_chars = "qweryuiop",
      leader_key = ";",
    },
    show_help = ";h",
    previous_page = "<s-tab>",
    next_page = "<tab>",
    move_to_previous_page = ";a",
    move_to_next_page = ";s",
  },
}

---@class BuffonConfigKeyBindingBufferMapping
---@field mapping_chars string -- Each character maps to a buffer ("qwer" maps 'q' to buffer 1, 'w' to buffer 2, etc.)
---@field leader_key string -- Leader key used as a prefix for buffer mappings (';' creates mappings ';q', ';w', etc.)

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
---@field buffer_mapping BuffonConfigKeyBindingBufferMapping
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
