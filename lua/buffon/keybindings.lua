local actions = require("buffon.actions")

local M = {}

---@class State
---@field leader_key string
local state = {
	leader_key = ";",
}

---@param lhs string
---@param rhs function | string
---@param help string
local keymap = function(lhs, rhs, help)
	vim.keymap.set("n", state.leader_key .. lhs, rhs, { silent = true, desc = "Buffon: " .. help })
end

---@param leader_key string
---@param buffer_mappings_chars string
M.register = function(leader_key, buffer_mappings_chars)
	state.leader_key = leader_key

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

	keymap("m", "<cmd>e #<cr>", "Move buffer to top position")

	keymap("d", "<cmd>bdelete<cr>", "Move buffer to top position")

	for i = 1, #buffer_mappings_chars do
		local char = buffer_mappings_chars:sub(i, i)
		keymap(char, function()
			actions.goto(i)
		end, 'Goto to buffer ' .. i)
	end
end

return M
