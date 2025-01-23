local M = {}

M.table_copy = function(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

--- Abbreviates a file path by taking the first letter of each directory, but keeps the file name intact.
---@param path string The original file path.
---@return string The abbreviated file path.
M.abbreviate_path = function(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do
    table.insert(parts, part)
  end
  for i = 1, #parts - 1 do
    parts[i] = parts[i]:sub(1, 1)
  end
  return "/" .. table.concat(parts, "/")
end

return M
