local actions = require("buffon.actions")
local ui = require("buffon.ui")

local M = {}

---@class BuffonKeybinding
---@field lhs string
---@field rhs function | string
---@field help string

---@type table<BuffonKeybinding>
local keybindings = {
	{
		lhs = "<s-j>",
		rhs = function() actions.next() end,
		help = "Go to next buffer"
	},
	{
		lhs = "<s-k>",
		rhs = function() actions.previous() end,
		help = "Go to previous buffer"
	},
	{
		lhs = "<s-h>",
		rhs = function() actions.buffer_up() end,
		help = "Move buffer to up one position"
	},
	{
		lhs = "<s-l>",
		rhs = function() actions.buffer_down() end,
		help = "Move buffer to down one position"
	},
	{
		lhs = "<s-t>",
		rhs = function() actions.buffer_top() end,
		help = "Move buffer to the top position"
	},
	{
		lhs = ";a",
		rhs = function() ui.show() end,
		help = "Toggle opened buffers window visibility"
	},
	{
		lhs = ";;",
		rhs = "<cmd>e #<cr>",
		help = "Switch to previous used buffer"
	},
	{
		lhs = ";d",
		rhs = "<cmd>bdelete<cr>",
		help = "Delete current buffer"
	}
}

---@class BuffonKeybindingsState
---@field config BuffonConfig
local state = {}

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
	for _, keybinding in ipairs(keybindings) do
		keymap(keybinding.lhs, keybinding.rhs, keybinding.help)
	end

	for i = 1, #state.config.buffer_mappings_chars do
		local char = state.config.buffer_mappings_chars:sub(i, i)
		keymap(";" .. char, function()
			actions.goto(i)
		end, 'Goto to buffer ' .. i)
	end
end

return M
