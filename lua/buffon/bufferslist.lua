local log = require("buffon.log")
local buffon_buffer = require("buffon.buffer")

local M = {}
---
---@param name string
---@return boolean
local allowed_buffer = function(name)
  return name ~= "" and name ~= "/"
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

---@class BuffonBuffersList
---@field buffers table<BuffonBuffer>
---@field index_by_name table<string, number>
---@field config BuffonConfig
local BuffersList = {}

---@param config BuffonConfig
function BuffersList:new(config)
  local o = {
    buffers = {},
    config = config,
    index_by_name = {},
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param buffer BuffonBuffer
---@param index_of_active_buffer number | nil
function BuffersList:add(buffer, index_of_active_buffer)
  if not allowed_buffer(buffer.name) then
    return
  end

  -- Check if buffer already exists
  local existent = self:get_index(buffer.name)
  if existent then
    self.buffers[existent].id = buffer.id
    return
  end

  log.debug("add buffer", buffer.name, "with id", buffer.id)

  if self.config.new_buffer_position == "start" then
    table.insert(self.buffers, 1, buffer)
  elseif self.config.new_buffer_position == "end" then
    table.insert(self.buffers, buffer)
  else
    index_of_active_buffer = index_of_active_buffer or 0
    local position = index_of_active_buffer + 1
    if position > #self.buffers then
      table.insert(self.buffers, buffer)
    else
      table.insert(self.buffers, position, buffer)
    end
  end
  self:reindex()
end

---@param name string
---@return number | nil
function BuffersList:get_index(name)
  return self.index_by_name[name]
end

function BuffersList:reindex()
  local index_by_name = {}
  for idx, buf in ipairs(self.buffers) do
    index_by_name[buf.name] = idx
  end
  self.index_by_name = index_by_name
end

---@param name string
---@return BuffonBuffer | nil
function BuffersList:get_by_name(name)
  local idx = self:get_index(name)
  if idx then
    return self.buffers[idx]
  end
end

---@param name string
function BuffersList:remove(name)
  local idx = self:get_index(name)
  if idx then
    table.remove(self.buffers, idx)
  end
  self:reindex()
end

---@param name string
---@return table<BuffonBuffer>
function BuffersList:get_buffers_above(name)
  local buffers = {}
  local idx = self:get_index(name)

  for i = 1, idx - 1 do
    table.insert(buffers, self.buffers[i])
  end

  return buffers
end

---@param name string
---@return table<BuffonBuffer>
function BuffersList:get_buffers_below(name)
  local buffers = {}
  local idx = self:get_index(name)

  for i = idx + 1, #self.buffers do
    table.insert(buffers, self.buffers[i])
  end

  return buffers
end

---@param name string
---@return table<BuffonBuffer>
function BuffersList:get_other_buffers(name)
  local buffers = self:get_buffers_above(name)

  for _, buffer in ipairs(self:get_buffers_below(name)) do
    table.insert(buffers, buffer)
  end

  return buffers
end

---@param name string
function BuffersList:move_up(name)
  local idx = self:get_index(name)
  if idx and idx > 1 then
    swap_buffers(self.buffers, idx, idx - 1)
  end
  self:reindex()
end

---@param name string
function BuffersList:move_down(name)
  local idx = self:get_index(name)
  if idx and idx < #self.buffers then
    swap_buffers(self.buffers, idx, idx + 1)
  end
  self:reindex()
end

---@param name string
function BuffersList:move_top(name)
  local idx = self:get_index(name)
  if idx then
    local buf = self.buffers[idx]
    table.remove(self.buffers, idx)
    table.insert(self.buffers, 1, buf)
  end
  self:reindex()
end

---@param name string
function BuffersList:move_bottom(name)
  local idx = self:get_index(name)
  if idx then
    local buf = self.buffers[idx]
    table.remove(self.buffers, idx)
    table.insert(self.buffers, buf)
  end
  self:reindex()
end

---@param buffers table<BuffonBuffer>
function BuffersList:set_buffers(buffers)
  self.buffers = buffers
  self:reindex()
end

---@param name string
---@return BuffonBuffer | nil
function BuffersList:get_next_buffer(name)
  local idx = self:get_index(name)
  if not idx then
    return
  end

  local next = idx + 1
  if next > #self.buffers then
    next = 1
  end

  return self.buffers[next]
end

---@param name string
---@return BuffonBuffer | nil
function BuffersList:get_previous_buffer(name)
  local idx = self:get_index(name)
  if not idx then
    return
  end

  local previous = idx - 1
  if previous < 1 then
    previous = #self.buffers
  end

  return self.buffers[previous]
end

---@param name string
---@param new_name string
function BuffersList:rename(name, new_name)
  local idx = self:get_index(name)
  if idx then
    local buf = buffon_buffer.Buffer:new(self.buffers[idx].id, new_name)
    self.buffers[idx] = buf
  end
end

---@param name string
---@param position [number, number]
function BuffersList:update_cursor(name, position)
  local idx = self:get_index(name)
  if idx then
    self.buffers[idx].cursor = position
  end
end

M.BuffersList = BuffersList

return M
