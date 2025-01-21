local eq = assert.are.same
local config = require("buffon.config")

describe("config", function()
	it("defaults options", function()
		config.setup({})
		local opts = config.opts()
		eq(opts, { cyclic_navigation = false, leader_key = ";", buffer_mappings_chars = "qwer", prepend_buffers = false })
	end)

	it("custom options", function()
		config.setup({ cyclic_navigation = true, leader_key = "m", buffer_mappings_chars = "asdf", prepend_buffers = true })
		local opts = config.opts()
		eq(opts, { cyclic_navigation = true, leader_key = "m", buffer_mappings_chars = "asdf", prepend_buffers = true })
	end)
end)
