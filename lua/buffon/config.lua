local M = {}

---@type BuffonConfig
local default = {
  cyclic_navigation = false,
  prepend_buffers = false,
  open = {
    by_default = false,
    ignore_ft = { "gitcommit" },
  },
  keybindings = {
    goto_next_buffer = "<s-j>",
    goto_previous_buffer = "<s-k>",
    move_buffer_up = "<s-l>",
    move_buffer_down = "<s-h>",
    move_buffer_top = "<s-t>",
    move_buffer_bottom = "<s-b>",
    toggle_buffon_window = ";a",
    switch_previous_used_buffer = ";;",
    close_buffer = ";d",
    close_buffers_above = ";v",
    close_buffers_below = ";b",
    close_all_buffers = ";cc",
    close_others = ";cd",
    restore_last_closed_buffer = ";t",
    buffer_mapping = {
      mapping_chars = "qweryuiop",
      leader_key = ";",
    },
    show_help = ";h",
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
