local M = {}

local state

---@param name string
---@param operation number
---@param fallback string
---@return BuffonBuffer?
local get_next_or_previous_buffer = function(name, operation, fallback)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index or not buffer_group_index.index then
    return nil
  end

  local next_or_previous = state.buffers[buffer_group_index.group][buffer_group_index.index + (1 * operation)]

  if not next_or_previous and state.config.opts.cyclic_navigation then
    if fallback == "first" then
      next_or_previous = state.buffers[buffer_group_index.group][1]
    else
      next_or_previous = state.buffers[buffer_group_index.group][#state.buffers[buffer_group_index.group]]
    end
  end

  return next_or_previous
end

---@param name string
---@return BuffonBuffer?
M.get_next_buffer = function(name)
  return get_next_or_previous_buffer(name, 1, "first")
end

---@param name string
---@return BuffonBuffer?
M.get_previous_buffer = function(name)
  return get_next_or_previous_buffer(name, -1, "last")
end

M.setup = function(buffers_state)
  state = buffers_state
  return M
end

return M
