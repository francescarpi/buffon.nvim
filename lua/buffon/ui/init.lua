local api = require("buffon.api")

local M = {}

---@class BuffonWindow
---@field buf number
---@field win number | nil

---@class BuffonUIState
---@field config BuffonConfig
---@field container BuffonWindow
---@field content BuffonWindow
local state = {}

--- Returns the window options for the container and content windows.
---@return table
local wins_options = function()
  return {
    {
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
    },
    {
      relative = "editor",
      width = 1,
      height = 1,
      col = 1,
      row = 1,
      style = "minimal",
      zindex = 2,
      focusable = false,
    },
  }
end

--- Updates the height of the specified window.
---@param win number The window ID.
---@param height number The new height for the window.
local update_height = function(win, height)
  if height == 0 then
    height = 1
  end
  vim.api.nvim_win_set_height(win, height)
end

--- Updates the width of the container and content windows.
---@param width number The new width for the windows.
local update_width = function(width)
  local editor_width = vim.api.nvim_get_option("columns")

  local container_cfg = vim.api.nvim_win_get_config(state.container.win)
  container_cfg.width = width
  container_cfg.col = editor_width - width - 2
  vim.api.nvim_win_set_config(state.container.win, container_cfg)

  local content_cfg = vim.api.nvim_win_get_config(state.content.win)
  content_cfg.width = width - (#state.config.keybindings.buffer_mapping.leader_key + 2)
  content_cfg.col = editor_width - width + (#state.config.keybindings.buffer_mapping.leader_key + 1)
  vim.api.nvim_win_set_config(state.content.win, content_cfg)
end

--- Refreshes the container window with the buffer shortcuts.
---@param buffers table<BuffonBuffer> The list of buffers.
local refresh_container = function(buffers)
  local lines = {}
  for index, _ in ipairs(buffers) do
    local shortcut = state.config.keybindings.buffer_mapping.mapping_chars:sub(index, index)
    if shortcut ~= "" then
      shortcut = state.config.keybindings.buffer_mapping.leader_key .. shortcut
    end
    table.insert(lines, shortcut)
  end

  vim.api.nvim_buf_set_lines(state.container.buf, 0, -1, false, lines)

  for line = 0, #lines do
    vim.api.nvim_buf_add_highlight(state.container.buf, -1, "Constant", line, 0, -1)
  end

  update_height(state.container.win, #buffers)
end

--- Refreshes the content window with the buffer filenames.
---@param buffers table<BuffonBuffer> The list of buffers.
---@param index_buffers_by_name table<string, number> A table mapping buffer names to their indices.
local refresh_content = function(buffers, index_buffers_by_name)
  local lines = {}
  local width = 18 + #state.config.keybindings.buffer_mapping.leader_key

  local line_active = nil
  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf then
    local current_buf_name = vim.api.nvim_buf_get_name(current_buf)
    local buffer_index = index_buffers_by_name[current_buf_name]
    if buffer_index ~= nil then
      line_active = buffer_index - 1
    end
  end

  for _, buffer in ipairs(buffers) do
    local fn = buffer.filename
    if api.are_duplicated_filenames() then
      fn = buffer.short_path
    end

    table.insert(lines, fn)
    if #fn >= width then
      width = #fn + 4
    end
  end

  if #lines == 0 then
    lines = { "No buffers..." }
  end

  vim.api.nvim_buf_set_lines(state.content.buf, 0, -1, false, lines)

  if line_active then
    vim.api.nvim_buf_add_highlight(state.content.buf, -1, "Title", line_active, 0, -1)
  end

  update_height(state.content.win, #buffers)
  update_width(width)
end

--- Sets up the UI state with the provided configuration.
---@param opts BuffonConfig The configuration options.
M.setup = function(opts)
  state.config = opts
  state.container = { buf = vim.api.nvim_create_buf(false, true), win = nil }
  state.content = { buf = vim.api.nvim_create_buf(false, true), win = nil }
end

--- Refreshes the container and content windows with the current buffer list.
M.refresh = function()
  if state.container.win and state.content.win then
    local buffers = api.get_buffers_list()
    local buffers_by_name = api.get_index_buffers_by_name()
    refresh_container(buffers)
    refresh_content(buffers, buffers_by_name)
  end
end

--- Hides the container and content windows.
M.hide = function()
  vim.api.nvim_win_close(state.content.win, true)
  vim.api.nvim_win_close(state.container.win, true)
  state.content.win = nil
  state.container.win = nil
end

--- Shows the container and content windows, or hides them if they are already visible.
M.show = function()
  if state.content.win and not vim.api.nvim_win_is_valid(state.content.win) then
    state.container.win = nil
    state.content.win = nil
  end

  if state.container.win ~= nil then
    M.hide()
    return
  end

  local opts = wins_options()
  state.container.win = vim.api.nvim_open_win(state.container.buf, false, opts[1])
  state.content.win = vim.api.nvim_open_win(state.content.buf, false, opts[2])

  M.refresh()
end

return M
