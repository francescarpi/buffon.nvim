local eq = assert.are.same
local storage = require("buffon.storage")

describe("storage", function()
  it("check filenames", function()
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
end)
