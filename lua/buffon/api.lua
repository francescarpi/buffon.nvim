local config = require("buffon.config")
local utils = require("buffon.utils")
local log = require("buffon.log")

local M = {}

---@type BuffonApiState
local state = {
  index_buffers_by_name = {},
  buffers = {},
  are_duplicated_filenames = false,
}

--- Refreshes the index_buffers_by_name list based on the current buffers list.
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

--- Check if buffers list have repeated filenames and update the are_duplicated_filenames state flag
---@return nil
local check_duplicated_filenames = function()
  local filenames = {}
  state.are_duplicated_filenames = false

  for _, buffer in ipairs(state.buffers) do
    if filenames[buffer.filename] then
      state.are_duplicated_filenames = true
      return
    end
    filenames[buffer.filename] = true
  end
end

--- Sets the buffers list and refreshes the indexes.
---@param list table<BuffonBuffer> The list of buffers to set.
local set_buffers = function(list)
  state.buffers = list
  refresh_indexes()
  check_duplicated_filenames()
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

--- Moves a buffer to the top of the list.
---@param name string The name of the buffer to move to the top.
---@param id number
---@return nil
M.add_buffer = function(name, id)
  -- [No Name] buffer is ignored
  if name == "" or name == "/" then
    return
  end

  local existent_buffer_index = state.index_buffers_by_name[name]
  if existent_buffer_index then
    local existent_buffer = state.buffers[existent_buffer_index]
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

  if state.config.prepend_buffers then
    table.insert(state.buffers, 1, buffer)
  else
    table.insert(state.buffers, buffer)
  end

  check_duplicated_filenames()
  refresh_indexes()
end

--- Gets the index_buffers_by_name list.
---@return table<string, number> The index_buffers_by_name list.
M.get_index_buffers_by_name = function()
  return state.index_buffers_by_name
end

--- Gets the list of buffers.
---@return table<BuffonBuffer> The list of buffers.
M.get_buffers = function()
  return state.buffers
end

--- Gets a buffer by its index.
---@param index number The index of the buffer.
---@return BuffonBuffer | nil The buffer at the specified index, or nil if not found.
M.get_buffer_by_index = function(index)
  return state.buffers[index]
end

--- Gets the index of a buffer by its name.
---@param name string The name of the buffer.
---@return number | nil The index of the buffer, or nil if not found.
M.get_index_by_name = function(name)
  return state.index_buffers_by_name[name]
end

--- Deletes a buffer by its name.
---@param name string The name of the buffer to delete.
---@return nil
M.delete_buffer = function(name)
  local buffer_index = state.index_buffers_by_name[name]
  if buffer_index == nil then
    return
  end

  log.debug("close buffer", name)
  table.remove(state.buffers, buffer_index)

  check_duplicated_filenames()
  refresh_indexes()
end

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
  local buffer_index = state.index_buffers_by_name[name]
  if not buffer_index or validation(buffer_index) then
    return -1
  end
  local new_index = callback(buffer_index)

  refresh_indexes()

  return new_index
end

---@param name string
---@return number
M.move_buffer_up = function(name)
  return move_buffer(name, function(index)
    return index == 1
  end, function(index)
    return swap_buffers(state.buffers, index, index - 1)
  end)
end

---@param name string
---@return number
M.move_buffer_down = function(name)
  return move_buffer(name, function(index)
    return index == #state.buffers
  end, function(index)
    return swap_buffers(state.buffers, index, index + 1)
  end)
end

---@param name string
---@return number
M.move_buffer_top = function(name)
  return move_buffer(name, function(index)
    return index == 1
  end, function(index)
    table.insert(state.buffers, 1, table.remove(state.buffers, index))
    return 1
  end)
end

---@param name string
---@return number
M.move_buffer_bottom = function(name)
  return move_buffer(name, function(index)
    return index == #state.buffers
  end, function(index)
    table.insert(state.buffers, table.remove(state.buffers, index))
    return #state.buffers
  end)
end

---@return boolean
M.are_duplicated_filenames = function()
  return state.are_duplicated_filenames
end

---@param name string
---@param operation number
---@param fallback number
---@return BuffonBuffer?
local get_next_or_previous_buffer = function(name, operation, fallback)
  local buffer_index = state.index_buffers_by_name[name]
  if not buffer_index then
    return nil
  end

  local buffer = state.buffers[buffer_index + (1 * operation)]
  if not buffer and state.config.cyclic_navigation then
    buffer = state.buffers[fallback]
  end

  return buffer
end

---@param name string
---@return BuffonBuffer?
M.get_next_buffer = function(name)
  return get_next_or_previous_buffer(name, 1, 1)
end

---@param name string
---@return BuffonBuffer?
M.get_previous_buffer = function(name)
  return get_next_or_previous_buffer(name, -1, #state.buffers)
end

---@param name string
---@param from_callback function
---@param to_callback function
---@return table<BuffonBuffer>
local get_buffers_above_below = function(name, from_callback, to_callback)
  local buffer_index = state.index_buffers_by_name[name]
  if not buffer_index then
    return {}
  end

  local response = {}
  local for_from = from_callback(buffer_index)
  local for_to = to_callback(buffer_index)

  for i = for_from, for_to do
    table.insert(response, state.buffers[i])
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
    return #state.buffers
  end)
end

---@param current_name string
---@param new_name string
M.rename_buffer = function(current_name, new_name)
  local buffer_index = state.index_buffers_by_name[current_name]
  if not buffer_index then
    log.debug("buffer", current_name, "to rename, does not exist")
    return
  end
  local buffer = state.buffers[buffer_index]
  state.buffers[buffer_index] = buffer_struct(new_name, buffer.id, buffer.cursor)
  refresh_indexes()
  log.debug("buffer", buffer.name, "renamed to", new_name)
end

---@param name string
---@param position [number, number]
M.update_cursor = function(name, position)
  local buffer_index = state.index_buffers_by_name[name]
  if not buffer_index then
    log.debug("buffer", name, "for update position, does not exist")
    return
  end
  state.buffers[buffer_index].cursor = position
  log.debug("cursor position of buffer", name, "updated to", position[1], ",", position[2])
end

--- Sets up the API state with the provided configuration.
---@param opts? BuffonConfig The configuration options.
---@param initial_buffers? table<BuffonBuffer>
M.setup = function(opts, initial_buffers)
  state.config = opts or config.opts()
  set_buffers(initial_buffers or {})
end

return M
