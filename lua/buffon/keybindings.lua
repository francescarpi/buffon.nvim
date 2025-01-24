local actions = require("buffon.actions")
local ui = require("buffon.ui")

local M = {}

---@class BuffonKeybindingsState
---@field config BuffonConfig
local state = {}

---@class BuffonKeybinding
---@field lhs string
---@field rhs function | string
---@field help string

--- Returns the list of keybindings based on the current configuration.
---@return table<BuffonKeybinding> The list of keybindings.
M.keybindings = function()
  return {
    {
      lhs = state.config.keybindings.goto_next_buffer,
      rhs = function()
        actions.next()
      end,
      help = "Next buffer",
    },
    {
      lhs = state.config.keybindings.goto_previous_buffer,
      rhs = function()
        actions.previous()
      end,
      help = "Previous buffer",
    },
    {
      lhs = state.config.keybindings.move_buffer_up,
      rhs = function()
        actions.buffer_up()
      end,
      help = "Move buffer up",
    },
    {
      lhs = state.config.keybindings.move_buffer_down,
      rhs = function()
        actions.buffer_down()
      end,
      help = "Move buffer down",
    },
    {
      lhs = state.config.keybindings.move_buffer_top,
      rhs = function()
        actions.buffer_top()
      end,
      help = "Move buffer to top",
    },
    {
      lhs = state.config.keybindings.toggle_buffon_window,
      rhs = function()
        if not ui.is_open() then
          ui.show()
        else
          ui.hide()
        end
      end,
      help = "Show/hide buffer list",
    },
    {
      lhs = state.config.keybindings.switch_previous_used_buffer,
      rhs = "<cmd>e #<cr>",
      help = "Last used buffer",
    },
    {
      lhs = state.config.keybindings.close_buffer,
      rhs = function()
        actions.close_buffer()
      end,
      help = "Close buffer",
    },
    {
      lhs = state.config.keybindings.close_buffers_above,
      rhs = function()
        actions.close_buffers_above()
      end,
      help = "Close buffers above",
    },
    {
      lhs = state.config.keybindings.close_buffers_below,
      rhs = function()
        actions.close_buffers_below()
      end,
      help = "Close buffers below",
    },
    {
      lhs = state.config.keybindings.close_all_buffers,
      rhs = function()
        actions.close_all_buffers()
      end,
      help = "Close all",
    },
    {
      lhs = state.config.keybindings.close_others,
      rhs = function()
        actions.close_others()
      end,
      help = "Close others",
    },
    {
      lhs = state.config.keybindings.restore_last_closed_buffer,
      rhs = function()
        actions.restore_last_closed_buffer()
      end,
      help = "Restore last tab",
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

--- Sets up the keybindings state with the provided configuration.
---@param opts BuffonConfig The configuration options.
M.setup = function(opts)
  state.config = opts
end

--- Registers all the keybindings based on the current configuration.
M.register = function()
  for _, keybinding in ipairs(M.keybindings()) do
    keymap(keybinding.lhs, keybinding.rhs, keybinding.help)
  end

  for i = 1, #state.config.keybindings.buffer_mapping.mapping_chars do
    local char = state.config.keybindings.buffer_mapping.mapping_chars:sub(i, i)
    keymap(";" .. char, function()
      actions.goto_buffer(i)
    end, "Goto to buffer " .. i)
  end

  keymap(state.config.keybindings.show_help, function()
    local help = require("buffon.ui.help")
    if not help.is_open() then
      help.show()
    else
      help.close()
    end
  end, "Show help")
end

return M
