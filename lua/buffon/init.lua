local log = require("buffon.log")
local config = require("buffon.config")
local storage = require("buffon.storage")
local maincontroller = require("buffon.maincontroller")
local pagecontroller = require("buffon.pagecontroller")

local M = {}

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

  local ctrl = maincontroller.MainController:new(cfg, pagectrl, stg)
  ctrl:register_shortcuts()
  ctrl:register_events()
  return ctrl
end

return M
