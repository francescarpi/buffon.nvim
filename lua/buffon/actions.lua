local api_buffers = require("buffon.api.buffers")
local main_win = require("buffon.ui.main")
local utils = require("buffon.utils")
local log = require("buffon.log")

local M = {}

---@type BuffonActionsState
local state = {}

---@param buffer BuffonBuffer
local open_buffer = function(buffer)
  vim.api.nvim_command("edit " .. buffer.name)
  buffer.id = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_cursor(0, buffer.cursor)
  vim.cmd("normal! zz")
end

---@param buffer BuffonBuffer
local activate_or_open = function(buffer)
  if buffer.id then
    vim.api.nvim_set_current_buf(buffer.id)
    local index_group = api_buffers.get_index_and_group_by_name(buffer.name)
    assert(index_group ~= nil, "index group should be present")

    if index_group.group ~= api_buffers.groups.get_active_group() then
      api_buffers.groups.activate_group(index_group.group)
    end
  else
    open_buffer(buffer)
  end
  main_win.refresh()
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
    main_win.refresh()
    log.debug("buffer moved to index", index)
  end
end

---@param buffers_to_close table<BuffonBuffer>
local close_buffers = function(buffers_to_close)
  for _, buffer in ipairs(buffers_to_close) do
    if buffer.id then
      vim.api.nvim_buf_delete(buffer.id, { force = false })
    else
      api_buffers.del.delete_buffer(buffer.name)
      main_win.refresh()
    end
    state.last_closed:add(buffer.name)
  end
end

--- Switches to the next buffer. If cyclic navigation is enabled, wraps around to the first buffer.
M.next = function()
  goto_next_or_previous(api_buffers.nav.get_next_buffer)
end

--- Switches to the previous buffer. If cyclic navigation is enabled, wraps around to the last buffer.
M.previous = function()
  goto_next_or_previous(api_buffers.nav.get_previous_buffer)
end

--- Goes to the buffer at the specified order.
---@param order number The index of the buffer to switch to.
M.goto_buffer = function(order)
  local buffer = api_buffers.get_buffer_by_group_and_index(api_buffers.groups.get_active_group(), order)
  if not buffer then
    return
  end
  activate_or_open(buffer)
end

--- Moves the current buffer up in the buffer list.
M.buffer_up = function()
  move_buffer(api_buffers.move.move_buffer_up)
end

--- Moves the current buffer down in the buffer list.
M.buffer_down = function()
  move_buffer(api_buffers.move.move_buffer_down)
end

--- Moves the current buffer to the top of the buffer list.
M.buffer_top = function()
  move_buffer(api_buffers.move.move_buffer_top)
end

--- Moves the current buffer to the bottom of the buffer list.
M.buffer_bottom = function()
  move_buffer(api_buffers.move.move_buffer_bottom)
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
  local buffers_to_close = api_buffers.del.get_buffers_above(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  close_buffers(buffers_to_close)
end

--- Close buffers below
M.close_buffers_below = function()
  local buffers_to_close = api_buffers.del.get_buffers_below(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  close_buffers(buffers_to_close)
end

--- Close all buffers
M.close_all_buffers = function()
  close_buffers(utils.table_copy(api_buffers.get_buffers_active_group()))
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

---@param name string
M.save_last_used = function(name)
  local buffer_index = api_buffers.get_index_and_group_by_name(name)
  if buffer_index and buffer_index.index then
    local buffer = api_buffers.get_buffer_by_group_and_index(buffer_index.group, buffer_index.index)
    state.last_used = buffer
  end
end

M.last_used = function()
  if state.last_used and vim.api.nvim_buf_is_valid(state.last_used.id) then
    activate_or_open(state.last_used)
  end
end

local select_first_buffer_of_group = function()
  local group_buffers = api_buffers.get_buffers_active_group()
  if #group_buffers > 0 then
    activate_or_open(group_buffers[1])
  end
end

M.next_group = function()
  api_buffers.groups.next_group()
  main_win.refresh()
  select_first_buffer_of_group()
end

M.previous_group = function()
  api_buffers.groups.previous_group()
  main_win.refresh()
  select_first_buffer_of_group()
end

M.move_to_next_group = function()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local group = api_buffers.groups.move_to_next_group(name)
  api_buffers.groups.activate_group(group)
  main_win.refresh()
end

M.move_to_previous_group = function()
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local group = api_buffers.groups.move_to_previous_group(name)
  api_buffers.groups.activate_group(group)
  main_win.refresh()
end

M.setup = function()
  state.last_closed = utils.LastClosedList:new(10)
end

return M
