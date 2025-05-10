local log = require("buffon.log")
local config = require("buffon.config")
local storage = require("buffon.storage")
local maincontroller = require("buffon.maincontroller")
local pagecontroller = require("buffon.pagecontroller")

local M = {}

---@alias BuffonPluginFunc fun(BuffonCtrl: BuffonMainController):nil

---@class BuffonGlobals
---@field ctrl BuffonMainController|nil
---@field on_created BuffonPluginFunc[]

---@type BuffonGlobals
Buffon = {
  ctrl = nil,
  on_created = {}
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

  for _, callback in ipairs(Buffon.on_created) do
    callback(Buffon.ctrl)
  end

  return Buffon.ctrl
end

---@param callback BuffonPluginFunc
function M.add(callback)
  if Buffon.ctrl ~= nil then
    callback(Buffon.ctrl)
  else
    table.insert(Buffon.on_created, callback)
  end
end

return M
