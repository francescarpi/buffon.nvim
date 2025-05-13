local eq = assert.are.same
local bufferslist = require("buffon.bufferslist")
local config = require("buffon.config")
local buffer = require("buffon.buffer")

local buf1 = buffer.Buffer:new(1, "buffer1.lua")
local buf2 = buffer.Buffer:new(2, "buffer2.lua")
local buf3 = buffer.Buffer:new(3, "buffer3.lua")
local buf4 = buffer.Buffer:new(4, "buffer4.lua")

describe("buffers list", function()
  it("instantation", function()
    local cfg = config.Config:new()
    local list = bufferslist.BuffersList:new(cfg)
    eq(#list.buffers, 0)
    eq(list.buffers, {})
  end)

  it("add buffers at position: start", function()
    local cfg = config.Config:new({ new_buffer_position = "start" })
    local list = bufferslist.BuffersList:new(cfg)

    list:add(buf1, nil)
    list:add(buf2, 1)
    list:add(buf3, 2)

    eq(#list.buffers, 3)
    eq(list.buffers[1], buf3)
    eq(list.buffers[2], buf2)
    eq(list.buffers[3], buf1)
  end)

  it("add buffers at position: end", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)

    list:add(buf1, nil)
    list:add(buf2, 1)
    list:add(buf3, 2)

    eq(list.buffers[1], buf1)
    eq(list.buffers[2], buf2)
    eq(list.buffers[3], buf3)
  end)

  it("add buffers at position: after", function()
    local cfg = config.Config:new({ new_buffer_position = "after" })
    local list = bufferslist.BuffersList:new(cfg)

    list:add(buf1, nil)
    list:add(buf2, 1)
    list:add(buf3, 1)

    eq(list.buffers[1], buf1)
    eq(list.buffers[2], buf3)
    eq(list.buffers[3], buf2)
  end)

  it("add existing buffer", function()
    local cfg = config.Config:new({ new_buffer_position = "after" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    eq(list.buffers[1].id, 1)
    eq(#list.buffers, 1)

    list:add(buffer.Buffer:new(4, "buffer1.lua"))
    eq(#list.buffers, 1)
    eq(list.buffers[1].id, 4)
  end)

  it("get index", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    eq(list:get_index(buf1.name), nil)

    list:add(buf1)
    list:add(buf2)
    eq(list:get_index(buf1.name), 1)
    eq(list:get_index(buf2.name), 2)
  end)

  it("remove", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:remove(buf2.name)
    eq(#list.buffers, 1)
    eq(list.buffers[1], buf1)
  end)

  it("move up", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)

    list:move_up(buf2.name)
    eq(list.buffers[1], buf2)
    eq(list.buffers[2], buf1)
    eq(list.buffers[3], buf3)

    list:move_up(buf2.name)
    eq(list.buffers[1], buf2)
    eq(list.buffers[2], buf1)
    eq(list.buffers[3], buf3)
  end)

  it("move top", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)

    list:move_top(buf3.name)
    eq(list.buffers[1], buf3)
    eq(list.buffers[2], buf1)
    eq(list.buffers[3], buf2)
  end)

  it("move down", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)

    list:move_down(buf2.name)
    eq(list.buffers[1], buf1)
    eq(list.buffers[2], buf3)
    eq(list.buffers[3], buf2)

    list:move_down(buf2.name)
    eq(list.buffers[1], buf1)
    eq(list.buffers[2], buf3)
    eq(list.buffers[3], buf2)
  end)

  it("move bottom", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)

    list:move_bottom(buf1.name)
    eq(list.buffers[1], buf2)
    eq(list.buffers[2], buf3)
    eq(list.buffers[3], buf1)
  end)

  it("get next/previous", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)

    eq(list:get_next_buffer(buf1.name), buf2)
    eq(list:get_next_buffer(buf2.name), buf3)
    eq(list:get_next_buffer(buf3.name), buf1)

    eq(list:get_previous_buffer(buf2.name), buf1)
    eq(list:get_previous_buffer(buf1.name), buf3)
  end)

  it("get buffers above", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)
    eq(list:get_buffers_above(buf3.name), { buf1, buf2 })
    eq(list:get_buffers_above(buf1.name), {})
  end)

  it("get buffers below", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)
    eq(list:get_buffers_below(buf1.name), { buf2, buf3 })
    eq(list:get_buffers_below(buf3.name), {})
  end)

  it("get other buffer ", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:add(buf2)
    list:add(buf3)
    eq(list:get_other_buffers(buf2.name), { buf1, buf3 })
  end)

  it("rename", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    list:rename(buf1.name, "/foo/boo/buffer1-1.lua")
    eq(#list.buffers, 1)
    eq(list.buffers[1], {
      id = 4,
      name = "/foo/boo/buffer1-1.lua",
      short_name = "/foo/boo/buffer1-1.lua",
      short_path = "/f/b/buffer1-1.lua",
      filename = "buffer1-1.lua",
      cursor = { 1, 1 },
    })
  end)

  it("update cursor position", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local list = bufferslist.BuffersList:new(cfg)
    list:add(buf1)
    eq(list.buffers[1].cursor, { 1, 1 })

    list:update_cursor(buf1.name, { 2, 5 })
    eq(list.buffers[1].cursor, { 2, 5 })
  end)

  it("add after wrong position", function()
    local cfg = config.Config:new({ new_buffer_position = "after" })
    local list = bufferslist.BuffersList:new(cfg)
    eq(list.buffers, {})
    list:add(buf1, 1)
    eq(list.buffers, { buf1 })
  end)

  it("ignore buffer names", function()
    local cfg = config.Config:new({})
    local list = bufferslist.BuffersList:new(cfg)
    eq(list.buffers, {})

    list:add(buffer.Buffer:new(1, "diffpanel_3"))
    list:add(buffer.Buffer:new(1, "/foo/bar/diffpanel_3"))
    eq(list.buffers, {})
  end)

  it("add buffers having unloaded buffers", function()
    -- initial state
    local cfg = config.Config:new({ sort_buffers_by_loaded_status = true })
    local list = bufferslist.BuffersList:new(cfg)

    list:set_buffers({
      buffer.Buffer:new(nil, "buffer1.lua"),
      buffer.Buffer:new(nil, "buffer2.lua"),
    })

    eq(list.buffers[1].id, nil)
    eq(list.buffers[2].id, nil)

    -- add buffer3. the expected buffers list, should be: buffer3, buffer1, buffer2
    list:add(buf3)
    eq(list.buffers[1].id, buf3.id)
    eq(list.buffers[2].id, nil)
    eq(list.buffers[3].id, nil)

    -- add buffer4. the expected buffers list, should be: buffer3, buffer4, buffer1, buffer2
    list:add(buf4)
    eq(list.buffers[1].id, buf3.id)
    eq(list.buffers[2].id, buf4.id)
    eq(list.buffers[3].id, nil)
    eq(list.buffers[4].id, nil)
  end)
end)
