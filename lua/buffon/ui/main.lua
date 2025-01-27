local api = require("buffon.api")
local devicons = require("nvim-web-devicons")
local window = require("buffon.ui.window")

local M = {}

---@type BuffonUIState
local state = {}

---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
---@return number | nil
local get_line_active = function(index_buffers_by_name)
  local current_buf = vim.api.nvim_get_current_buf()
  if not current_buf then
    return
  end

  local buffer_index = index_buffers_by_name[vim.api.nvim_buf_get_name(current_buf)]
  if buffer_index == nil then
    return
  end

  return buffer_index - 1
end

---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
---@return BuffonUIGetContent
M.get_content = function(buffers, index_buffers_by_name)
  local lines = {}
  local filenames = {}

  local line_active = get_line_active(index_buffers_by_name)

  for index, buffer in ipairs(buffers) do
    local filename = buffer.filename
    if api.are_duplicated_filenames() then
      filename = buffer.short_path
    end

    table.insert(filenames, filename)

    local shortcut = state.config.opts.keybindings.buffer_mapping.mapping_chars:sub(index, index)
    if shortcut ~= "" then
      shortcut = state.config.opts.keybindings.buffer_mapping.leader_key .. shortcut
    else
      shortcut = string.rep(" ", #state.config.opts.keybindings.buffer_mapping.leader_key + 1)
    end

    local icon, _ = devicons.get_icon_color(buffer.filename, buffer.filename:match("%.(%a+)$"))

    table.insert(lines, string.format("%s %s %s", shortcut, filename, icon or ""))
  end

  return {
    lines = lines,
    line_active = line_active,
    filenames = filenames,
  }
end

--- Refreshes the content window with the buffer filenames.
---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
local refresh_content = function(buffers, index_buffers_by_name)
  local leader_key_length = #state.config.opts.keybindings.buffer_mapping.leader_key + 1
  local content = M.get_content(buffers, index_buffers_by_name)

  if #content.lines == 0 then
    state.window:set_content({ " No buffers... " })
    state.window:refresh_dimensions()
    return
  end

  state.window:set_content(content.lines)
  state.window:refresh_dimensions()

  local highlights = {
    LineNr = {},
    Constant = {},
    String = {},
    Label = {},
  }

  if content.line_active then
    local icon_col_start = leader_key_length + 2 + #content.filenames[content.line_active + 1]
    table.insert(highlights.String, { content.line_active, icon_col_start, icon_col_start + 1 })
    table.insert(highlights.Label, { content.line_active, leader_key_length + 1, -1 })
  end

  for index, buffer in ipairs(buffers) do
    table.insert(highlights.Constant, { index - 1, 0, leader_key_length })
    if buffer.id == nil then
      table.insert(highlights.LineNr, { index - 1, 0, -1 })
    end
  end

  state.window:set_highlight(highlights)
end

--- Refreshes the container and content windows with the current buffer list.
M.refresh = function()
  if state.window then
    local buffers = api.get_buffers()
    local buffers_by_name = api.get_index_buffers_by_name()
    refresh_content(buffers, buffers_by_name)
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
