local api = require("buffon.api")
local devicons = require("nvim-web-devicons")

local M = {}

---@type BuffonUIState
local state = {}

local window_options = function()
  return {
    title = " Buffon (" .. state.config.opts.keybindings.show_help .. ") ",
    title_pos = "right",
    relative = "editor",
    width = 1,
    height = 1,
    col = 1,
    row = 0,
    style = "minimal",
    border = "single",
    zindex = 1,
    focusable = false,
  }
end

--- Updates the width of the window.
---@param longest_word_length number The new width for the windows.
---@param num_lines number
local update_dimensions = function(longest_word_length, num_lines)
  local editor_width = vim.api.nvim_get_option("columns")
  local leader_key_length = #state.config.opts.keybindings.buffer_mapping.leader_key
  local MAPPING_CHAR_LENGTH = 1
  local SPACE_LENGTH = 1
  local BORDER_LENGTH = 1
  local ICON_LENGTH = 2

  local width = leader_key_length + MAPPING_CHAR_LENGTH + SPACE_LENGTH + longest_word_length + ICON_LENGTH
  local col = editor_width - (BORDER_LENGTH + width + BORDER_LENGTH)

  local wincfg = vim.api.nvim_win_get_config(state.window.id)
  wincfg.col = col
  wincfg.width = width
  vim.api.nvim_win_set_config(state.window.id, wincfg)

  local height = num_lines
  if num_lines == 0 then
    height = 1
  end
  vim.api.nvim_win_set_height(state.window.id, height)
end

---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
---@return BuffonUIGetContent
M.get_content = function(buffers, index_buffers_by_name)
  local lines = {}
  local filenames = {}
  local longest_word_length = 10 -- Width minimum for the empty modal

  local line_active = nil
  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf then
    local buffer_index = index_buffers_by_name[vim.api.nvim_buf_get_name(current_buf)]
    if buffer_index then
      line_active = buffer_index - 1
    end
  end

  -- lines loop
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

    if #filename > longest_word_length then
      longest_word_length = #filename
    end
  end
  return {
    lines = lines,
    line_active = line_active,
    longest_word_length = longest_word_length,
    filenames = filenames,
  }
end

--- Refreshes the content window with the buffer filenames.
---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
local refresh_content = function(buffers, index_buffers_by_name)
  local content = M.get_content(buffers, index_buffers_by_name)
  local leader_key_length = #state.config.opts.keybindings.buffer_mapping.leader_key + 1

  if #content.lines == 0 then
    vim.api.nvim_buf_set_lines(state.window.buf, 0, -1, false, { " No buffers... " })
    update_dimensions(content.longest_word_length, #buffers)
    return
  end

  vim.api.nvim_buf_set_lines(state.window.buf, 0, -1, false, content.lines)

  -- highlights (color)
  for index, buffer in ipairs(buffers) do
    if buffer.id == nil then -- unloaded buffer
      vim.api.nvim_buf_add_highlight(state.window.buf, -1, "LineNr", index - 1, 0, -1)
    end
    vim.api.nvim_buf_add_highlight(state.window.buf, -1, "Constant", index - 1, 0, leader_key_length) -- shortcut
  end

  if content.line_active then
    vim.api.nvim_buf_add_highlight(state.window.buf, -1, "Label", content.line_active, leader_key_length + 1, -1)
    local icon_col_start = leader_key_length + 2 + #content.filenames[content.line_active + 1]
    vim.api.nvim_buf_add_highlight(
      state.window.buf,
      -1,
      "String",
      content.line_active,
      icon_col_start,
      icon_col_start + 1
    )
  end

  update_dimensions(content.longest_word_length, #buffers)
end

--- Refreshes the container and content windows with the current buffer list.
M.refresh = function()
  if state.window.id then
    local buffers = api.get_buffers()
    local buffers_by_name = api.get_index_buffers_by_name()
    refresh_content(buffers, buffers_by_name)
  end
end

--- Hides the windows
M.hide = function()
  vim.api.nvim_win_close(state.window.id, true)
  state.window.id = nil

  local help = require("buffon.ui.help")
  if help.is_open() then
    help.close()
  end
end

---@return boolean
M.is_open = function()
  if state.window.id then
    return true
  end
  return false
end

--- Shows the window, or hides them if they are already visible.
M.show = function()
  state.window.id = vim.api.nvim_open_win(state.window.buf, false, window_options())
  M.refresh()
end

M.toggle = function()
  if not M.is_open() then
    M.show()
  else
    M.hide()
  end
end

M.check_open = function()
  if state.window.id or not vim.bo.filetype then
    return
  end

  if state.config.opts.open.by_default and not vim.tbl_contains(state.config.opts.open.ignore_ft, vim.bo.filetype) then
    M.show()
  end
end

--- Sets up the UI state with the provided configuration.
---@param config BuffonConfigState The configuration options.
M.setup = function(config)
  state.config = config
  state.window = { buf = vim.api.nvim_create_buf(false, true), id = nil }
end

return M
