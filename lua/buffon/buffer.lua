local M = {}

---@class BuffonBuffer
---@field id number
---@field name string
---@field short_name string
---@field filename string
---@field short_path string
---@field cursor [number, number] | nil
local Buffer = {}

M.abbreviate_path = function(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do
    table.insert(parts, part)
  end

  local start_index = math.max(1, #parts - 3)
  for i = start_index, #parts - 1 do
    parts[i] = parts[i]:gsub("(%w)%w+", "%1")
  end

  return "/" .. table.concat(parts, "/", start_index)
end

---@param id number
---@param name string
function Buffer:new(id, name)
  local o = {
    id = id,
    name = name,
    short_name = vim.fn.fnamemodify(name, ":."),
    filename = vim.fn.fnamemodify(name, ":t"),
    short_path = M.abbreviate_path(vim.fn.fnamemodify(name, ":.")),
    cursor = { 1, 1 },
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

M.Buffer = Buffer

return M
