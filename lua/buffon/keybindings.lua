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
local keybindings = function()
  return {
    {
      lhs = state.config.keybindings.goto_next_buffer,
      rhs = function()
        actions.next()
      end,
      help = "Go to next buffer",
    },
    {
      lhs = state.config.keybindings.goto_previous_buffer,
      rhs = function()
        actions.previous()
      end,
      help = "Go to previous buffer",
    },
    {
      lhs = state.config.keybindings.move_buffer_up,
      rhs = function()
        actions.buffer_up()
      end,
      help = "Move buffer to up one position",
    },
    {
      lhs = state.config.keybindings.move_buffer_down,
      rhs = function()
        actions.buffer_down()
      end,
      help = "Move buffer to down one position",
    },
    {
      lhs = state.config.keybindings.move_buffer_top,
      rhs = function()
        actions.buffer_top()
      end,
      help = "Move buffer to the top position",
    },
    {
      lhs = state.config.keybindings.toggle_buffon_window,
      rhs = function()
        ui.show()
      end,
      help = "Toggle buffon window",
    },
    {
      lhs = state.config.keybindings.switch_previous_used_buffer,
      rhs = "<cmd>e #<cr>",
      help = "Switch to previous used buffer",
    },
    {
      lhs = state.config.keybindings.close_buffer,
      rhs = function()
        actions.close_buffer()
      end,
      help = "Close current buffer",
    },
    {
      lhs = state.config.keybindings.close_buffers_above,
      rhs = function()
        actions.close_buffers_above()
      end,
      help = "Close buffers above the current one",
    },
    {
      lhs = state.config.keybindings.close_buffers_below,
      rhs = function()
        actions.close_buffers_below()
      end,
      help = "Close buffers below the current one",
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
  for _, keybinding in ipairs(keybindings()) do
    keymap(keybinding.lhs, keybinding.rhs, keybinding.help)
  end

  for i = 1, #state.config.keybindings.buffer_mapping.mapping_chars do
    local char = state.config.keybindings.buffer_mapping.mapping_chars:sub(i, i)
    keymap(";" .. char, function()
      actions.goto_buffer(i)
    end, "Goto to buffer " .. i)
  end
end

return M
