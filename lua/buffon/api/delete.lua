local log = require("buffon.log")

local M = {}

local state
local refresh_indexes

--- Deletes a buffer by its name.
---@param name string The name of the buffer to delete.
---@return nil
M.delete_buffer = function(name)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index or not buffer_group_index.index then
    return
  end

  log.debug("close buffer", name)
  table.remove(state.buffers[buffer_group_index.group], buffer_group_index.index)

  refresh_indexes()
end

---@param name string
---@param from_callback function
---@param to_callback function
---@return table<BuffonBuffer>
local get_buffers_above_below = function(name, from_callback, to_callback)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index or not buffer_group_index.index then
    return {}
  end

  local response = {}
  local start_index = from_callback(buffer_group_index.index)
  local end_index = to_callback(buffer_group_index.index)

  for i = start_index, end_index do
    table.insert(response, state.buffers[buffer_group_index.group][i])
  end

  return response
end

---@param name string
---@return table<BuffonBuffer>
M.get_buffers_above = function(name)
  return get_buffers_above_below(name, function(_)
    return 1
  end, function(index)
    return index - 1
  end)
end

---@param name string
---@return table<BuffonBuffer>
M.get_buffers_below = function(name)
  return get_buffers_above_below(name, function(index)
    return index + 1
  end, function(_)
    return #state.buffers[state.active_group]
  end)
end

M.setup = function(buffers_state, buffers_refresh_indexes)
  state = buffers_state
  refresh_indexes = buffers_refresh_indexes
  return M
end

return M
