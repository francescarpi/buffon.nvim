local eq = assert.are.same
local utils = require("buffon.utils")

describe("utils", function()
  it("abbreviate path", function()
    eq(utils.abbreviate_path("/foo/bar/zoo/file.json"), "/f/b/z/file.json")
    eq(utils.abbreviate_path("/foo/bar/[id]/file.json"), "/f/b/[id]/file.json")
    eq(utils.abbreviate_path("/foo/bar/zoo/too/file.json"), "/b/z/t/file.json")
    eq(utils.abbreviate_path("/foo/bar/zoo/too/moo/file.json"), "/z/t/m/file.json")
  end)
end)
