---@class BuffonBuffer
---@field id number
---@field name string
---@field short_name string
---@field filename string
---@field short_path string
---@field cursor [number, number] | nil

---@class BuffonConfigKeyBindingBufferMapping
---@field mapping_chars string -- Each character maps to a buffer ("qwer" maps 'q' to buffer 1, 'w' to buffer 2, etc.)
---@field leader_key string -- Leader key used as a prefix for buffer mappings (';' creates mappings ';q', ';w', etc.)

---@class BuffonConfigOpen
---@field by_default boolean
---@field ignore_ft table<string>

---@class BuffonConfigKeyBinding
---@field goto_next_buffer string
---@field goto_previous_buffer string
---@field move_buffer_up string
---@field move_buffer_down string
---@field move_buffer_top string
---@field toggle_buffon_window string
---@field switch_previous_used_buffer string
---@field close_buffer string
---@field close_buffers_above string
---@field close_buffers_below string
---@field close_all_buffers string
---@field close_others string
---@field restore_last_closed_buffer string
---@field buffer_mapping BuffonConfigKeyBindingBufferMapping
---@field show_help string

---@class BuffonConfig
---@field cyclic_navigation boolean -- If true, navigation between buffers will wrap around (cyclic navigation).
---@field prepend_buffers boolean -- If true, new buffers are added at the first position, shifting existing buffers.
---@field open BuffonConfigOpen
---@field keybindings BuffonConfigKeyBinding

---@class BuffonConfigState
---@field opts BuffonConfig

---@class BuffonKeybinding
---@field lhs string
---@field rhs function | string
---@field help string

---@class BuffonUIState
---@field config? BuffonConfigState
---@field window? Window

---@class BuffonUIGetContent
---@field lines table<string>
---@field line_active number
---@field filenames table<string>

---@class BuffonBuffersState
---@field index_buffers_by_name table<string, number>
---@field buffers table<BuffonBuffer>
---@field config? BuffonConfigState
---@field are_duplicated_filenames boolean
---@field storage? BuffonStorage

---@class BuffonHelpState
---@field window? Window
---@field content_rendered boolean

---@class BuffonKeybindingsState
---@field config? BuffonConfigState

---@class BuffonActionsState
---@field last_closed? BuffonLastClosedList

---@class BuffonTestBuffer
---@field path string
---@field id? number
---@field name string
---@field short_path string

---@class BuffonState
---@field buf_will_rename string | nil
---@field storage BuffonStorage | nil
