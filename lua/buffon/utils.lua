local M = {}

---@return string
M.get_buffer_name = function()
  return vim.fn.expand("%:p")
end

M.table_add = function(tbl1, tbl2)
  for _, item in ipairs(tbl2) do
    table.insert(tbl1, item)
  end
end

---@param cfg BuffonConfig
---@param shortcut string
---@return string
M.replace_leader = function(cfg, shortcut)
  local replaced_string = shortcut:gsub("<buffonleader>", cfg.leader_key)
  return replaced_string
end

---@param lines table<string>
---@return number
M.calc_max_length = function(lines)
  local max_length = 0
  for _, line in ipairs(lines) do
    local line_length = vim.fn.strdisplaywidth(line)
    if line_length > max_length then
      max_length = line_length
    end
  end
  return max_length
end

---@class BuffonRecentlyClosed
---@field filenames? table<string>
---@field limit? number
local RecentlyClosed = {}

---@param limit? number
function RecentlyClosed:new(limit)
  local o = {
    filenames = {},
    limit = limit or 10,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param filename string
function RecentlyClosed:add(filename)
  if #self.filenames > 0 and self.filenames[#self.filenames] == filename then
    return
  end

  table.insert(self.filenames, filename)

  if #self.filenames > self.limit then
    table.remove(self.filenames, 1)
  end
end

---@return string?
function RecentlyClosed:get_last()
  if #self.filenames == 0 then
    return nil
  end
  return table.remove(self.filenames)
end

M.RecentlyClosed = RecentlyClosed

return M
