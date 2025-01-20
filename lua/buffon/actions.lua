local api = require("buffon.api")
local config = require("buffon.config")

local M = {}

---@return BufferByName | nil
local get_current_buf_info = function()
	if api.buffers_counter() == 0 then
		return
	end

	local current_buf_id = vim.api.nvim_get_current_buf()
	if current_buf_id == nil then
		return
	end

	local current_buf_name = vim.api.nvim_buf_get_name(current_buf_id)
	local current_buf_info = api.get_buffer_by_name(current_buf_name)
	if current_buf_info == nil then
		return
	end

	return current_buf_info
end

M.next = function()
	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end

	local opts = config.opts()
	local next_buf = api.get_buffer_by_order(current_buf_info.order + 1)
	if next_buf == nil then
		if opts.cyclic_navigation then
			next_buf = api.get_buffer_by_order(0)
		else
			return
		end
	end

	assert(next_buf, "next buffer sould exists")
	if next_buf.id ~= current_buf_id then
		vim.api.nvim_set_current_buf(next_buf.id)
	end
end

M.previous = function()
	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end

	local opts = config.opts()
	local previous_buf = api.get_buffer_by_order(current_buf_info.order - 1)
	if previous_buf == nil then
		if opts.cyclic_navigation then
			previous_buf = api.get_buffer_by_order(api.buffers_counter() - 1)
		else
			return
		end
	end

	assert(previous_buf, "previous should exists")
	if previous_buf.id ~= current_buf_id then
		vim.api.nvim_set_current_buf(previous_buf.id)
	end
end

---@param order number
M.goto = function(order)
	local buffer = api.get_buffer_by_order(order)
	if buffer == nil then
		return
	end

	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end

	if buffer.id ~= current_buf_info.id then
		vim.api.nvim_set_current_buf(buffer.id)
	end

end

--- Move current buffer up
M.buffer_up = function()
	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end

	local position = api.move_buffer_up(current_buf_info.name)
	if position > -1 then
		vim.print("Buffer moved to position " .. position)
	end
end

--- Move current buffer down
M.buffer_down = function()
	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end
	local position = api.move_buffer_down(current_buf_info.name)
	if position > -1 then
		vim.print("Buffer moved to position " .. position)
	end
end

--- Move current buffer to top
M.buffer_top = function()
	local current_buf_info = get_current_buf_info()
	if current_buf_info == nil then
		return
	end
	api.move_buffer_top(current_buf_info.name)
	vim.print("Buffer moved to top")
end

return M
