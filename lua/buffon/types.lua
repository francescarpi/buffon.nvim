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
---@field next_group string
---@field previous_group string
---@field move_to_previous_group string
---@field move_to_next_group string

---@class BuffonConfig
---@field cyclic_navigation boolean -- If true, navigation between buffers will wrap around (cyclic navigation).
---@field new_buffer_position "start" | "end" | "after"
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

---@class BuffonMainWindowContent
---@field lines table<string>
---@field line_active number
---@field filenames table<string>

---@class BuffonIndexBuffersByName
---@field index number
---@field group number

---@class BuffonBuffersState
---@field index_buffers_by_name table<string, BuffonIndexBuffersByName>
---@field buffers table<table<BuffonBuffer>>
---@field config? BuffonConfigState
---@field storage? BuffonStorage
---@field active_group number
---@field max_groups number

---@class BuffonHelpState
---@field window? Window
---@field content_rendered boolean

---@class BuffonKeybindingsState
---@field config? BuffonConfigState

---@class BuffonActionsState
---@field last_closed? BuffonLastClosedList
---@field last_used? BuffonBuffer

---@class BuffonTestBuffer
---@field path string
---@field id? number
---@field name string
---@field short_path string

---@class BuffonState
---@field buf_will_rename? string
---@field storage? BuffonStorage
---@field buffer_activea? number
