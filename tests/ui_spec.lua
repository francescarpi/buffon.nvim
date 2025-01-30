local eq = assert.are.same
local buffers = require("buffon.buffers")
local ui = require("buffon.ui.main")
local config = require("buffon.config")

describe("ui", function()
  it("content", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    ui.setup(cfg)

    for i = 1, 10 do
      buffers.add_buffer("/foo/buffer" .. i, i)
    end

    eq(ui.get_content(buffers.get_buffers(), buffers.get_index_buffers_by_name()), {
      filenames = {
        "buffer1",
        "buffer2",
        "buffer3",
        "buffer4",
        "buffer5",
        "buffer6",
        "buffer7",
        "buffer8",
        "buffer9",
        "buffer10",
      },
      lines = {
        ";q buffer1    ",
        ";w buffer2    ",
        ";e buffer3    ",
        ";r buffer4    ",
        ";y buffer5    ",
        ";u buffer6    ",
        ";i buffer7    ",
        ";o buffer8    ",
        ";p buffer9    ",
        "   buffer10    ",
      },
    })
  end)

  it("repeated buffer names", function()
    local cfg = config.setup()
    buffers.setup(cfg)
    ui.setup(cfg)

    buffers.add_buffer("/foo/boo/buffer1", 1)
    buffers.add_buffer("/foo/boo/buffer2", 2)
    eq(ui.ger_buffer_names(buffers.get_buffers()), { "buffer1", "buffer2" })

    buffers.add_buffer("/foo/zoo/buffer2", 3)
    eq(ui.ger_buffer_names(buffers.get_buffers()), { "buffer1", "/f/b/buffer2", "/f/z/buffer2" })

    buffers.add_buffer("/foo/roo/buffer2", 4)
    buffers.add_buffer("/foo/boo/buffer3", 5)
    eq(ui.ger_buffer_names(buffers.get_buffers()), {
      "buffer1",
      "/f/b/buffer2",
      "/f/z/buffer2",
      "/f/r/buffer2",
      "buffer3",
    })
  end)
end)
