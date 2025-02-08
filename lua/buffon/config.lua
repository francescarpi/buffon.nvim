local M = {}

---@type BuffonConfig
local default = {
  cyclic_navigation = false,
  --- possible values:
  ---   "start": buffers are added at the begginning of the buffers list
  ---   "end": buffers are added at the end of the list
  ---   "after": are added after the active buffer
  new_buffer_position = "end",
  max_groups = 3,
  open = {
    by_default = false,
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
    restore_last_closed_buffer = ";t",
    buffer_mapping = {
      mapping_chars = "qweryuiop",
      leader_key = ";",
    },
    show_help = ";h",
    previous_group = "<s-tab>",
    next_group = "<tab>",
    move_to_previous_group = ";a",
    move_to_next_group = ";s",
  },
}

---@type BuffonConfigState
local state = {
  opts = default,
}

M.setup = function(opts)
  state.opts = vim.tbl_deep_extend("force", default, opts or {})
  M.opts = state.opts
  return M
end

M.opts = state.opts

return M
