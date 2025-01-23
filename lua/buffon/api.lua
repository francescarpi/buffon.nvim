local config = require("buffon.config")
local utils = require("buffon.utils")

local M = {}

---@class BuffonBuffer
---@field id number
---@field name string
---@field short_name string
---@field filename string
---@field short_path string

---@class BuffonApiState
---@field index_buffers_by_name table<string, number>
---@field buffers table<BuffonBuffer>
---@field config BuffonConfig
---@field are_duplicated_filenames boolean
---@field storage? BuffonStorage
local state = {
  index_buffers_by_name = {},
  buffers = {},
  are_duplicated_filenames = false,
  storage = nil,
}

local update_storage = function()
  if state.storage then
    state.storage:save(state.buffers)
  end
end

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

--- Sets the buffers list and refreshes the indexes.
---@param list table<BuffonBuffer> The list of buffers to set.
local set_buffers = function(list)
  state.buffers = list
  refresh_indexes()
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

--- Moves a buffer to the top of the list.
---@param name string The name of the buffer to move to the top.
---@param id number
---@return nil
M.add_buffer = function(name, id)
  -- [No Name] buffer is ignored
  if name == "" or name == "/" or state.index_buffers_by_name[name] ~= nil then
    return
  end

  ---@type BuffonBuffer
  local buffer = {
    id = id,
    name = name,
    short_name = vim.fn.fnamemodify(name, ":."),
    filename = vim.fn.fnamemodify(name, ":t"),
    short_path = utils.abbreviate_path(vim.fn.fnamemodify(name, ":.")),
  }

  if state.config.prepend_buffers then
    table.insert(state.buffers, 1, buffer)
  else
    table.insert(state.buffers, buffer)
  end

  check_duplicated_filenames()
  refresh_indexes()
  update_storage()
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

  table.remove(state.buffers, buffer_index)
  check_duplicated_filenames()
  refresh_indexes()
  update_storage()
end

--- Swaps two buffers in the list.
---@param list table<BuffonBuffer> The list of buffers.
---@param index1 number The index of the first buffer.
---@param index2 number The index of the second buffer.
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
  update_storage()
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
  update_storage()
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
  update_storage()
end

---@return boolean
M.are_duplicated_filenames = function()
  return state.are_duplicated_filenames
end

--- Sets up the API state with the provided configuration.
---@param opts? BuffonConfig The configuration options.
---@param storage? BuffonStorage The instance of the storage class
M.setup = function(opts, storage)
  state.config = opts or config.opts()
  set_buffers({})

  if storage then
    state.storage = storage
    -- TODO validate buffers before add them
    set_buffers(state.storage:load())
  end
end

return M
