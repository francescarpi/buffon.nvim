-- luacheck: ignore unused self

local bufferslist = require("buffon.bufferslist")
local devicons = require("nvim-web-devicons")
local utils = require("buffon.utils")

local M = {}

---@enum theme
local THEME = {
  UnloadedBuffers = "BuffonUnloadedBuffer",
  Shortcut = "BuffonShortcut",
  LineActive = "BuffonLineActive",
  ModifiedIndicator = "BuffonUnsavedIndicator",
}

local WHITESPACE = 1
local CHAR = 1
local ICON = 1
local MODIFIED = 5

---@class BuffonPage
---@field bufferslist BuffonBuffersList
---@field config BuffonConfig
local Page = {}

---@param cfg BuffonConfig
function Page:new(cfg)
  local o = {
    bufferslist = bufferslist.BuffersList:new(cfg),
    config = cfg,
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

---@param index number
---@return string
function Page:_get_shortcut(index)
  local shortcut = self.config.mapping_chars:sub(index, index)
  if shortcut ~= "" then
    shortcut = self.config.leader_key .. shortcut
  else
    shortcut = string.rep(" ", #self.config.leader_key + 1)
  end
  return shortcut
end

---@param buffer BuffonBuffer
---@return string
function Page:_get_modified(buffer)
  local modified = ""
  if
    buffer.id
    and vim.api.nvim_buf_is_valid(buffer.id)
    and vim.api.nvim_get_option_value("modified", { buf = buffer.id })
  then
    modified = " [+]"
  end
  return modified
end

---@param filename string
---@return string
function Page:_get_icon(filename)
  local icon, _ = devicons.get_icon(filename, filename:match("%.(%a+)$"), { default = true })
  return icon
end

---@param buffers table<BuffonBuffer>
---@return table<string>
function Page:_get_filenames(buffers)
  local filenames = {}
  local filenames_done = {}

  for idx, buffer in ipairs(buffers) do
    if filenames_done[buffer.filename] then
      table.insert(filenames, buffer.short_path)
      filenames[filenames_done[buffer.filename].index] = filenames_done[buffer.filename].short_path
    else
      table.insert(filenames, buffer.filename)
    end

    filenames_done[buffer.filename] = {
      index = idx,
      short_path = buffer.short_path,
    }
  end

  return filenames
end

---@class BuffonPageRender
---@field content table<string>
---@field highlights BuffonWindowHighlights

---@param active_buffer? string
---@return BuffonPageRender
function Page:render(active_buffer)
  if #self.bufferslist.buffers == 0 then
    return {
      content = { " No buffers... " },
      highlights = {},
    }
  end

  active_buffer = active_buffer or utils.get_buffer_name()
  local response = {
    content = {},
    highlights = {
      [THEME.LineActive] = {},
      [THEME.UnloadedBuffers] = {},
      [THEME.ModifiedIndicator] = {},
      [THEME.Shortcut] = {},
    },
  }
  local filenames = self:_get_filenames(self.bufferslist.buffers)
  local max_length = utils.calc_max_length(filenames)

  for idx, buffer in ipairs(self.bufferslist.buffers) do
    -- content
    local shortcut = self:_get_shortcut(idx)
    local filename = filenames[idx]
    local modified = self:_get_modified(buffer)
    local icon = self:_get_icon(buffer.filename)

    local diff_file_length = max_length - vim.fn.strdisplaywidth(filename)
    local spaces = string.rep(" ", diff_file_length + 1)
    if diff_file_length == 0 then
      spaces = " "
    end

    local line = string.format("%s %s%s%s%s", shortcut, filename, spaces, icon, modified)
    table.insert(response.content, line)

    -- highlights
    local shortcut_start = 0
    local shortcut_end = shortcut_start + #self.config.leader_key + CHAR
    local filename_start = shortcut_end + WHITESPACE
    local filename_end = filename_start + #filename + #spaces + WHITESPACE + ICON
    local modified_start = filename_end + WHITESPACE
    local modified_end = modified_start + MODIFIED

    if buffer.name == active_buffer then -- line active
      table.insert(response.highlights[THEME.LineActive], {
        line = idx - 1,
        col_start = filename_start,
        col_end = filename_end,
      })
    end

    if buffer.id then -- loaded buffer
      if modified ~= "" then
        table.insert(response.highlights[THEME.ModifiedIndicator], {
          line = idx - 1,
          col_start = modified_start,
          col_end = modified_end,
        })
      end
      table.insert(
        response.highlights[THEME.Shortcut],
        { line = idx - 1, col_start = shortcut_start, col_end = shortcut_end }
      )
    else -- unloaded buffer
      table.insert(response.highlights[THEME.UnloadedBuffers], {
        line = idx - 1,
        col_start = shortcut_start,
        col_end = filename_end,
      })
    end
  end

  return response
end

---@param buffer BuffonBuffer
---@param index_of_active_buffer number | nil
function Page:add_buffer(buffer, index_of_active_buffer)
  self.bufferslist:add(buffer, index_of_active_buffer)
end

---@return table<BuffonBuffer>
function Page:get_buffers()
  return self.bufferslist.buffers
end

---@param name string
function Page:remove_buffer(name)
  self.bufferslist:remove(name)
end

M.Page = Page

return M
