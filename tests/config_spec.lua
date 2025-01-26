local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
  it("defaults options", function()
    local cfg = config.setup({})
    eq(cfg.opts, {
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
    })
  end)

  it("user changes cyclic_navigation and prepend_buffers", function()
    local cfg = config.setup({
      cyclic_navigation = true,
      prepend_buffers = true,
    })

    eq(cfg.opts, {
      cyclic_navigation = true,
      prepend_buffers = true,
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
      prepend_buffers = false,
      open = {
        by_default = false,
        ignore_ft = { "gitcommit" },
      },
      keybindings = {
        goto_next_buffer = "<s-j>",
        goto_previous_buffer = "<s-k>",
        move_buffer_up = "<s-l>",
        move_buffer_down = "aa",
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
          leader_key = "<space>",
        },
        show_help = ";h",
      },
    })
  end)
end)
