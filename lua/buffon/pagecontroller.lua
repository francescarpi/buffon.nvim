local page = require("buffon.page")
local log = require("buffon.log")

local M = {}

---@class BuffonPageController
---@field pages table<BuffonPage>
---@field config BuffonConfig
---@field active number
local PageController = {}

---@param config BuffonConfig
function PageController:new(config)
  local o = {
    pages = {},
    config = config,
    active = 1,
  }

  for _ = 1, config.num_pages do
    table.insert(o.pages, page.Page:new(config))
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

---@param page_num number
---@param buffer BuffonBuffer
---@param index_of_active_buffer number | nil
function PageController:add_buffer(page_num, buffer, index_of_active_buffer)
  if not self.pages[page_num] then
    log.debug("page", page_num, "doesn't exists")
    return
  end
  self.pages[page_num]:add_buffer(buffer, index_of_active_buffer)
end

---@param buffer BuffonBuffer
---@param index_of_active_buffer number | nil
function PageController:add_buffer_to_active_page(buffer, index_of_active_buffer)
  self.pages[self.active]:add_buffer(buffer, index_of_active_buffer)
end

---@param page_num string
---@param name string
function PageController:remove_buffer(page_num, name)
  self.pages[page_num]:remove_buffer(name)
end

---@param name string
function PageController:remove_buffer_from_active_page(name)
  self.pages[self.active]:remove_buffer(name)
end

---@param index number
---@return BuffonPage | nil
function PageController:get_page(index)
  return self.pages[index]
end

---@return BuffonPage | nil
function PageController:get_active_page()
  return self.pages[self.active]
end

---@return number
function PageController:num_pages()
  return #self.pages
end

--- Returns the list of pages with their buffers. This method is used to
--- store the data on disk, using the Storage class
---@return table<table<BuffonBuffer>>
function PageController:get_data()
  local data = {}
  for _, p in ipairs(self.pages) do
    table.insert(data, p:get_buffers())
  end
  return data
end

---@param pages table<table<BuffonBuffer>>
local validate_data = function(config, pages)
  if config.num_pages ~= #pages then
    error("number of pages doesn't match")
  end
  for idx = 1, config.num_pages do
    local buffers = pages[idx]
    for _, buffer in ipairs(buffers) do
      vim.validate({
        name = { buffer.name, "string" },
        short_path = { buffer.short_path, "string" },
        short_name = { buffer.short_name, "string" },
        filename = { buffer.filename, "string" },
        cursor = { buffer.cursor, "table" },
      })
    end
  end
end

---@param pages table<table<BuffonBuffer>>
---@return boolean
function PageController:validate_data(pages)
  local ok, _ = pcall(validate_data, self.config, pages)
  return ok
end

---@param pages table<table<BuffonBuffer>>
function PageController:set_data(pages)
  if not self:validate_data(pages) then
    log.debug("loaded data is not valid")
    return
  end

  for idx, buffers in ipairs(pages) do
    self.pages[idx].bufferslist:set_buffers(buffers)
  end

  log.debug("data loaded from disk successfully")
end

function PageController:next_page()
  local next = (self.active % self.config.num_pages) + 1
  self.active = next
end

function PageController:previous_page()
  local previous = ((self.active - 2) % self.config.num_pages) + 1
  self.active = previous
end

---@param page_number number
function PageController:set_page(page_number)
  self.active = page_number
end

---@param name string
function PageController:move_to_next_page(name)
  local buf = self:get_active_page().bufferslist:get_by_name(name)
  if buf then
    self:get_active_page().bufferslist:remove(name)
    local next = (self.active % self.config.num_pages) + 1
    self:add_buffer(next, buf)
  end
end

---@param name string
function PageController:move_to_previous_page(name)
  local buf = self:get_active_page().bufferslist:get_by_name(name)
  if buf then
    self:get_active_page().bufferslist:remove(name)
    local previous = ((self.active - 2) % self.config.num_pages) + 1
    self:add_buffer(previous, buf)
  end
end

---@param name string
---@return BuffonBuffer?, number?
function PageController:get_buffer_and_page(name)
  for page_num, pageobj in ipairs(self.pages) do
    local buf = pageobj.bufferslist:get_by_name(name)
    if buf then
      return buf, page_num
    end
  end
  return nil, nil
end

M.PageController = PageController

return M
