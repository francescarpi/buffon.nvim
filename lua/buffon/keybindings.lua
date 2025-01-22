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

---@return table<BuffonKeybinding>
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
            rhs = "<cmd>bdelete<cr>",
            help = "Delete current buffer",
        },
    }
end

---@param lhs string
---@param rhs function | string
---@param help string
local keymap = function(lhs, rhs, help)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = "Buffon: " .. help })
end

---@param opts BuffonConfig
M.setup = function(opts)
    state.config = opts
end

M.register = function()
    for _, keybinding in ipairs(keybindings()) do
        keymap(keybinding.lhs, keybinding.rhs, keybinding.help)
    end

    for i = 1, #state.config.keybindings.buffer_mapping.mapping_chars do
        local char = state.config.keybindings.buffer_mapping.mapping_chars:sub(i, i)
        keymap(";" .. char, function()
            actions.goto_bufer(i)
        end, "Goto to buffer " .. i)
    end
end

return M
