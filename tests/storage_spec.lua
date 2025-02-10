local eq = assert.are.same
local storage = require("buffon.storage")
local Path = require("plenary.path")
local config = require("buffon.config")
local pagecontroller = require("buffon.pagecontroller")
local buffer = require("buffon.buffer")

describe("storage", function()
  it("filenames", function()
    local tests = {
      { workspace = "/", filename = "root.json" },
      { workspace = "/foo/boo/", filename = "foo-boo.json" },
      { workspace = "/foo/boò/", filename = "foo-bo.json" },
      { workspace = "c:\\foo\\boo", filename = "c-foo-boo.json" },
      { workspace = "c:\\foo zoo\\boo", filename = "c-foo-zoo-boo.json" },
      { workspace = "/foo/" .. string.rep("a", 300) .. "/", filename = "foo-" .. string.rep("a", 146) .. ".json" },
    }

    for _, test in ipairs(tests) do
      local stg = storage.Storage:new(test.workspace)
      eq(stg:filename(), test.filename)
    end
  end)

  it("filename path", function()
    local stg = storage.Storage:new("/foo/boo")
    local expected_path = "/nvim/buffon/foo-boo.json"
    eq(stg:filename_path():sub(-#expected_path), expected_path)
  end)

  it("data path", function()
    local path = "/tmp/buffon-tmp"
    local stg = storage.Storage:new("/foo/boo", path)
    local p = Path:new(path)
    eq(p:exists(), false)
    local success = stg:init()
    eq(success, true)
    eq(p:exists(), true)
    p:rmdir()
    eq(p:exists(), false)
  end)

  it("save & load", function()
    local path = "/tmp/buffon-tmp"
    local stg = storage.Storage:new("/foo/boo", path)
    local success = stg:init()
    eq(success, true)

    local cfg = config.Config:new()
    local pagectrl = pagecontroller.PageController:new(cfg)
    pagectrl:add_buffer(2, buffer.Buffer:new(1, "/foo/boo/buffer1.json"))

    stg:save(pagectrl:get_data())

    local loaded_data = stg:load()
    eq(loaded_data, {
      {},
      {
        {
          id = nil,
          name = "/foo/boo/buffer1.json",
          short_name = "/foo/boo/buffer1.json",
          short_path = "/f/b/buffer1.json",
          filename = "buffer1.json",
          cursor = { 1, 1 },
        },
      },
    })

    Path:new(path):rm({ recursive = true })
  end)
end)
