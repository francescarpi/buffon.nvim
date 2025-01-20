local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
	it("default opts", function()
		local opts = config.opts()
		eq(opts.cyclic_navigation, false)
	end)
end)
