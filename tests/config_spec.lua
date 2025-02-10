local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
  it("default", function()
    local cfg = config.Config:new()
    eq(cfg, {
      cyclic_navigation = true,
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
    })
  end)
end)
