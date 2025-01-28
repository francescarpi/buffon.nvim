local eq = assert.are.same
local buffers = require("buffon.buffers")
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

---@param index number
---@param buffer BuffonTestBuffer
local check_buffer = function(index, buffer)
  eq(buffers.get_buffer_by_index(index), test_buffer_to_buffon_buffer(buffer))
  eq(buffers.get_index_by_name(buffer.path), index)
end

local add_buffers = function(buffers_to_add)
  for _, buffer in ipairs(buffers_to_add) do
    buffers.add_buffer(buffer.path, buffer.id)
  end
end

local check_initial_state = function(buffers_to_check)
  eq(#buffers.get_buffers(), #buffers_to_check)
  for i, buffer in ipairs(buffers_to_check) do
    check_buffer(i, buffer)
  end
end

local buffer1 = { path = "/home/foo/buffer1", id = 98, name = "buffer1", short_path = "/h/f/buffer1" }
local buffer2 = { path = "/home/foo/buffer2", id = 97, name = "buffer2", short_path = "/h/f/buffer2" }
local buffer3 = { path = "/home/foo/buffer3", id = 96, name = "buffer3", short_path = "/h/f/buffer3" }
local buffer4 = { path = "/home/boo/buffer3", id = 96, name = "buffer3", short_path = "/h/b/buffer3" }

describe("api", function()
  it("full test", function()
    local cfg = config.setup()
    buffers.setup(cfg)

    local buffers_to_add = { buffer1, buffer2, buffer3 }
    add_buffers(buffers_to_add)
    buffers.add_buffer("", 100) -- blank buffer

    check_initial_state(buffers_to_add)

    -- start tests
    eq(buffers.get_buffer_by_index(99), nil)

    -- buffer2 is deleted and buffer3's index will be set to 1 (instead 2)
    buffers.delete_buffer(buffer2.path)
    eq(#buffers.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
    eq(buffers.get_buffer_by_index(3), nil)

    -- buffer1 is deleted. only buffer3 will be present with index 0
    buffers.delete_buffer("/home/foo/buffer1")
    eq(#buffers.get_buffers(), 1)
    check_buffer(1, buffer3)

    -- finally, if buffer3 is deleted, the buffers's list will be empty
    buffers.delete_buffer("/home/foo/buffer3")
    eq(#buffers.get_buffers(), 0)
  end)

  it("change order", function()
    local cfg = config.setup()
    buffers.setup(cfg)

    local buffers_to_add = { buffer1, buffer2, buffer3 }
    add_buffers(buffers_to_add)
    check_initial_state(buffers_to_add)

    -- buffer1 is moved to up
    buffers.move_buffer_up("/home/foo/buffer1")
    check_initial_state(buffers_to_add)

    -- buffer2 is moved to up
    buffers.move_buffer_up("/home/foo/buffer2")
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
    check_buffer(3, buffer3)

    -- buffer3 to down
    buffers.move_buffer_down("/home/foo/buffer3")
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
    check_buffer(3, buffer3)

    -- buffer1 to down
    buffers.move_buffer_down("/home/foo/buffer1")
    check_buffer(1, buffer2)
    check_buffer(2, buffer3)
    check_buffer(3, buffer1)

    -- move buffer1 at top
    buffers.move_buffer_top("/home/foo/buffer1")
    check_initial_state(buffers_to_add)

    --- move buffer1 at bottom
    buffers.move_buffer_bottom("/home/foo/buffer1")
    check_buffer(1, buffer2)
    check_buffer(2, buffer3)
    check_buffer(3, buffer1)
  end)

  it("prepend buffers", function()
    local cfg = config.setup({ prepend_buffers = true })
    buffers.setup(cfg)
    add_buffers({ buffer1, buffer2 })
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
  end)

  it("prevent add duplicated buffers", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    add_buffers({ buffer1, buffer3 })
    eq(#buffers.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
    add_buffers({ buffer1 })
    eq(#buffers.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
  end)

  it("update buffer id", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    add_buffers({ { path = "/foo/bar.json", id = nil } })
    eq(#buffers.get_buffers(), 1)
    check_buffer(1, { path = "/foo/bar.json", id = nil, name = "bar.json", short_path = "/f/bar.json" })

    add_buffers({ { path = "/foo/bar.json", id = 1 } })
    eq(#buffers.get_buffers(), 1)
    check_buffer(1, { path = "/foo/bar.json", id = 1, name = "bar.json", short_path = "/f/bar.json" })
  end)

  it("next/prev buffers", function()
    -- no cyclic
    local cfg1 = config.setup()
    buffers.setup(cfg1)
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(buffers.get_next_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer3))
    eq(buffers.get_next_buffer(buffer3.path), nil)
    eq(buffers.get_previous_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer1))
    eq(buffers.get_previous_buffer(buffer1.path), nil)

    -- cyclic
    local cfg2 = config.setup({ cyclic_navigation = true })
    buffers.setup(cfg2)
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(buffers.get_next_buffer(buffer3.path), test_buffer_to_buffon_buffer(buffer1))
    eq(buffers.get_previous_buffer(buffer1.path), test_buffer_to_buffon_buffer(buffer3))
  end)

  it("useful methods to close buffers", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    add_buffers({ buffer1, buffer2, buffer3 })
    eq(buffers.get_buffers_above(buffer3.path), {
      test_buffer_to_buffon_buffer(buffer1),
      test_buffer_to_buffon_buffer(buffer2),
    })
    eq(buffers.get_buffers_above(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer1),
    })
    eq(buffers.get_buffers_above(buffer1.path), {})

    eq(buffers.get_buffers_below(buffer1.path), {
      test_buffer_to_buffon_buffer(buffer2),
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(buffers.get_buffers_below(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(buffers.get_buffers_below(buffer3.path), {})
  end)

  it("rename buffers", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    add_buffers({ buffer1 })
    check_buffer(1, buffer1)

    buffers.rename_buffer("/home/foo/buffer1", "/home/foo/buffer1.1")
    check_buffer(1, { path = "/home/foo/buffer1.1", id = 98, name = "buffer1.1", short_path = "/h/f/buffer1.1" })
  end)

  it("update cursor", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    add_buffers({ buffer1 })
    eq(buffers.get_buffer_by_index(1).cursor, { 1, 1 })
    buffers.update_cursor(buffer1.path, { 2, 2 })
    eq(buffers.get_buffer_by_index(1).cursor, { 2, 2 })
  end)

  it("buffers validation", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    eq(
      buffers.validate_buffers({
        {
          name = "foo",
          short_path = "foo",
          cursor = { 1, 1 },
          short_name = "foo",
          filename = "foo",
        },
      }),
      true
    )
    eq(
      buffers.validate_buffers({
        {
          name = "foo",
          short_path = "foo",
          cursor = { 1, 1 },
          short_name = "foo",
          filename = "foo",
          id = 1,
        },
      }),
      true
    )
    eq(
      buffers.validate_buffers({
        {
          name = "foo",
          short_path = "foo",
          cursor = { 1, 1 },
          short_name = "foo",
          filename = 1,
        },
      }),
      false
    )
    eq(
      buffers.validate_buffers({
        {
          name = "foo",
          short_path = "foo",
          short_name = "foo",
          filename = "foo",
          id = 1,
        },
      }),
      false
    )
  end)
end)
