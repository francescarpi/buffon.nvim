local utils = require("buffon.utils")

local M = {}

local Storage = {}

--- Constructor
---@param workspace string
function Storage:new(workspace)
  local o = {
    workspace = workspace,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Generates the filename according the workspace
---@return string
function Storage:filename()
  if self.workspace == "/" then
    return "root.json"
  end
  local fn = utils.slugify(self.workspace)
  if #fn > 150 then
    fn = fn:sub(1, 150)
  end
  return fn .. ".json"
end

M.Storage = Storage

return M
