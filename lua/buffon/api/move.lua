local M = {}

local state
local refresh_indexes

--- Swaps two buffers in the list.
---@param list table<BuffonBuffer> The list of buffers.
---@param index1 number The index of the first buffer.
---@param index2 number The index of the second buffer.
---@return number
local swap_buffers = function(list, index1, index2)
  local tmp = list[index1]
  list[index1] = list[index2]
  list[index2] = tmp
  return index2
end

---@param name string
---@param validation function
---@param callback function
---@return number
local move_buffer = function(name, validation, callback)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index or not buffer_group_index.index or validation(buffer_group_index.index) then
    return -1
  end
  local new_index = callback(buffer_group_index.index)

  refresh_indexes()

  return new_index
end

---@param name string
---@return number
M.move_buffer_up = function(name)
  return move_buffer(name, function(index)
    return index == 1
  end, function(index)
    return swap_buffers(state.buffers[state.active_group], index, index - 1)
  end)
end

---@param name string
---@return number
M.move_buffer_down = function(name)
  return move_buffer(name, function(index)
    return index == #state.buffers[state.active_group]
  end, function(index)
    return swap_buffers(state.buffers[state.active_group], index, index + 1)
  end)
end

---@param name string
---@return number
M.move_buffer_top = function(name)
  return move_buffer(name, function(index)
    return index == 1
  end, function(index)
    table.insert(state.buffers[state.active_group], 1, table.remove(state.buffers[state.active_group], index))
    return 1
  end)
end

---@param name string
---@return number
M.move_buffer_bottom = function(name)
  return move_buffer(name, function(index)
    return index == #state.buffers[state.active_group]
  end, function(index)
    table.insert(state.buffers[state.active_group], table.remove(state.buffers[state.active_group], index))
    return #state.buffers[state.active_group]
  end)
end

M.setup = function(buffers_state, buffers_refresh_indexes)
  state = buffers_state
  refresh_indexes = buffers_refresh_indexes
  return M
end

return M
