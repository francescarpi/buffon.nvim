local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
  it("defaults options", function()
    local cfg = config.setup({})
    eq(cfg.opts, {
      cyclic_navigation = false,
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
    })
  end)

  it("user changes cyclic_navigation and new_buffer_position", function()
    local cfg = config.setup({
      cyclic_navigation = true,
      new_buffer_position = "start",
    })

    eq(cfg.opts, {
      cyclic_navigation = true,
      new_buffer_position = "start",
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
    })
  end)

  it("user changes some keybinding", function()
    local cfg = config.setup({
      keybindings = {
        move_buffer_down = "aa",
        buffer_mapping = {
          leader_key = "<space>",
        },
      },
    })

    eq(cfg.opts, {
      cyclic_navigation = false,
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
        move_buffer_down = "aa",
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
          leader_key = "<space>",
        },
        show_help = ";h",
        previous_group = "<s-tab>",
        next_group = "<tab>",
        move_to_previous_group = ";a",
        move_to_next_group = ";s",
      },
    })
  end)
end)
