local actions = require("buffon.actions")
local ui = require("buffon.ui.main")

local M = {}

---@type BuffonKeybindingsState
local state = {}

--- Returns the list of keybindings based on the current configuration.
---@return table<BuffonKeybinding> The list of keybindings.
M.keybindings = function()
  return {
    {
      lhs = state.config.opts.keybindings.goto_next_buffer,
      rhs = function()
        actions.next()
      end,
      help = "Next buffer",
    },
    {
      lhs = state.config.opts.keybindings.goto_previous_buffer,
      rhs = function()
        actions.previous()
      end,
      help = "Previous buffer",
    },
    {
      lhs = state.config.opts.keybindings.move_buffer_up,
      rhs = function()
        actions.buffer_up()
      end,
      help = "Move buffer up",
    },
    {
      lhs = state.config.opts.keybindings.move_buffer_down,
      rhs = function()
        actions.buffer_down()
      end,
      help = "Move buffer down",
    },
    {
      lhs = state.config.opts.keybindings.move_buffer_top,
      rhs = function()
        actions.buffer_top()
      end,
      help = "Move buffer to top",
    },
    {
      lhs = state.config.opts.keybindings.move_buffer_bottom,
      rhs = function()
        actions.buffer_bottom()
      end,
      help = "Move buffer to bottom",
    },
    {
      lhs = state.config.opts.keybindings.toggle_buffon_window,
      rhs = function()
        ui.toggle()
      end,
      help = "Show/hide buffer list",
    },
    {
      lhs = state.config.opts.keybindings.switch_previous_used_buffer,
      rhs = function()
        actions.last_used()
      end,
      help = "Last used buffer",
    },
    {
      lhs = state.config.opts.keybindings.close_buffer,
      rhs = function()
        actions.close_buffer()
      end,
      help = "Close buffer",
    },
    {
      lhs = state.config.opts.keybindings.close_buffers_above,
      rhs = function()
        actions.close_buffers_above()
      end,
      help = "Close buffers above",
    },
    {
      lhs = state.config.opts.keybindings.close_buffers_below,
      rhs = function()
        actions.close_buffers_below()
      end,
      help = "Close buffers below",
    },
    {
      lhs = state.config.opts.keybindings.close_all_buffers,
      rhs = function()
        actions.close_all_buffers()
      end,
      help = "Close all",
    },
    {
      lhs = state.config.opts.keybindings.close_others,
      rhs = function()
        actions.close_others()
      end,
      help = "Close others",
    },
    {
      lhs = state.config.opts.keybindings.restore_last_closed_buffer,
      rhs = function()
        actions.restore_last_closed_buffer()
      end,
      help = "Restore last tab",
    },
    {
      lhs = state.config.opts.keybindings.next_group,
      rhs = function()
        actions.next_group()
      end,
      help = "Next group",
    },
    {
      lhs = state.config.opts.keybindings.previous_group,
      rhs = function()
        actions.previous_group()
      end,
      help = "Previous group",
    },
    {
      lhs = state.config.opts.keybindings.move_to_next_group,
      rhs = function()
        actions.move_to_next_group()
      end,
      help = "Move to next group",
    },
    {
      lhs = state.config.opts.keybindings.move_to_previous_group,
      rhs = function()
        actions.move_to_previous_group()
      end,
      help = "Move to prvious group",
    },
  }
end

--- Sets a keymap with the given parameters.
---@param lhs string The left-hand side of the keymap.
---@param rhs function | string The right-hand side of the keymap.
---@param help string The description of the keymap.
local keymap = function(lhs, rhs, help)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = "Buffon: " .. help })
end

--- Registers all the keybindings based on the current configuration.
local register = function()
  for _, keybinding in ipairs(M.keybindings()) do
    keymap(keybinding.lhs, keybinding.rhs, keybinding.help)
  end

  for i = 1, #state.config.opts.keybindings.buffer_mapping.mapping_chars do
    local char = state.config.opts.keybindings.buffer_mapping.mapping_chars:sub(i, i)
    keymap(";" .. char, function()
      actions.goto_buffer(i)
    end, "Goto to buffer " .. i)
  end

  keymap(state.config.opts.keybindings.show_help, function()
    local help = require("buffon.ui.help")
    help.toggle()
  end, "Show help")
end

--- Sets up the keybindings state with the provided configuration.
---@param config BuffonConfigState The configuration options.
M.setup = function(config)
  state.config = config
  register()
end

return M
