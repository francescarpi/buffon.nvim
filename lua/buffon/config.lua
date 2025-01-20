local M = {}

---@class NvimConfig
---@field cyclic_navigation? boolean

---@class PluginConfig
---@field cyclic_navigation boolean

---@type PluginConfig
local plugin_config = {
	cyclic_navigation = false,
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
