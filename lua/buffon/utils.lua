local M = {}

---@param name string
---@return string
M.format_buffer_name = function(name)
	return vim.fn.fnamemodify(name, ":.")
end

return M
