local eq = assert.are.same
local buffer = require("buffon.buffer")

describe("buffer", function()
  it("abbreviate path", function()
    eq(buffer.abbreviate_path("/foo/bar/zoo/file.json"), "/f/b/z/file.json")
    eq(buffer.abbreviate_path("/foo/bar/[id]/file.json"), "/f/b/[i]/file.json")
    eq(buffer.abbreviate_path("/foo/bar/zoo/too/file.json"), "/b/z/t/file.json")
    eq(buffer.abbreviate_path("/foo/bar/zoo/too/moo/file.json"), "/z/t/m/file.json")
    eq(buffer.abbreviate_path("/foo-boo/file.json"), "/f-b/file.json")
    eq(buffer.abbreviate_path("/foo-boo/file-boo.json"), "/f-b/file-boo.json")
  end)
end)
