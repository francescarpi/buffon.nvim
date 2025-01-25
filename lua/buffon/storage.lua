local utils = require("buffon.utils")
local Path = require("plenary.path")
local log = require("buffon.log")

local M = {}

---@class BuffonStorage
---@field workspace string
local Storage = {}

local default_data_path = string.format("%s/buffon", vim.fn.stdpath("data"))

--- Constructor
---@param workspace string
---@param custom_data_path? string
function Storage:new(workspace, custom_data_path)
  local o = {
    workspace = workspace,
    data_path = custom_data_path or default_data_path,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Generates a slugified filename based on the workspace.
--- If the workspace is "/", returns "root.json".
--- The filename is limited to a maximum of 150 characters (excluding the ".json" extension).
---@return string The generated filename.
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

--- Generates the full path for the storage file based on the workspace.
--- The path is constructed using the data path and the slugified filename.
---@return string The full path to the storage file.
function Storage:filename_path()
  return string.format("%s/%s", self.data_path, self:filename())
end

--- Initializes the storage by creating the necessary directory if it does not exist.
function Storage:init()
  local path = Path:new(self.data_path)
  if not path:exists() then
    path:mkdir()
  end
end

--- Loads the list of buffers from a JSON file and returns them.
---@param filename_path string
--- @return table<BuffonBuffer> The list of buffers.
local load_data = function(filename_path)
  local path = Path:new(filename_path)
  if not path:exists() then
    return {}
  end
  local data = path:read()
  local buffers = vim.json.decode(data)

  -- The buffer ID must be set to nil because, by default, all buffers will be loaded
  -- within the buffers list but not in Neovim.
  for _, buffer in ipairs(buffers) do
    buffer.id = nil
  end
  return buffers
end

--- Loads the list of buffers from a JSON file and returns them.
--- @return table<BuffonBuffer> The list of buffers.
function Storage:load()
  local ok, buffers = pcall(load_data, self:filename_path())
  if not ok then
    error("Buffers couldn't be loaded from disk")
    return {}
  end

  log.debug(#buffers, "buffers loaded from disk")
  return buffers
end

--- Saves the list of buffers to a JSON file.
--- @param buffers table<BuffonBuffer> The list of buffers to save.
function Storage:save(buffers)
  Path:new(self:filename_path()):write(vim.json.encode(buffers), "w")
end

M.Storage = Storage

return M
