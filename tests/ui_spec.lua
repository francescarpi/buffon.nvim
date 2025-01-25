local eq = assert.are.same
local api = require("buffon.api")
local ui = require("buffon.ui")
local config = require("buffon.config")

describe("ui", function()
  it("content", function()
    config.setup()
    local opts = config.opts()
    api.setup()
    ui.setup(opts)

    for i = 1, 10 do
      api.add_buffer("/foo/buffer" .. i, i)
    end

    eq(ui.get_content(api.get_buffers(), api.get_index_buffers_by_name()), {
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
        ";q buffer1 ",
        ";w buffer2 ",
        ";e buffer3 ",
        ";r buffer4 ",
        ";y buffer5 ",
        ";u buffer6 ",
        ";i buffer7 ",
        ";o buffer8 ",
        ";p buffer9 ",
        "   buffer10 ",
      },
      longest_word_length = 10,
    })
  end)
end)
