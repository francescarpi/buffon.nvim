local api = require("buffon.api")
local config = require("buffon.config")
local ui = require("buffon.ui")

local M = {}

--- Gets the current buffer information.
---@return table<BuffonBuffer, number> | nil The current buffer and its index, or nil if no buffer is found.
local get_current_buf_info = function()
  local buffers = api.get_buffers_list()
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

  return { buffers[current_buf_index], current_buf_index }
end

--- Switches to the next buffer. If cyclic navigation is enabled, wraps around to the first buffer.
M.next = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  local opts = config.opts()
  local next_buf = api.get_buffer_by_index(current_buffer[2] + 1)
  if next_buf == nil then
    if opts.cyclic_navigation then
      next_buf = api.get_buffer_by_index(1)
    else
      return
    end
  end

  assert(next_buf, "next buffer must exists")
  if next_buf.id ~= current_buffer[1].id then
    vim.api.nvim_set_current_buf(next_buf.id)
  end
end

--- Switches to the previous buffer. If cyclic navigation is enabled, wraps around to the last buffer.
M.previous = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  local opts = config.opts()
  local previous_buf_index = api.get_buffer_by_index(current_buffer[2] - 1)
  if previous_buf_index == nil then
    if opts.cyclic_navigation then
      previous_buf_index = api.get_buffer_by_index(#api.get_buffers_list())
    else
      return
    end
  end

  assert(previous_buf_index, "previous should exists")
  if previous_buf_index.id ~= current_buffer[1].id then
    vim.api.nvim_set_current_buf(previous_buf_index.id)
  end
end

--- Goes to the buffer at the specified order.
---@param order number The index of the buffer to switch to.
M.goto_buffer = function(order)
  local next_buffer = api.get_buffer_by_index(order)
  local current_buffer = get_current_buf_info()

  if next_buffer == nil or current_buffer == nil then
    return
  end

  if next_buffer.id ~= current_buffer[1].id then
    vim.api.nvim_set_current_buf(next_buffer.id)
  end
end

--- Moves the current buffer up in the buffer list.
M.buffer_up = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  local position = api.move_buffer_up(current_buffer[1].name)
  if position > -1 then
    ui.refresh()
    vim.print("Buffer moved to position " .. position)
  end
end

--- Moves the current buffer down in the buffer list.
M.buffer_down = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  local position = api.move_buffer_down(current_buffer[1].name)
  if position > -1 then
    ui.refresh()
    vim.print("Buffer moved to position " .. position)
  end
end

--- Moves the current buffer to the top of the buffer list.
M.buffer_top = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  api.move_buffer_top(current_buffer[1].name)
  ui.refresh()
  vim.print("Buffer moved to top")
end

--- Close current buffer
M.close_buffer = function()
  local current_buffer = get_current_buf_info()
  if current_buffer == nil then
    return
  end

  if vim.api.nvim_buf_is_valid(current_buffer[1].id) then
    vim.api.nvim_buf_delete(current_buffer[1].id, { force = true })
    vim.print("Buffer closed")
  end
end

return M
