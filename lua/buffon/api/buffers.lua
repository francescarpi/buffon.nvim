local utils = require("buffon.utils")
local log = require("buffon.log")
local api_move = require("buffon.api.move")
local api_groups = require("buffon.api.groups")
local api_nav = require("buffon.api.nav")
local api_delete = require("buffon.api.delete")

local M = {}

---@type BuffonBuffersState
local state = {
  -- buffers is the main attribute. All buffers are stored there.
  -- It's multilevel table. First level is the group.
  -- Example with 3 groups: { { buffer1, buffer2 }, { }, { } }
  buffers = {},
  -- the following attribute is useful to know the group and index where is
  -- a specific buffer searching by name
  index_buffers_by_name = {},
  active_group = 1,
}

--- Refreshes the index_buffers_by_name list based on the current buffers list.
--- index_buffers_by_name is a table where key is the buffer name, and value
--- an object with the buffer's index and group
local refresh_indexes = function()
  ---@type table<string, BuffonIndexBuffersByName>
  local buffers_by_name = {}

  for group_index, group in ipairs(state.buffers) do
    for buffer_index, buffer in ipairs(group) do
      buffers_by_name[buffer.name] = {
        index = buffer_index,
        group = group_index,
      }
    end
  end

  state.index_buffers_by_name = buffers_by_name
end

--- Sets the buffers list and refreshes the indexes.
---@param list table<BuffonBuffer> The list of buffers to set.
local set_buffers = function(list)
  state.buffers = list
  refresh_indexes()
end

local initialize_buffers = function()
  local groups = {}
  for _ = 1, state.config.opts.max_groups do
    table.insert(groups, {})
  end
  set_buffers(groups)
end

---@param name string
---@param id number
---@param cursor [number, number]
---@return BuffonBuffer
local buffer_struct = function(name, id, cursor)
  return {
    id = id,
    name = name,
    short_name = vim.fn.fnamemodify(name, ":."),
    filename = vim.fn.fnamemodify(name, ":t"),
    short_path = utils.abbreviate_path(vim.fn.fnamemodify(name, ":.")),
    cursor = cursor,
  }
end

---@param name string The name of the buffer
---@param id number
---@param index_of_active? number
---@return nil
M.add_buffer = function(name, id, index_of_active)
  -- [No Name] buffer is ignored
  if name == "" or name == "/" then
    return
  end

  local buffer_group_index = state.index_buffers_by_name[name]
  if buffer_group_index then
    local existent_buffer = state.buffers[buffer_group_index.group][buffer_group_index.index]
    if existent_buffer.id then
      log.debug("tries to add an existing buffer", name)
      return
    end
    -- it means that there is a buffer in the list, but without buffer id
    -- it only needs to be set
    existent_buffer.id = id
    return
  end

  local buffer = buffer_struct(name, id, { 1, 1 })

  log.debug("add buffer", buffer.name, "with id", buffer.id)

  if not state.buffers[state.active_group] then
    state.buffers[state.active_group] = {}
  end

  if state.config.opts.new_buffer_position == "start" then
    table.insert(state.buffers[state.active_group], 1, buffer)
  elseif state.config.opts.new_buffer_position == "end" then
    table.insert(state.buffers[state.active_group], buffer)
  else
    index_of_active = index_of_active or 0
    table.insert(state.buffers[state.active_group], index_of_active + 1, buffer)
  end

  refresh_indexes()
end

--- Gets the index_buffers_by_name list.
---@return table<string, BuffonIndexBuffersByName>
M.get_index_buffers_by_name = function()
  return state.index_buffers_by_name
end

--- Gets the list of buffers.
---@return table<BuffonBuffer> The list of buffers.
M.get_groups = function()
  return state.buffers
end

---@return table<BuffonBuffer>
M.get_buffers_active_group = function()
  return M.get_buffers_of_group(state.active_group)
end

---@param group number
---@return table<BuffonBuffer>
M.get_buffers_of_group = function(group)
  local buffers = state.buffers[group]
  if not buffers then
    return {}
  end
  return buffers
end

--- Gets a buffer by its index.
---@param group number The index of the buffer.
---@param index number The index of the buffer.
---@return BuffonBuffer | nil The buffer at the specified index, or nil if not found.
M.get_buffer_by_group_and_index = function(group, index)
  return state.buffers[group][index]
end

--- Gets the index of a buffer by its name.
---@param name string The name of the buffer.
---@return BuffonIndexBuffersByName | nil The index of the buffer, or nil if not found.
M.get_index_and_group_by_name = function(name)
  local buffer = state.index_buffers_by_name[name]
  if buffer then
    return buffer
  end
end

---@param current_name string
---@param new_name string
M.rename_buffer = function(current_name, new_name)
  local buffer_group_index = state.index_buffers_by_name[current_name]
  if not buffer_group_index or not buffer_group_index.index then
    log.debug("buffer", current_name, "to rename, does not exist")
    return
  end

  ---@type BuffonBuffer
  local buffer = state.buffers[buffer_group_index.group][buffer_group_index.index]
  state.buffers[buffer_group_index.group][buffer_group_index.index] = buffer_struct(new_name, buffer.id, buffer.cursor)

  refresh_indexes()
  log.debug("buffer", buffer.name, "renamed to", new_name)
end

---@param name string
---@param position [number, number]
M.update_cursor = function(name, position)
  local buffer_group_index = state.index_buffers_by_name[name]
  if not buffer_group_index or not buffer_group_index.index then
    log.debug("buffer", name, "for update position, does not exist")
    return
  end
  state.buffers[buffer_group_index.group][buffer_group_index.index].cursor = position
  log.debug("cursor position of buffer", name, "updated to", position[1], ",", position[2])
end

--- Checks if the structure of the buffers is correct. This method makes sense with the data loaded
--- from the disk, because if some attribute is added in a newer version of the plugin, the stored data
--- might not be compatible.
---@param buffers table<BuffonBuffer>
M.validate_buffers = function(buffers)
  assert(#buffers == state.config.opts.max_groups, "invalid groups length")
  for _, group in ipairs(buffers) do
    for _, buffer in ipairs(group) do
      vim.validate({
        name = { buffer.name, "string" },
        short_path = { buffer.short_path, "string" },
        short_name = { buffer.short_name, "string" },
        filename = { buffer.filename, "string" },
        cursor = { buffer.cursor, "table" },
      })
    end
  end
end

--- Sets up the API state with the provided configuration.
---@param config BuffonConfigState The configuration options.
---@param initial_buffers? table<BuffonBuffer>
M.setup = function(config, initial_buffers)
  state.config = config

  if initial_buffers then
    local success, msg = pcall(M.validate_buffers, initial_buffers)
    if success then
      set_buffers(initial_buffers)
      log.debug("initial buffers is valid")
    else
      initialize_buffers()
      log.debug("initial buffers is not valid", msg)
    end
  else
    initialize_buffers()
  end

  M.move = api_move.setup(state, refresh_indexes)
  M.groups = api_groups.setup(state, refresh_indexes)
  M.nav = api_nav.setup(state)
  M.del = api_delete.setup(state, refresh_indexes)
end

return M
