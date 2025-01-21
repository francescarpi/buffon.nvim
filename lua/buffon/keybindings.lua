local actions = require("buffon.actions")
local ui = require("buffon.ui")

local M = {}

---@class BuffonKeybindingsState
---@field config BuffonConfig
local state = {}

---@param lhs string
---@param rhs function | string
---@param help string
local keymap = function(lhs, rhs, help)
	vim.keymap.set("n", state.config.leader_key .. lhs, rhs, { silent = true, desc = "Buffon: " .. help })
end

---@param opts BuffonConfig
M.setup = function(opts)
	state.config = opts
end

M.register = function()
	keymap("l", function()
		actions.next()
	end, "Next buffer")

	keymap("h", function()
		actions.previous()
	end, "Previous buffer")

	keymap("k", function()
		actions.buffer_up()
	end, "Move buffer to up")

	keymap("j", function()
		actions.buffer_down()
	end, "Move buffer to down")

	keymap("t", function()
		actions.buffer_top()
	end, "Move buffer to top position")

	keymap(";", function()
		ui.show()
	end, "Toggle info window")

	keymap("a", "<cmd>e #<cr>", "Switch to previous used buffer")

	keymap("d", "<cmd>bdelete<cr>", "Delete current buffer")

	for i = 1, #state.config.buffer_mappings_chars do
		local char = state.config.buffer_mappings_chars:sub(i, i)
		keymap(char, function()
			actions.goto(i)
		end, 'Goto to buffer ' .. i)
	end
end

return M
