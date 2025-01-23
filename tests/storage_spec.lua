local eq = assert.are.same
local storage = require("buffon.storage")
local Path = require("plenary.path")
local api = require("buffon.api")

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
    stg:init()
    eq(p:exists(), true)
    p:rmdir()
    eq(p:exists(), false)
  end)

  it("save and load data", function()
    local path = "/tmp/buffon-tmp"
    local stg = storage.Storage:new("/foo/boo", path)
    stg:init()
    api.setup(nil, stg)
    eq(api.get_buffers(), {})

    api.add_buffer("/foo/bar/sample.py", 1)
    api.add_buffer("/foo/bar/readme.txt", 2)

    local buffers = stg:load()
    eq(buffers, {
      {
        filename = "sample.py",
        id = nil,
        name = "/foo/bar/sample.py",
        short_name = "/foo/bar/sample.py",
        short_path = "/f/b/sample.py",
      },
      {
        filename = "readme.txt",
        id = nil,
        name = "/foo/bar/readme.txt",
        short_name = "/foo/bar/readme.txt",
        short_path = "/f/b/readme.txt",
      },
    })

    Path:new(path):rm({ recursive = true })
  end)
end)
