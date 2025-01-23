local api = require("buffon.api")
local config = require("buffon.config")
local ui = require("buffon.ui")
local utils = require("buffon.utils")

local M = {}

---@class BuffonBufferInfo
---@field buffer BuffonBuffer
---@field index number

--- Gets the current buffer information.
---@return BuffonBufferInfo | nil The current buffer and its index, or nil if no buffer is found.
local get_current_buf_info = function()
  local buffers = api.get_buffers()
  if #buffers == 0 then
    return
  end

  local current_buf_id = vim.api.nvim_get_current_buf()
  if current_buf_id == nil then
    return
  end

  local current_buf_name = vim.api.nvim_buf_get_name(current_buf_id)
  local current_buf_index = api.get_index_by_name(current_buf_name)
  if current_buf_index == nil then
    return
  end

  return {
    buffer = buffers[current_buf_index],
    index = current_buf_index,
  }
end

---@param buffer BuffonBuffer
local open_buffer = function(buffer)
  vim.api.nvim_command("edit " .. buffer.name)
  buffer.id = vim.api.nvim_get_current_buf()
end

--- Switches to the next buffer. If cyclic navigation is enabled, wraps around to the first buffer.
M.next = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local cyclic_navigation = config.opts().cyclic_navigation
  local next_buf = api.get_buffer_by_index(current_buffer.index + 1)
  if not next_buf and cyclic_navigation then
    next_buf = api.get_buffer_by_index(1)
  end

  if not next_buf then
    return
  end

  if not next_buf.id then
    open_buffer(next_buf)
    ui.refresh()
    return
  end

  vim.api.nvim_set_current_buf(next_buf.id)
end

--- Switches to the previous buffer. If cyclic navigation is enabled, wraps around to the last buffer.
M.previous = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local cyclic_navigation = config.opts().cyclic_navigation
  local previous_buf = api.get_buffer_by_index(current_buffer.index - 1)
  if not previous_buf and cyclic_navigation then
    previous_buf = api.get_buffer_by_index(#api.get_buffers())
  end

  if not previous_buf then
    return
  end

  if not previous_buf.id then
    open_buffer(previous_buf)
    ui.refresh()
    return
  end

  vim.api.nvim_set_current_buf(previous_buf.id)
end

--- Goes to the buffer at the specified order.
---@param order number The index of the buffer to switch to.
M.goto_buffer = function(order)
  local buffer_to_go = api.get_buffer_by_index(order)
  if not buffer_to_go then
    return
  end

  if not buffer_to_go.id then
    open_buffer(buffer_to_go)
    ui.refresh()
    return
  end

  local current_buffer = get_current_buf_info()
  if current_buffer and current_buffer.buffer.id ~= buffer_to_go.id then
    vim.api.nvim_set_current_buf(buffer_to_go.id)
  end
end

--- Moves the current buffer up in the buffer list.
M.buffer_up = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local position = api.move_buffer_up(current_buffer.buffer.name)
  if position > -1 then
    ui.refresh()
    vim.print("Buffer moved to position " .. position)
  end
end

--- Moves the current buffer down in the buffer list.
M.buffer_down = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local position = api.move_buffer_down(current_buffer.buffer.name)
  if position > -1 then
    ui.refresh()
    vim.print("Buffer moved to position " .. position)
  end
end

--- Moves the current buffer to the top of the buffer list.
M.buffer_top = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  api.move_buffer_top(current_buffer.buffer.name)
  ui.refresh()
  vim.print("Buffer moved to top")
end

--- Close current buffer
M.close_buffer = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  if vim.api.nvim_buf_is_valid(current_buffer.buffer.id) then
    vim.api.nvim_buf_delete(current_buffer.buffer.id, { force = false })
  end
end

--- Close buffers above
M.close_buffers_above = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local buffers = utils.table_copy(api.get_buffers())

  for i = 1, current_buffer.index - 1 do
    local buf_id = buffers[i].id
    if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
      vim.api.nvim_buf_delete(buf_id, { force = false })
    end
  end
end

--- Close buffers below
M.close_buffers_below = function()
  local current_buffer = get_current_buf_info()
  if not current_buffer then
    return
  end

  local buffers = utils.table_copy(api.get_buffers())
  vim.print(buffers)

  for i = current_buffer.index + 1, #buffers do
    local buf_id = buffers[i].id
    if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
      vim.api.nvim_buf_delete(buf_id, { force = false })
    end
  end
end

return M
