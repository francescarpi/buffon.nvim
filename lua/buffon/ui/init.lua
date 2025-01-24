local api = require("buffon.api")
local devicons = require("nvim-web-devicons")

local M = {}

---@class BuffonWindow
---@field buf number
---@field id number | nil

---@class BuffonUIState
---@field config BuffonConfig
---@field window BuffonWindow
local state = {}

local window_options = {
  title = " Buffon ",
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

--- Updates the width of the window.
---@param longest_word_length number The new width for the windows.
---@param num_lines number
local update_dimensions = function(longest_word_length, num_lines)
  local editor_width = vim.api.nvim_get_option("columns")
  local leader_key_length = #state.config.keybindings.buffer_mapping.leader_key
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

--- Refreshes the content window with the buffer filenames.
---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
local refresh_content = function(buffers, index_buffers_by_name)
  local lines = {}
  local longest_word_length = 7 -- Width minimum for the empty modal
  local leader_key_length = #state.config.keybindings.buffer_mapping.leader_key + 1

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

    local shortcut = state.config.keybindings.buffer_mapping.mapping_chars:sub(index, index)
    if shortcut ~= "" then
      shortcut = state.config.keybindings.buffer_mapping.leader_key .. shortcut
    end

    local icon, _ = devicons.get_icon_color(buffer.filename, buffer.filename:match("%.(%a+)$"))

    table.insert(lines, string.format("%s %s %s", shortcut, filename, icon or ""))

    if #filename > longest_word_length then
      longest_word_length = #filename
    end
  end

  if #lines == 0 then
    lines = { "No buffers..." }
  end

  vim.api.nvim_buf_set_lines(state.window.buf, 0, -1, false, lines)

  -- colors loop
  for index, buffer in ipairs(buffers) do
    if buffer.id == nil then -- unloaded buffer
      vim.api.nvim_buf_add_highlight(state.window.buf, -1, "LineNr", index - 1, 0, -1)
    end

    vim.api.nvim_buf_add_highlight(state.window.buf, -1, "Constant", index - 1, 0, leader_key_length) -- shortcut
  end

  if line_active then
    vim.api.nvim_buf_add_highlight(state.window.buf, -1, "Label", line_active, leader_key_length + 1, -1)
  end

  update_dimensions(longest_word_length, #buffers)
end

--- Sets up the UI state with the provided configuration.
---@param opts BuffonConfig The configuration options.
M.setup = function(opts)
  state.config = opts
  state.window = { buf = vim.api.nvim_create_buf(false, true), id = nil }
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
end

--- Shows the window, or hides them if they are already visible.
M.show = function()
  if state.window.id and not vim.api.nvim_win_is_valid(state.window.id) then
    state.window.id = nil
  end

  if state.window.id then
    M.hide()
    return
  end

  state.window.id = vim.api.nvim_open_win(state.window.buf, false, window_options)

  M.refresh()
end

return M
