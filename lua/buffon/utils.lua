local M = {}

---@return string
M.get_buffer_name = function()
  return vim.fn.expand("%:p")
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
