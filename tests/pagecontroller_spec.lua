local eq = assert.are.same
local pagecontroller = require("buffon.pagecontroller")
local config = require("buffon.config")
local buffer = require("buffon.buffer")

local buf1 = buffer.Buffer:new(1, "buffer1.lua")
local buf2 = buffer.Buffer:new(2, "buffer2.lua")

describe("page controller", function()
  it("instantation", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    eq(pagectrl:num_pages(), 2)
  end)

  it("add page", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    eq(#pagectrl:get_page(1):get_buffers(), 0)
    eq(#pagectrl:get_page(2):get_buffers(), 0)

    pagectrl:add_buffer(2, buffer.Buffer:new(1, "/foo/boo/buffer1.json"))
    eq(#pagectrl:get_page(2):get_buffers(), 1)
  end)

  it("get data", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:add_buffer(2, buffer.Buffer:new(1, "/foo/boo/buffer1.json"))
    eq(pagectrl:get_data(), {
      {},
      {
        {
          id = 1,
          name = "/foo/boo/buffer1.json",
          short_name = "/foo/boo/buffer1.json",
          short_path = "/f/b/buffer1.json",
          filename = "buffer1.json",
          cursor = { 1, 1 },
        },
      },
    })
  end)

  it("set data", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:set_data({
      {
        {
          id = 1,
          name = "/foo/boo/buffer1.json",
          short_name = "/foo/boo/buffer1.json",
          short_path = "/f/b/buffer1.json",
          filename = "buffer1.json",
          cursor = { 1, 1 },
        },
      },
      {},
    })
    eq(#pagectrl:get_page(1):get_buffers(), 1)
    eq(#pagectrl:get_page(2):get_buffers(), 0)
  end)

  it("validate data", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)

    local all_good_1, _ = pagectrl:validate_data({
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo" } },
      {},
      {},
    })
    eq(all_good_1, true)

    local all_good_2, _ = pagectrl:validate_data({
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo", id = 1 } },
      {},
      {},
    })
    eq(all_good_2, true)

    local id_is_missing, _ = pagectrl:validate_data({
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = 1 }, {}, {} },
      {},
      {},
    })
    eq(id_is_missing, false)

    local cursor_is_missing, _ = pagectrl:validate_data({
      { { name = "foo", short_path = "foo", short_name = "foo", filename = "foo", id = 1 }, {}, {} },
      {},
      {},
    })
    eq(cursor_is_missing, false)

    local invalid_groups_length, _ = pagectrl:validate_data({
      { { name = "foo", short_path = "foo", cursor = { 1, 1 }, short_name = "foo", filename = "foo" } },
    })
    eq(invalid_groups_length, false)
  end)

  it("navigate", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:add_buffer_to_active_page(buf1)
    pagectrl:next_page()
    pagectrl:add_buffer_to_active_page(buf2)

    pagectrl:next_page()
    eq(pagectrl.active, 1)
    eq(#pagectrl:get_active_page():get_buffers(), 1)
    eq(pagectrl:get_active_page():get_buffers()[1], buf1)

    pagectrl:next_page()
    eq(pagectrl.active, 2)
    eq(#pagectrl:get_active_page():get_buffers(), 1)
    eq(pagectrl:get_active_page():get_buffers()[1], buf2)

    pagectrl:previous_page()
    eq(pagectrl.active, 1)
  end)

  it("move buffers to other pages", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:add_buffer_to_active_page(buf1)

    eq(#pagectrl:get_page(1):get_buffers(), 1)
    eq(#pagectrl:get_page(2):get_buffers(), 0)

    pagectrl:move_to_next_page(buf1.name)
    eq(#pagectrl:get_page(1):get_buffers(), 0)
    eq(#pagectrl:get_page(2):get_buffers(), 1)

    pagectrl:next_page()
    pagectrl:move_to_next_page(buf1.name)
    eq(#pagectrl:get_page(1):get_buffers(), 1)
    eq(#pagectrl:get_page(2):get_buffers(), 0)

    pagectrl:next_page()
    pagectrl:move_to_previous_page(buf1.name)
    eq(#pagectrl:get_page(1):get_buffers(), 0)
    eq(#pagectrl:get_page(2):get_buffers(), 1)
  end)

  it("find buffer and page", function()
    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:add_buffer(2, buf1)
    eq(pagectrl.active, 1)
    local buf, page = pagectrl:get_buffer_and_page(buf1.name)
    eq(buf, buf1)
    eq(page, 2)
  end)
end)
