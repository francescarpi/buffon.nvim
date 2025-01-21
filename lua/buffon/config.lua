local M = {}

---@class BuffonUserConfig
---@field cyclic_navigation? boolean
---@field leader_key? string
---@field buffer_mappings_chars? string
---@field prepend_buffers? boolean

---@class BuffonConfig
---@field cyclic_navigation boolean
---@field leader_key string
---@field buffer_mappings_chars string
---@field prepend_buffers boolean

---@type BuffonConfig
local plugin_config = {
	cyclic_navigation = false,
	leader_key = ";",
	buffer_mappings_chars = "qwer",
	prepend_buffers = false,
}

---@return BuffonConfig
M.opts = function()
	return plugin_config
end

---@param opts BuffonUserConfig
M.setup = function(opts)
	opts = opts or {}
	plugin_config = vim.tbl_deep_extend("force", plugin_config, opts)
end

return M
