local M = {}

local state
local refresh_indexes

---@return number
M.get_active_group = function()
  return state.active_group
end

M.next_group = function()
  local next_group = state.active_group + 1
  if next_group > state.config.opts.max_groups then
    next_group = 1
  end
  state.active_group = next_group
end

M.previous_group = function()
  local previous_group = state.active_group - 1
  if previous_group < 1 then
    previous_group = state.config.opts.max_groups
  end
  state.active_group = previous_group
end

---@param group number
M.activate_group = function(group)
  state.active_group = group
end

---@param name string
---@param operation number
---@param set_default function
---@return number
local move_to_next_prev_group = function(name, operation, set_default)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index then
    return 1
  end

  local next_or_previous = buffer_group_index.group + (1 * operation)
  if next_or_previous < 1 or next_or_previous > state.config.opts.max_groups then
    next_or_previous = set_default()
  end

  local buffer = state.buffers[buffer_group_index.group][buffer_group_index.index]
  table.remove(state.buffers[buffer_group_index.group], buffer_group_index.index)

  -- if group is not present, we have to initialize
  if state.buffers[next_or_previous] == nil then
    state.buffers[next_or_previous] = {}
  end
  table.insert(state.buffers[next_or_previous], buffer)

  refresh_indexes()
  return next_or_previous
end

---@param name string
---@return number
M.move_to_next_group = function(name)
  return move_to_next_prev_group(name, 1, function()
    return 1
  end)
end

---@param name string
---@return number
M.move_to_previous_group = function(name)
  return move_to_next_prev_group(name, -1, function()
    return state.config.opts.max_groups
  end)
end

M.setup = function(buffers_state, buffers_refresh_indexes)
  state = buffers_state
  refresh_indexes = buffers_refresh_indexes
  return M
end

return M
