local api_buffers = require("buffon.api.buffers")
local devicons = require("nvim-web-devicons")
local window = require("buffon.ui.window")

local M = {}

---@type BuffonUIState
local state = {}

---@param index_buffers_by_name table<string, BuffonIndexBuffersByName> A table mapping buffer names to their indices.
---@return number | nil
local get_line_active = function(index_buffers_by_name)
  local buffer_name = vim.api.nvim_get_current_buf()
  if not buffer_name then
    return
  end

  local buffer_group_index = index_buffers_by_name[vim.api.nvim_buf_get_name(buffer_name)]
  if
    not buffer_group_index
    or not buffer_group_index.index
    or buffer_group_index.group ~= api_buffers.groups.get_active_group()
  then
    return
  end

  return buffer_group_index.index - 1
end

---@param buffers_list table<BuffonBuffer> The list of buffers.
---@return table<string>
M.ger_buffer_names = function(buffers_list)
  local filenames = {}
  local filenames_done = {}
  for index, buffer in ipairs(buffers_list) do
    if filenames_done[buffer.filename] then
      table.insert(filenames, buffer.short_path)
      filenames[filenames_done[buffer.filename].index] = filenames_done[buffer.filename].short_path
    else
      table.insert(filenames, buffer.filename)
    end
    filenames_done[buffer.filename] = {
      index = index,
      short_path = buffer.short_path,
    }
  end
  return filenames
end

---@param buffers_list table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, BuffonIndexBuffersByName> A table mapping buffer names to their indices.
---@return BuffonMainWindowContent
M.get_content = function(buffers_list, index_buffers_by_name)
  local lines = {}
  local filenames = M.ger_buffer_names(buffers_list)
  local line_active = get_line_active(index_buffers_by_name)

  for index, buffer in ipairs(buffers_list) do
    local filename = filenames[index]
    local shortcut = state.config.opts.keybindings.buffer_mapping.mapping_chars:sub(index, index)
    if shortcut ~= "" then
      shortcut = state.config.opts.keybindings.buffer_mapping.leader_key .. shortcut
    else
      shortcut = string.rep(" ", #state.config.opts.keybindings.buffer_mapping.leader_key + 1)
    end

    local modified = ""
    if
      buffer.id
      and vim.api.nvim_buf_is_valid(buffer.id)
      and vim.api.nvim_get_option_value("modified", { buf = buffer.id })
    then
      modified = " [+]"
    end

    local icon, _ = devicons.get_icon(buffer.filename, buffer.filename:match("%.(%a+)$"), { default = true })
    local line = string.format("%s %s %s%s", shortcut, filename, icon, modified)

    table.insert(lines, line)
  end

  return {
    lines = lines,
    line_active = line_active,
    filenames = filenames,
  }
end

---@return string
local footer = function()
  local footer = ""
  for i = 1, state.config.opts.max_groups do
    if i == api_buffers.groups.get_active_group() then
      footer = footer .. "●"
    else
      footer = footer .. "○"
    end
  end
  return footer
end

--- Refreshes the content window with the buffer filenames.
---@param buffers_list table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, BuffonIndexBuffersByName> A table mapping buffer names to their indices.
local refresh_content = function(buffers_list, index_buffers_by_name)
  local leader_key_length = #state.config.opts.keybindings.buffer_mapping.leader_key + 1
  local content = M.get_content(buffers_list, index_buffers_by_name)

  if #content.lines == 0 then
    state.window:set_content({ " No buffers... " })
    state.window:set_footer(footer())
    state.window:refresh_dimensions()
    return
  end

  state.window:set_content(content.lines)
  state.window:set_footer(footer())
  state.window:refresh_dimensions()

  local theme = {
    UnloadedBuffers = {},
    Shortcut = {},
    Icon = {},
    LineActive = {},
    ModifiedIndicator = {},
  }

  if content.line_active then
    local icon_col_start = leader_key_length + 2 + #content.filenames[content.line_active + 1]
    table.insert(theme.Icon, { content.line_active, icon_col_start, icon_col_start + 1 })
    table.insert(theme.LineActive, { content.line_active, leader_key_length + 1, -1 })
  end

  for index, buffer in ipairs(buffers_list) do
    if buffer.id == nil then
      table.insert(theme.UnloadedBuffers, { index - 1, 0, -1 })
    else
      local modified_col_start = leader_key_length + 2 + #content.filenames[index] + 4
      table.insert(theme.ModifiedIndicator, { index - 1, modified_col_start, modified_col_start + 4 })
      table.insert(theme.Shortcut, { index - 1, 0, leader_key_length })
    end
  end

  state.window:set_highlight({
    LineNr = theme.UnloadedBuffers,
    Constant = theme.Shortcut,
    String = theme.Icon,
    Label = theme.LineActive,
    ErrorMsg = theme.ModifiedIndicator,
  })
end

--- Refreshes the container and content windows with the current buffer list.
M.refresh = function()
  if state.window then
    refresh_content(api_buffers.get_buffers_active_group(), api_buffers.get_index_buffers_by_name())
  end
end

M.toggle = function()
  state.window:toggle()
end

M.check_open = function()
  local should_open = state.config.opts.open.by_default
  local buffer_ignored = vim.tbl_contains(state.config.opts.open.ignore_ft, vim.bo.filetype)

  if should_open and not buffer_ignored then
    state.window:show()
  end
end

--- Sets up the UI state with the provided configuration.
---@param config BuffonConfigState The configuration options.
M.setup = function(config)
  state.config = config
  local title = " Buffon (" .. config.opts.keybindings.show_help .. ") "
  state.window = window.Window:new(title, window.WIN_POSITIONS.top_right)
end

return M
