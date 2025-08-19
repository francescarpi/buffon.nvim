local log = require("buffon.log")
local config = require("buffon.config")
local storage = require("buffon.storage")
local maincontroller = require("buffon.maincontroller")
local pagecontroller = require("buffon.pagecontroller")

local M = {}

---@alias BuffonPluginFunc fun(BuffonCtrl: BuffonMainController):nil

---@class BuffonGlobals
---@field ctrl BuffonMainController|nil
---@field extensions_queue BuffonPluginFunc[]

---@type BuffonGlobals
Buffon = {
	ctrl = nil,
	extensions_queue = {}
}

M.setup = function(opts)
	log.debug("==== initial setup ====")
	local cfg = config.Config:new(opts or {})

	local stg = storage.Storage:new(vim.fn.getcwd())
	local success = stg:init()
	if not success then
		vim.notify("buffon: storage couldn't be initialized", vim.log.levels.ERROR)
		return
	end

	local pages = stg:load()

	local pagectrl = pagecontroller.PageController:new(cfg)
	pagectrl:set_data(pages)

	Buffon.ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
	Buffon.ctrl:register_shortcuts()
	Buffon.ctrl:register_events()

	for _, callback in ipairs(Buffon.extensions_queue) do
		callback(Buffon.ctrl)
	end

	return Buffon.ctrl
end

---@param callback BuffonPluginFunc
function M.add(callback)
	if Buffon.ctrl ~= nil then
		callback(Buffon.ctrl)
	else
		table.insert(Buffon.extensions_queue, callback)
	end
end

---@param partial_shortcuts table<string, string>
function M.update_shortcuts(partial_shortcuts)
	if Buffon.ctrl == nil then
		log.error("Buffon controller is not initialized yet.")
		return
	end
	Buffon.ctrl:update_shortcuts(partial_shortcuts)
end

return M
