local eq = assert.are.same
local api_buffers = require("buffon.api.buffers")
local config = require("buffon.config")

---@param buffer BuffonTestBuffer
---@return BuffonBuffer
local test_buffer_to_buffon_buffer = function(buffer)
  return {
    id = buffer.id,
    name = buffer.path,
    short_name = buffer.path,
    filename = buffer.name,
    short_path = buffer.short_path,
    cursor = { 1, 1 },
  }
end

---@param group number
---@param index number
---@param buffer BuffonTestBuffer
local check_buffer = function(group, index, buffer)
  eq(api_buffers.get_buffer_by_group_and_index(group, index), test_buffer_to_buffon_buffer(buffer))
  eq(api_buffers.get_index_and_group_by_name(buffer.path).index, index)
end

local add_buffers = function(buffers_to_add)
  for _, buffer in ipairs(buffers_to_add) do
    api_buffers.add_buffer(buffer.path, buffer.id)
  end
end

local check_initial_state = function(buffers_to_check)
  eq(#api_buffers.get_buffers_of_group(1), #buffers_to_check)
  for i, buffer in ipairs(buffers_to_check) do
    check_buffer(1, i, buffer)
  end
end

local buffer1 = { path = "/home/foo/buffer1", id = 98, name = "buffer1", short_path = "/h/f/buffer1" }
local buffer2 = { path = "/home/foo/buffer2", id = 97, name = "buffer2", short_path = "/h/f/buffer2" }
local buffer3 = { path = "/home/foo/buffer3", id = 96, name = "buffer3", short_path = "/h/f/buffer3" }

describe("buffers", function()
  it("full test", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)

    local buffers_to_add = { buffer1, buffer2, buffer3 }
    add_buffers(buffers_to_add)
    api_buffers.add_buffer("", 100) -- blank buffer

    check_initial_state(buffers_to_add)

    -- start tests
    eq(api_buffers.get_buffer_by_group_and_index(1, 99), nil)

    -- buffer2 is deleted and buffer3's index will be set to 1 (instead 2)
    api_buffers.del.delete_buffer(buffer2.path)
    eq(#api_buffers.get_buffers_of_group(1), 2)
    check_buffer(1, 1, buffer1)
    check_buffer(1, 2, buffer3)
    eq(api_buffers.get_buffer_by_group_and_index(1, 3), nil)

    -- buffer1 is deleted. only buffer3 will be present with index 0
    api_buffers.del.delete_buffer("/home/foo/buffer1")
    eq(#api_buffers.get_buffers_of_group(1), 1)
    check_buffer(1, 1, buffer3)

    -- finally, if buffer3 is deleted, the buffers's list will be empty
    api_buffers.del.delete_buffer("/home/foo/buffer3")
    eq(#api_buffers.get_buffers_of_group(1), 0)
  end)

  it("change order", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)

    local buffers_to_add = { buffer1, buffer2, buffer3 }
    add_buffers(buffers_to_add)
    check_initial_state(buffers_to_add)

    -- buffer1 is moved to up
    api_buffers.move.move_buffer_up("/home/foo/buffer1")
    check_initial_state(buffers_to_add)

    -- buffer2 is moved to up
    api_buffers.move.move_buffer_up("/home/foo/buffer2")
    check_buffer(1, 1, buffer2)
    check_buffer(1, 2, buffer1)
    check_buffer(1, 3, buffer3)

    -- buffer3 to down
    api_buffers.move.move_buffer_down("/home/foo/buffer3")
    check_buffer(1, 1, buffer2)
    check_buffer(1, 2, buffer1)
    check_buffer(1, 3, buffer3)

    -- buffer1 to down
    api_buffers.move.move_buffer_down("/home/foo/buffer1")
    check_buffer(1, 1, buffer2)
    check_buffer(1, 2, buffer3)
    check_buffer(1, 3, buffer1)

    -- move buffer1 at top
    api_buffers.move.move_buffer_top("/home/foo/buffer1")
    check_initial_state(buffers_to_add)

    --- move buffer1 at bottom
    api_buffers.move.move_buffer_bottom("/home/foo/buffer1")
    check_buffer(1, 1, buffer2)
    check_buffer(1, 2, buffer3)
    check_buffer(1, 3, buffer1)
  end)

  it("new buffer position", function()
    local cfg = config.setup({ new_buffer_position = "start" })
    api_buffers.setup(cfg)
    api_buffers.add_buffer(buffer1.path, buffer1.id, nil)
    api_buffers.add_buffer(buffer2.path, buffer2.id, 1)
    api_buffers.add_buffer(buffer3.path, buffer3.id, 2)
    check_buffer(1, 1, buffer3)
    check_buffer(1, 2, buffer2)
    check_buffer(1, 3, buffer1)

    local cfg2 = config.setup({ new_buffer_position = "end" })
    api_buffers.setup(cfg2)
    api_buffers.add_buffer(buffer1.path, buffer1.id, nil)
    api_buffers.add_buffer(buffer2.path, buffer2.id, 1)
    api_buffers.add_buffer(buffer3.path, buffer3.id, 2)
    check_buffer(1, 1, buffer1)
    check_buffer(1, 2, buffer2)
    check_buffer(1, 3, buffer3)

    local cfg3 = config.setup({ new_buffer_position = "after" })
    api_buffers.setup(cfg3)
    api_buffers.add_buffer(buffer1.path, buffer1.id, nil)
    api_buffers.add_buffer(buffer2.path, buffer2.id, 1)
    api_buffers.add_buffer(buffer3.path, buffer3.id, 1)
    check_buffer(1, 1, buffer1)
    check_buffer(1, 2, buffer3)
    check_buffer(1, 3, buffer2)
  end)

  it("prevent add duplicated buffers", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ buffer1, buffer3 })
    eq(#api_buffers.get_buffers_of_group(1), 2)
    check_buffer(1, 1, buffer1)
    check_buffer(1, 2, buffer3)
    add_buffers({ buffer1 })
    eq(#api_buffers.get_buffers_of_group(1), 2)
    check_buffer(1, 1, buffer1)
    check_buffer(1, 2, buffer3)
  end)

  it("update buffer id", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ { path = "/foo/bar.json", id = nil } })
    eq(#api_buffers.get_buffers_of_group(1), 1)
    check_buffer(1, 1, { path = "/foo/bar.json", id = nil, name = "bar.json", short_path = "/f/bar.json" })

    add_buffers({ { path = "/foo/bar.json", id = 1 } })
    eq(#api_buffers.get_buffers_of_group(1), 1)
    check_buffer(1, 1, { path = "/foo/bar.json", id = 1, name = "bar.json", short_path = "/f/bar.json" })
  end)

  it("next/prev buffers", function()
    -- no cyclic
    local cfg1 = config.setup()
    api_buffers.setup(cfg1)
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(api_buffers.nav.get_next_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer3))
    eq(api_buffers.nav.get_next_buffer(buffer3.path), nil)
    eq(api_buffers.nav.get_previous_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer1))
    eq(api_buffers.nav.get_previous_buffer(buffer1.path), nil)

    -- cyclic
    local cfg2 = config.setup({ cyclic_navigation = true })
    api_buffers.setup(cfg2)
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(api_buffers.nav.get_next_buffer(buffer3.path), test_buffer_to_buffon_buffer(buffer1))
    eq(api_buffers.nav.get_previous_buffer(buffer1.path), test_buffer_to_buffon_buffer(buffer3))
  end)

  it("useful methods to close buffers", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ buffer1, buffer2, buffer3 })
    eq(api_buffers.del.get_buffers_above(buffer3.path), {
      test_buffer_to_buffon_buffer(buffer1),
      test_buffer_to_buffon_buffer(buffer2),
    })
    eq(api_buffers.del.get_buffers_above(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer1),
    })
    eq(api_buffers.del.get_buffers_above(buffer1.path), {})

    eq(api_buffers.del.get_buffers_below(buffer1.path), {
      test_buffer_to_buffon_buffer(buffer2),
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(api_buffers.del.get_buffers_below(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(api_buffers.del.get_buffers_below(buffer3.path), {})
  end)

  it("rename buffers", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ buffer1 })
    check_buffer(1, 1, buffer1)

    api_buffers.rename_buffer("/home/foo/buffer1", "/home/foo/buffer1.1")
    check_buffer(1, 1, { path = "/home/foo/buffer1.1", id = 98, name = "buffer1.1", short_path = "/h/f/buffer1.1" })
  end)

  it("update cursor", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ buffer1 })
    eq(api_buffers.get_buffer_by_group_and_index(1, 1).cursor, { 1, 1 })
    api_buffers.update_cursor(buffer1.path, { 2, 2 })
    eq(api_buffers.get_buffer_by_group_and_index(1, 1).cursor, { 2, 2 })
  end)

  it("buffers validation", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)

    local all_good_1, _ = pcall(api_buffers.validate_buffers, {
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo" } },
      {},
      {},
    })
    eq(all_good_1, true)

    local all_good_2, _ = pcall(api_buffers.validate_buffers, {
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo", id = 1 } },
      {},
      {},
    })
    eq(all_good_2, true)

    local id_is_missing, _ = pcall(api_buffers.validate_buffers, {
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = 1 }, {}, {} },
      {},
      {},
    })
    eq(id_is_missing, false)

    local cursor_is_missing, _ = pcall(api_buffers.validate_buffers, {
      { { name = "foo", short_path = "foo", short_name = "foo", filename = "foo", id = 1 }, {}, {} },
      {},
      {},
    })
    eq(cursor_is_missing, false)

    local invalid_groups_length, _ = pcall(api_buffers.validate_buffers, {
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo" } },
      {},
    })
    eq(invalid_groups_length, false)
  end)

  it("move buffers between groups", function()
    local cfg = config.setup()
    api_buffers.setup(cfg)
    add_buffers({ buffer1 })

    eq(#api_buffers.get_buffers_of_group(1), 1)
    eq(#api_buffers.get_buffers_of_group(2), 0)
    eq(#api_buffers.get_buffers_of_group(3), 0)

    api_buffers.groups.move_to_next_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 0)
    eq(#api_buffers.get_buffers_of_group(2), 1)
    eq(#api_buffers.get_buffers_of_group(3), 0)

    api_buffers.groups.move_to_next_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 0)
    eq(#api_buffers.get_buffers_of_group(2), 0)
    eq(#api_buffers.get_buffers_of_group(3), 1)

    api_buffers.groups.move_to_next_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 1)
    eq(#api_buffers.get_buffers_of_group(2), 0)
    eq(#api_buffers.get_buffers_of_group(3), 0)

    api_buffers.groups.move_to_previous_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 0)
    eq(#api_buffers.get_buffers_of_group(2), 0)
    eq(#api_buffers.get_buffers_of_group(3), 1)

    api_buffers.groups.move_to_previous_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 0)
    eq(#api_buffers.get_buffers_of_group(2), 1)
    eq(#api_buffers.get_buffers_of_group(3), 0)

    api_buffers.groups.move_to_previous_group(buffer1.path)
    eq(#api_buffers.get_buffers_of_group(1), 1)
    eq(#api_buffers.get_buffers_of_group(2), 0)
    eq(#api_buffers.get_buffers_of_group(3), 0)
  end)
end)
