local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
  it("default", function()
    local cfg = config.Config:new()
    eq(cfg, {
      cyclic_navigation = true,
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
    })
  end)

  it("if num_pages is invalid, set default to 1", function()
    local cfg = config.Config:new({ num_pages = 0 })
    eq(cfg.num_pages, 1)

    -- limot of num_pages is 4
    local cfg2 = config.Config:new({ num_pages = 5 })
    eq(cfg2.num_pages, 1)
  end)
end)
