local M = {}

M.table_copy = function(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

--- Abbreviates a file path by taking the first letter of each directory, but keeps the file name intact.
--- Only considers the last three levels of the path.
---@param path string The original file path.
---@return string The abbreviated file path.
M.abbreviate_path = function(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do
    table.insert(parts, part)
  end

  local start_index = math.max(1, #parts - 3)
  for i = start_index, #parts - 1 do
    parts[i] = parts[i]:gsub("[%[%]]", ""):gsub("-", ""):sub(1, 1)
  end

  return "/" .. table.concat(parts, "/", start_index)
end

--- Converts a string into a URL-friendly "slug" by replacing spaces and non-alphanumeric characters with hyphens.
---@param str string The original string to be slugified.
---@return string The slugified string.
M.slugify = function(str)
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

---@class BuffonLastClosedList
---@field buffers? table<string>
---@field limit? number
local LastClosedList = {}

--- Constructor
---@param limit? number
function LastClosedList:new(limit)
  local o = {
    buffers = {},
    limit = limit or 10,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param buffer string
function LastClosedList:add(buffer)
  if #self.buffers > 0 and self.buffers[#self.buffers] == buffer then
    return
  end

  table.insert(self.buffers, buffer)

  if #self.buffers > self.limit then
    table.remove(self.buffers, 1)
  end
end

---@return string?
function LastClosedList:get_last()
  if #self.buffers == 0 then
    return nil
  end
  return table.remove(self.buffers)
end

M.LastClosedList = LastClosedList

return M
