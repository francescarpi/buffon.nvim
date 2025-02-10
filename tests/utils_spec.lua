local eq = assert.are.same
local utils = require("buffon.utils")

describe("utils", function()
  it("last closed list", function()
    local list = utils.RecentlyClosed:new(3)
    list:add("/foo/bar1.json")
    list:add("/foo/bar2.json")
    list:add("/foo/bar3.json")
    list:add("/foo/bar4.json")
    eq(#list.filenames, 3)
    eq(list.filenames, { "/foo/bar2.json", "/foo/bar3.json", "/foo/bar4.json" })

    list:add("/foo/bar4.json")
    eq(#list.filenames, 3)
    eq(list.filenames, { "/foo/bar2.json", "/foo/bar3.json", "/foo/bar4.json" })

    eq(list:get_last(), "/foo/bar4.json")
    eq(list:get_last(), "/foo/bar3.json")
    eq(list:get_last(), "/foo/bar2.json")
    eq(list:get_last(), nil)
  end)
end)
