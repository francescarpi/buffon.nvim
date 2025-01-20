local config = require("buffon.config")

local M = {}

---@class BufferByName
---@field id number
---@field name string
---@field index number

---@class BuffersList
---@field name string
---@field id number

---@class ApiState
---@field buffers_by_name table<string, BufferByName>
---@field buffers_list table<BuffersList>
---@field opts PluginConfig
local state = {
	buffers_by_name = {},
	buffers_list = {},
}

--- This method is called after update buffers_list and generates
--- the buffes_by_name list automatically
local refresh_buffers_by_name = function()
	---@type table<string, BufferByName>
	local buffers = {}

	for i = 1, #state.buffers_list do
		---@type BuffersList
		local buffer = state.buffers_list[i]
		buffers[buffer.name] = {
			id = buffer.id,
			name = buffer.name,
			index = i,
		}
	end
	state.buffers_by_name = buffers
end

---@param name string
---@param id number
---@return nil
M.add_buffer = function(name, id)
	-- [No Name] buffer is ignored
	if name == "" then
		return
	end

	table.insert(state.buffers_list, { id = id, name = name })
	refresh_buffers_by_name()
end

---@return table<string, BufferByName>
M.get_buffers_by_name = function()
	return state.buffers_by_name
end

---@return table<BuffersList>
M.get_buffers_list = function()
	return state.buffers_list
end

---@param index number
---@return BuffersList | nil
M.get_buffer_by_index = function(index)
	return state.buffers_list[index]
end

---@param name string
---@return BufferByName | nil
M.get_buffer_by_name = function(name)
	return state.buffers_by_name[name]
end

---@param name string
---@return nil
M.delete_buffer = function(name)
	local buffer = state.buffers_by_name[name]
	if buffer == nil then
		return
	end

	table.remove(state.buffers_list, buffer.index)
	refresh_buffers_by_name()
end

---@param list table<BuffersList>
---@param index1 number
---@param index2 number
local swap_buffers = function(list, index1, index2)
	local tmp = list[index1]
	list[index1] = list[index2]
	list[index2] = tmp
end

---@param name string
---@return number new index
M.move_buffer_up = function(name)
	---@type BufferByName | nil
	local buffer = state.buffers_by_name[name]
	if buffer == nil or buffer.index == 1 then
		return -1
	end
	local new_index = buffer.index - 1
	swap_buffers(state.buffers_list, buffer.index, new_index)
	refresh_buffers_by_name()
	return new_index
end

---@param name string
---@return number target position
M.move_buffer_down = function(name)
	---@type BufferByName | nil
	local buffer = state.buffers_by_name[name]
	if buffer == nil or buffer.index == #state.buffers_list then
		return -1
	end
	local new_index = buffer.index + 1
	swap_buffers(state.buffers_list, buffer.index, new_index)
	refresh_buffers_by_name()
	return new_index
end

---@param name string
M.move_buffer_top = function(name)
	---@type BufferByName | nil
	local buffer = state.buffers_by_name[name]
	if buffer == nil or buffer.index == 1 then
		return
	end
	local buffer_removed = table.remove(state.buffers_list, buffer.index)
	table.insert(state.buffers_list, 1, buffer_removed)
	refresh_buffers_by_name()
end

---@param opts PluginConfig | nil
M.setup = function(opts)
	state.opts = opts or config.opts()
end

return M
