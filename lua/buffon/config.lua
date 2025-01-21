local M = {}

---@class NvimConfig
---@field cyclic_navigation? boolean
---@field leader_key? string
---@field buffer_mappings_chars? string

---@class PluginConfig
---@field cyclic_navigation boolean
---@field leader_key string
---@field buffer_mappings_chars string

---@type PluginConfig
local plugin_config = {
	cyclic_navigation = false,
	leader_key = ";",
	buffer_mappings_chars = "qwer",
}

---@return PluginConfig
M.opts = function()
	return plugin_config
end

---@param opts NvimConfig
M.setup = function(opts)
	opts = opts or {}
	plugin_config = vim.tbl_deep_extend("force", plugin_config, opts)
end

return M
