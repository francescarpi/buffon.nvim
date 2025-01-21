local config = require("buffon.config")

local M = {}

-- TODO Deprecated this class. In the future, it will only has a record<string, number> to map the index. The data (such id and name), is already
-- present within the BuffonBuffer
---@class BuffonBufferNyName
---@field id number
---@field name string
---@field index number

---@class BuffonBuffer
---@field name string
---@field short_name string
---@field shorter_name string
---@field id number

---@class BuffonApiState
---@field buffers_by_name table<string, BuffonBufferNyName>
---@field buffers_list table<BuffonBuffer>
---@field opts BuffonConfig
local state = {
	buffers_by_name = {},
	buffers_list = {},
}

--- This method is called after update buffers_list and generates
--- the buffes_by_name list automatically
local refresh_buffers_by_name = function()
	---@type table<string, BuffonBufferNyName>
	local buffers = {}

	for i = 1, #state.buffers_list do
		---@type BuffonBuffer
		local buffer = state.buffers_list[i]
		buffers[buffer.name] = {
			id = buffer.id,
			name = buffer.name,
			index = i,
		}
	end
	state.buffers_by_name = buffers
end

---@param list table<BuffonBuffer>
local set_buffers_list = function(list)
	state.buffers_list = list
	refresh_buffers_by_name()
end

---@param name string
---@param id number
---@return nil
M.add_buffer = function(name, id)
	-- [No Name] buffer is ignored
	if name == "" or name == "/" then
		return
	end

	table.insert(state.buffers_list, {
		id = id,
		name = name,
		short_name = vim.fn.fnamemodify(name, ":."),
		shorter_name = vim.fn.fnamemodify(name, ":t"),
	})
	refresh_buffers_by_name()
end

---@return table<string, BuffonBufferNyName>
M.get_buffers_by_name = function()
	return state.buffers_by_name
end

---@return table<BuffonBuffer>
M.get_buffers_list = function()
	return state.buffers_list
end

---@param index number
---@return BuffonBuffer | nil
M.get_buffer_by_index = function(index)
	return state.buffers_list[index]
end

---@param name string
---@return BuffonBufferNyName | nil
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

---@param list table<BuffonBuffer>
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
	---@type BuffonBufferNyName | nil
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
	---@type BuffonBufferNyName | nil
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
	---@type BuffonBufferNyName | nil
	local buffer = state.buffers_by_name[name]
	if buffer == nil or buffer.index == 1 then
		return
	end
	local buffer_removed = table.remove(state.buffers_list, buffer.index)
	table.insert(state.buffers_list, 1, buffer_removed)
	refresh_buffers_by_name()
end

---@param opts BuffonConfig | nil
M.setup = function(opts)
	state.opts = opts or config.opts()
	set_buffers_list({})
end

---@param buffers_list table<string>
---@return boolean
M.sort_buffers_by_list = function(buffers_list)
	if #buffers_list ~= #state.buffers_list then
		return false
	end

	local new_list = {}
	for _, buffer_name in ipairs(buffers_list) do
		local buffer = state.buffers_by_name[buffer_name]
		if buffer == nil then
			return false
		end
		table.insert(new_list, { id = buffer.id, name = buffer.name })
	end

	set_buffers_list(new_list)

	return true
end

return M
