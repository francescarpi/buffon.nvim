local eq = assert.are.same
local page = require("buffon.page")
local buffer = require("buffon.buffer")
local config = require("buffon.config")

describe("page", function()
  it("empty list", function()
    local cfg = config.Config:new()
    local pag = page.Page:new(cfg)
    local render = pag:render()
    eq(render.content, { " No buffers... " })
  end)

  it("basic render", function()
    local cfg = config.Config:new({ new_buffer_position = "end" })
    local pag = page.Page:new(cfg)

    for i = 1, 10 do
      pag:add_buffer(buffer.Buffer:new(i, "/foo/buffer" .. i .. ".lua"))
    end
    pag:get_buffers()[1].id = nil

    ---@type BuffonPageRender
    local render = pag:render("/foo/buffer2.lua")
    eq(render.content, {
      ";q buffer1.lua  ",
      ";w buffer2.lua  ",
      ";e buffer3.lua  ",
      ";r buffer4.lua  ",
      ";y buffer5.lua  ",
      ";u buffer6.lua  ",
      ";i buffer7.lua  ",
      ";o buffer8.lua  ",
      ";p buffer9.lua  ",
      "   buffer10.lua ",
    })

    eq(render.highlights.Constant, {
      {
        col_end = 2,
        col_start = 0,
        line = 1,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 2,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 3,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 4,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 5,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 6,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 7,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 8,
      },
      {
        col_end = 2,
        col_start = 0,
        line = 9,
      },
    })

    eq(render.highlights.ErrorMsg, {})

    eq(render.highlights.Label, {
      {
        col_end = 18,
        col_start = 3,
        line = 1,
      },
    })

    eq(render.highlights.LineNr, {
      {
        col_end = 18,
        col_start = 0,
        line = 0,
      },
    })
  end)
end)
