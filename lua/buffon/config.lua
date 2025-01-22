local M = {}

---@class BuffonConfigKeyBindingBufferMapping
---@field mapping_chars string -- Each character maps to a buffer ("qwer" maps 'q' to buffer 1, 'w' to buffer 2, etc.)
---@field leader_key string -- Leader key used as a prefix for buffer mappings (';' creates mappings ';q', ';w', etc.)

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
---@field buffer_mapping BuffonConfigKeyBindingBufferMapping

---@class BuffonConfig
---@field cyclic_navigation boolean -- If true, navigation between buffers will wrap around (cyclic navigation).
---@field prepend_buffers boolean -- If true, new buffers are added at the first position, shifting existing buffers.
---@field keybindings BuffonConfigKeyBinding

---@type BuffonConfig
local default = {
  cyclic_navigation = false,
  prepend_buffers = false,
  keybindings = {
    goto_next_buffer = "<s-j>",
    goto_previous_buffer = "<s-k>",
    move_buffer_up = "<s-l>",
    move_buffer_down = "<s-h>",
    move_buffer_top = "<s-t>",
    toggle_buffon_window = ";a",
    switch_previous_used_buffer = ";;",
    close_buffer = ";d",
    close_buffers_above = ";v",
    close_buffers_below = ";b",
    buffer_mapping = {
      mapping_chars = "qwer",
      leader_key = ";",
    },
  },
}

---@type BuffonConfig
local plugin_config = default

---@return BuffonConfig
M.opts = function()
  return plugin_config
end

M.setup = function(opts)
  opts = opts or {}
  plugin_config = vim.tbl_deep_extend("force", default, opts)
end

return M
