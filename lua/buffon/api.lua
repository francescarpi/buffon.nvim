local config = require("buffon.config")

local M = {}

---@class BufferByName
---@field id number
---@field name string
---@field order number

---@class BufferByOrder
---@field name string
---@field id number

---@class ApiState
---@field buffers_by_name table<string, BufferByName>
---@field buffers_counter number
---@field buffers_by_order table<string, BufferByOrder>
---@field opts PluginConfig
local state = {
	buffers_counter = 0,
	buffers_by_name = {},
	buffers_by_order = {},
}

---@param original_obj BufferByOrder
---@param original_order number
---@param target_obj BufferByOrder
---@param target_order number
local swap_buffers = function(original_obj, original_order, target_obj, target_order)
	state.buffers_by_order[tostring(target_order)] = original_obj
	state.buffers_by_order[tostring(original_order)] = target_obj
	state.buffers_by_name[original_obj.name].order = target_order
	state.buffers_by_name[target_obj.name].order = original_order
end

---@param buf_name string
---@param buf_id number
---@return nil
M.add_buffer = function(buf_name, buf_id)
	-- [No Name] buffer is ignored
	if buf_name == "" then
		return
	end

	state.buffers_by_name[buf_name] = {
		id = buf_id,
		name = buf_name,
		order = state.buffers_counter,
	}

	state.buffers_by_order[tostring(state.buffers_counter)] = {
		id = buf_id,
		name = buf_name,
	}

	state.buffers_counter = state.buffers_counter + 1
end

---@return table<string, BufferByName>
M.get_buffers_by_name = function()
	return state.buffers_by_name
end

---@return table<string, BufferByOrder>
M.get_buffers_by_order = function()
	return state.buffers_by_order
end

---@param order number
---@return BufferByOrder | nil
M.get_buffer_by_order = function(order)
	return state.buffers_by_order[tostring(order)]
end

---@param name string
---@return BufferByName | nil
M.get_buffer_by_name = function(name)
	return state.buffers_by_name[name]
end

---@param name string
---@return nil
M.delete_buffer = function(name)
	if state.buffers_by_name[name] == nil then
		return
	end

	state.buffers_by_order[tostring(state.buffers_by_name[name].order)] = nill
	state.buffers_by_name[name] = nil
	state.buffers_counter = state.buffers_counter - 1

	for i = 0, state.buffers_counter - 1 do
		if state.buffers_by_order[tostring(i)] == nil then
			state.buffers_by_order[tostring(i)] = state.buffers_by_order[tostring(i + 1)]
			state.buffers_by_name[state.buffers_by_order[tostring(i)].name].order = i
		end
	end

	if state.buffers_by_order[tostring(state.buffers_counter)] then
		state.buffers_by_order[tostring(state.buffers_counter)] = nil
	end
end

---@return number
M.buffers_counter = function()
	return state.buffers_counter
end

---@param name string
---@return number target position
M.move_buffer_up = function(name)
	---@type BufferByName | nil
	local buffer_to_move = state.buffers_by_name[name]
	if buffer_to_move == nil then
		return -1
	end

	---@type BufferByOrder | nil
	local buffer_above = state.buffers_by_order[tostring(buffer_to_move.order - 1)]
	if buffer_above == nil then
		return -1
	end

	local buffer_to_move_original_order = buffer_to_move.order
	local buffer_to_move_original = state.buffers_by_order[tostring(buffer_to_move_original_order)]

	local buffer_to_move_target_order = buffer_to_move.order - 1
	local buffer_to_move_target = state.buffers_by_order[tostring(buffer_to_move_target_order)]

	swap_buffers(
		buffer_to_move_original,
		buffer_to_move_original_order,
		buffer_to_move_target,
		buffer_to_move_target_order
	)

	return buffer_to_move_target_order
end

---@param name string
---@return number target position
M.move_buffer_down = function(name)
	---@type BufferByName | nil
	local buffer_to_move = state.buffers_by_name[name]
	if buffer_to_move == nil then
		return -1
	end

	---@type BufferByOrder | nil
	local buffer_below = state.buffers_by_order[tostring(buffer_to_move.order + 1)]
	if buffer_below == nil then
		return -1
	end

	local buffer_to_move_original_order = buffer_to_move.order
	local buffer_to_move_original = state.buffers_by_order[tostring(buffer_to_move_original_order)]

	local buffer_to_move_target_order = buffer_to_move.order + 1
	local buffer_to_move_target = state.buffers_by_order[tostring(buffer_to_move_target_order)]

	swap_buffers(
		buffer_to_move_original,
		buffer_to_move_original_order,
		buffer_to_move_target,
		buffer_to_move_target_order
	)

	return buffer_to_move_target_order
end

---@param name string
M.move_buffer_top = function(name)
	---@type BufferByName | nil
	local buffer_to_move = state.buffers_by_name[name]
	if buffer_to_move == nil then
		return
	end

	if buffer_to_move.order == 0 then
		return
	end

	local buffer_to_move_order = state.buffers_by_order[tostring(buffer_to_move.order)]

	local new = {}
	for i = 1, state.buffers_counter - 1 do
		new[tostring(i)] = state.buffers_by_order[tostring(i - 1)]
	end
	new["0"] = buffer_to_move_order
	state.buffers_by_order = new

	for i = 0, state.buffers_counter - 1 do
		state.buffers_by_name[state.buffers_by_order[tostring(i)].name].order = i
	end
end

---@param opts PluginConfig | nil
M.setup = function(opts)
	state.opts = opts or config.opts()
end

return M
