local config = require("buffon.config")

local M = {}

---@class BuffonBuffer
---@field name string
---@field short_name string
---@field filename string
---@field id number

---@class BuffonApiState
---@field index_buffers_by_name table<string, number>
---@field buffers table<BuffonBuffer>
---@field opts BuffonConfig
local state = {
	index_buffers_by_name = {},
	buffers = {},
}

--- This method is called after update buffers_list and generates
--- the buffes_by_name list automatically
local refresh_indexes = function()
	---@type table<string, number>
	local buffers = {}

	for i = 1, #state.buffers do
		---@type BuffonBuffer
		local buffer = state.buffers[i]
		buffers[buffer.name] = i
	end
	state.index_buffers_by_name = buffers
end

---@param list table<BuffonBuffer>
local set_buffers_list = function(list)
	state.buffers = list
	refresh_indexes()
end

---@param name string
---@param id number
---@return nil
M.add_buffer = function(name, id)
	-- [No Name] buffer is ignored
	if name == "" or name == "/" then
		return
	end

	table.insert(state.buffers, {
		id = id,
		name = name,
		short_name = vim.fn.fnamemodify(name, ":."),
		filename = vim.fn.fnamemodify(name, ":t"),
	})
	refresh_indexes()
end

---@return table<string, number>
M.get_index_buffers_by_name = function()
	return state.index_buffers_by_name
end

---@return table<BuffonBuffer>
M.get_buffers_list = function()
	return state.buffers
end

---@param index number
---@return BuffonBuffer | nil
M.get_buffer_by_index = function(index)
	return state.buffers[index]
end

---@param name string
---@return number | nil
M.get_index_by_name = function(name)
	return state.index_buffers_by_name[name]
end

---@param name string
---@return nil
M.delete_buffer = function(name)
	local buffer_index = state.index_buffers_by_name[name]
	if buffer_index == nil then
		return
	end

	table.remove(state.buffers, buffer_index)
	refresh_indexes()
end

---@param list table<BuffonBuffer>
---@param index1 number
---@param index2 number
local swap_buffers = function(list, index1, index2)
	local tmp = list[index1]
	list[index1] = list[index2]
	list[index2] = tmp
end

---@param name string
M.move_buffer_up = function(name)
	---@type number | nil
	local buffer_index = state.index_buffers_by_name[name]
	if buffer_index == nil or buffer_index == 1 then
		return -1
	end
	local new_index = buffer_index - 1
	swap_buffers(state.buffers, buffer_index, new_index)
	refresh_indexes()
	return new_index
end

---@param name string
M.move_buffer_down = function(name)
	---@type number | nil
	local buffer_index = state.index_buffers_by_name[name]
	if buffer_index == nil or buffer_index == #state.buffers then
		return -1
	end
	local new_index = buffer_index + 1
	swap_buffers(state.buffers, buffer_index, new_index)
	refresh_indexes()
	return new_index
end

---@param name string
M.move_buffer_top = function(name)
	---@type number | nil
	local buffer_index = state.index_buffers_by_name[name]
	if buffer_index == nil or buffer_index == 1 then
		return
	end
	local buffer_removed = table.remove(state.buffers, buffer_index)
	table.insert(state.buffers, 1, buffer_removed)
	refresh_indexes()
end

---@param opts BuffonConfig | nil
M.setup = function(opts)
	state.opts = opts or config.opts()
	set_buffers_list({})
end

return M
