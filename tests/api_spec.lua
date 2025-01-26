local eq = assert.are.same
local api = require("buffon.api")
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
  }
end

---@param index number
---@param buffer BuffonTestBuffer
local check_buffer = function(index, buffer)
  eq(api.get_buffer_by_index(index), test_buffer_to_buffon_buffer(buffer))
  eq(api.get_index_by_name(buffer.path), index)
end

local add_buffers = function(buffers)
  for _, buffer in ipairs(buffers) do
    api.add_buffer(buffer.path, buffer.id)
  end
end

local check_initial_state = function(buffers)
  eq(#api.get_buffers(), #buffers)
  for i, buffer in ipairs(buffers) do
    check_buffer(i, buffer)
  end
end

local buffer1 = { path = "/home/foo/buffer1", id = 98, name = "buffer1", short_path = "/h/f/buffer1" }
local buffer2 = { path = "/home/foo/buffer2", id = 97, name = "buffer2", short_path = "/h/f/buffer2" }
local buffer3 = { path = "/home/foo/buffer3", id = 96, name = "buffer3", short_path = "/h/f/buffer3" }
local buffer4 = { path = "/home/boo/buffer3", id = 96, name = "buffer3", short_path = "/h/b/buffer3" }

api.setup()

describe("api", function()
  it("full test", function()
    local buffers = { buffer1, buffer2, buffer3 }
    add_buffers(buffers)
    api.add_buffer("", 100) -- blank buffer

    check_initial_state(buffers)

    -- start tests
    eq(api.get_buffer_by_index(99), nil)

    -- buffer2 is deleted and buffer3's index will be set to 1 (instead 2)
    api.delete_buffer(buffer2.path)
    eq(#api.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
    eq(api.get_buffer_by_index(3), nil)

    -- buffer1 is deleted. only buffer3 will be present with index 0
    api.delete_buffer("/home/foo/buffer1")
    eq(#api.get_buffers(), 1)
    check_buffer(1, buffer3)

    -- finally, if buffer3 is deleted, the buffers's list will be empty
    api.delete_buffer("/home/foo/buffer3")
    eq(#api.get_buffers(), 0)
  end)

  it("change order", function()
    local buffers = { buffer1, buffer2, buffer3 }
    add_buffers(buffers)
    check_initial_state(buffers)

    -- buffer1 is moved to up
    api.move_buffer_up("/home/foo/buffer1")
    check_initial_state(buffers)

    -- buffer2 is moved to up
    api.move_buffer_up("/home/foo/buffer2")
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
    check_buffer(3, buffer3)

    -- buffer3 to down
    api.move_buffer_down("/home/foo/buffer3")
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
    check_buffer(3, buffer3)

    -- buffer1 to down
    api.move_buffer_down("/home/foo/buffer1")
    check_buffer(1, buffer2)
    check_buffer(2, buffer3)
    check_buffer(3, buffer1)

    -- move buffer1 at top
    api.move_buffer_top("/home/foo/buffer1")
    check_initial_state(buffers)

    --- move buffer1 at bottom
    api.move_buffer_bottom("/home/foo/buffer1")
    check_buffer(1, buffer2)
    check_buffer(2, buffer3)
    check_buffer(3, buffer1)
  end)

  it("prepend buffers", function()
    local opts = config.opts()
    api.setup(vim.tbl_deep_extend("force", opts, { prepend_buffers = true }))
    add_buffers({ buffer1, buffer2 })
    check_buffer(1, buffer2)
    check_buffer(2, buffer1)
  end)

  it("duplicated buffer names", function()
    api.setup()
    add_buffers({ buffer1, buffer3 })
    eq(api.are_duplicated_filenames(), false)
    add_buffers({ buffer4 })
    eq(api.are_duplicated_filenames(), true)
  end)

  it("prevent add duplicated buffers", function()
    api.setup()
    add_buffers({ buffer1, buffer3 })
    eq(#api.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
    add_buffers({ buffer1 })
    eq(#api.get_buffers(), 2)
    check_buffer(1, buffer1)
    check_buffer(2, buffer3)
  end)

  it("update buffer id", function()
    api.setup()
    add_buffers({ { path = "/foo/bar.json", id = nil } })
    eq(#api.get_buffers(), 1)
    check_buffer(1, { path = "/foo/bar.json", id = nil, name = "bar.json", short_path = "/f/bar.json" })

    add_buffers({ { path = "/foo/bar.json", id = 1 } })
    eq(#api.get_buffers(), 1)
    check_buffer(1, { path = "/foo/bar.json", id = 1, name = "bar.json", short_path = "/f/bar.json" })
  end)

  it("next/prev buffers", function()
    -- no cyclic
    api.setup()
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(api.get_next_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer3))
    eq(api.get_next_buffer(buffer3.path), nil)
    eq(api.get_previous_buffer(buffer2.path), test_buffer_to_buffon_buffer(buffer1))
    eq(api.get_previous_buffer(buffer1.path), nil)

    -- cyclic
    local opts = config.opts()
    api.setup(vim.tbl_deep_extend("force", opts, { cyclic_navigation = true }))
    add_buffers({ buffer1, buffer2, buffer3 })

    eq(api.get_next_buffer(buffer3.path), test_buffer_to_buffon_buffer(buffer1))
    eq(api.get_previous_buffer(buffer1.path), test_buffer_to_buffon_buffer(buffer3))
  end)

  it("useful methods to close buffers", function()
    api.setup()
    add_buffers({ buffer1, buffer2, buffer3 })
    eq(api.get_buffers_above(buffer3.path), {
      test_buffer_to_buffon_buffer(buffer1),
      test_buffer_to_buffon_buffer(buffer2),
    })
    eq(api.get_buffers_above(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer1),
    })
    eq(api.get_buffers_above(buffer1.path), {})

    eq(api.get_buffers_below(buffer1.path), {
      test_buffer_to_buffon_buffer(buffer2),
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(api.get_buffers_below(buffer2.path), {
      test_buffer_to_buffon_buffer(buffer3),
    })
    eq(api.get_buffers_below(buffer3.path), {})
  end)

  it("rename buffers", function()
    api.setup()
    add_buffers({ buffer1 })
    check_buffer(1, buffer1)

    api.rename_buffer("/home/foo/buffer1", "/home/foo/buffer1.1")
    check_buffer(1, { path = "/home/foo/buffer1.1", id = 98, name = "buffer1.1", short_path = "/h/f/buffer1.1" })
  end)
end)
