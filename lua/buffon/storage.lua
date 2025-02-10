local Path = require("plenary.path")
local log = require("buffon.log")

local M = {}

local default_data_path = string.format("%s/buffon", vim.fn.stdpath("data"))

---@class BuffonStorage
---@field workspace string
---@field data_path string
local Storage = {}

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

--- Converts a string into a URL-friendly "slug" by replacing spaces and non-alphanumeric characters with hyphens.
---@param str string The original string to be slugified.
---@return string The slugified string.
local slugify = function(str)
  local replacement = "-"
  local result = ""
  -- loop through each word or number
  for word in string.gmatch(str, "(%w+)") do
    result = result .. word .. replacement
  end
  -- remove trailing separator
  result = string.gsub(result, replacement .. "$", "")
  return result:lower()
end

--- Generates a slugified filename based on the workspace.
--- If the workspace is "/", returns "root.json".
--- The filename is limited to a maximum of 150 characters (excluding the ".json" extension).
---@return string The generated filename.
function Storage:filename()
  if self.workspace == "/" then
    return "root.json"
  end
  local fn = slugify(self.workspace)
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

---@param data_path string
local initialize_data_path = function(data_path)
  local path = Path:new(data_path)
  if not path:exists() then
    path:mkdir()
  end
end

--- Initializes the storage by creating the necessary directory if it does not exist.
---@return boolean
function Storage:init()
  local ok, msg = pcall(initialize_data_path, self.data_path)
  if not ok then
    log.debug("storage couldn't be initialized", msg)
  end
  return ok
end

--- Saves the list of buffers to a JSON file.
--- @param pages_buffers table<table<BuffonBuffer>> The list of buffers to save.
function Storage:save(pages_buffers)
  Path:new(self:filename_path()):write(vim.json.encode(pages_buffers), "w")
  log.debug(#pages_buffers, "buffers saved to disk")
end

--- Loads the list of buffers from a JSON file and returns them.
---@param filename_path string
--- @return table<table<BuffonBuffer>> The list of buffers.
local load_data = function(filename_path)
  local path = Path:new(filename_path)
  if not path:exists() then
    return {}
  end

  local data = path:read()
  local buffers = vim.json.decode(data)

  -- Buffer IDs must be set to nil because, by default, all buffers will be loaded
  -- within the buffer list but not in Neovim.
  for _, page in ipairs(buffers) do
    for _, buffer in ipairs(page) do
      buffer.id = nil
    end
  end

  return buffers
end

--- Loads the list of buffers from a JSON file and returns them.
--- @return table<table<BuffonBuffer>> The list of buffers.
function Storage:load()
  local ok, pages_buffers = pcall(load_data, self:filename_path())
  if not ok then
    error("Buffers couldn't be loaded from disk")
    return {}
  end

  log.debug(#pages_buffers, "buffers loaded from disk")
  return pages_buffers
end

M.Storage = Storage

return M
