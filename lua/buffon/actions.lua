local api = require("buffon.api")
local ui = require("buffon.ui")
local utils = require("buffon.utils")

local M = {}

---@type BuffonActionsState
local state = {}

---@param buffer BuffonBuffer
local open_buffer = function(buffer)
  vim.api.nvim_command("edit " .. buffer.name)
  buffer.id = vim.api.nvim_get_current_buf()
end

---@param buffer BuffonBuffer
local activate_or_open = function(buffer)
  if buffer.id then
    vim.api.nvim_set_current_buf(buffer.id)
  else
    open_buffer(buffer)
    ui.refresh()
  end
end

---@param callback function
local goto_next_or_previous = function(callback)
  local buffer = callback(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))

  if not buffer then
    return
  end

  activate_or_open(buffer)
end

---@param callback function
local move_buffer = function(callback)
  local index = callback(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  if index > -1 then
    ui.refresh()
    vim.notify(string.format("Buffer moved to index: %d", index))
  end
end

---@param buffers table<BuffonBuffer>
local close_buffers = function(buffers)
  for _, buffer in ipairs(buffers) do
    if buffer.id then
      vim.api.nvim_buf_delete(buffer.id, { force = false })
    else
      api.delete_buffer(buffer.name)
      ui.refresh()
    end
    state.last_closed:add(buffer.name)
  end
end

--- Switches to the next buffer. If cyclic navigation is enabled, wraps around to the first buffer.
M.next = function()
  goto_next_or_previous(api.get_next_buffer)
end

--- Switches to the previous buffer. If cyclic navigation is enabled, wraps around to the last buffer.
M.previous = function()
  goto_next_or_previous(api.get_previous_buffer)
end

--- Goes to the buffer at the specified order.
---@param order number The index of the buffer to switch to.
M.goto_buffer = function(order)
  local buffer = api.get_buffer_by_index(order)
  if not buffer then
    return
  end
  activate_or_open(buffer)
end

--- Moves the current buffer up in the buffer list.
M.buffer_up = function()
  move_buffer(api.move_buffer_up)
end

--- Moves the current buffer down in the buffer list.
M.buffer_down = function()
  move_buffer(api.move_buffer_down)
end

--- Moves the current buffer to the top of the buffer list.
M.buffer_top = function()
  move_buffer(api.move_buffer_top)
end

--- Close current buffer
M.close_buffer = function()
  local buffer_id = vim.api.nvim_get_current_buf()
  close_buffers({
    {
      id = buffer_id,
      name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
    },
  })
end

--- Close buffers above
M.close_buffers_above = function()
  local buffers = api.get_buffers_above(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  close_buffers(buffers)
end

--- Close buffers below
M.close_buffers_below = function()
  local buffers = api.get_buffers_below(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  close_buffers(buffers)
end

--- Close all buffers
M.close_all_buffers = function()
  close_buffers(utils.table_copy(api.get_buffers()))
end

--- Close others buffers
M.close_others = function()
  M.close_buffers_above()
  M.close_buffers_below()
end

--- Restore last closed buffer
M.restore_last_closed_buffer = function()
  local name = state.last_closed:get_last()
  if name then
    vim.api.nvim_command("edit " .. name)
  end
end

M.setup = function()
  state.last_closed = utils.LastClosedList:new(10)
end

return M
