local eq = assert.are.same
local api = require("buffon.api")

local check_buffer = function(index, id, name)
	eq(api.get_buffer_by_index(index), { id = id, name = name, short_name = name, filename = name })
	eq(api.get_index_by_name(name), index)
end

describe("api", function()
	it("full test", function()
		-- 3 + 1(blank) buffers are added, but there only have to be 3 (the blank is ignored)
		for i = 1, 3 do
			api.add_buffer("buffer" .. i, 99 - i)
		end
		api.add_buffer("", 100)

		-- initial state
		eq(#api.get_buffers_list(), 3)
		check_buffer(1, 98, "buffer1")
		check_buffer(2, 97, "buffer2")
		check_buffer(3, 96, "buffer3")

		-- start tests
		eq(api.get_buffer_by_index(99), nil)

		-- buffer2 is deleted and buffer3's index will be set to 1 (instead 2)
		api.delete_buffer("buffer2")
		eq(#api.get_buffers_list(), 2)
		check_buffer(1, 98, "buffer1")
		check_buffer(2, 96, "buffer3")
		eq(api.get_buffer_by_index(3), nil)

		-- buffer1 is deleted. only buffer3 will be present with index 0
		api.delete_buffer("buffer1")
		eq(#api.get_buffers_list(), 1)
		check_buffer(1, 96, "buffer3")

		-- finally, if buffer3 is deleted, the buffers's list will be empty
		api.delete_buffer("buffer3")
		eq(#api.get_buffers_list(), 0)
	end)

	it("change order", function()
		for i = 1, 3 do
			api.add_buffer("buffer" .. i, 99 - i)
		end

		-- initial state
		eq(#api.get_buffers_list(), 3)
		check_buffer(1, 98, "buffer1")
		check_buffer(2, 97, "buffer2")
		check_buffer(3, 96, "buffer3")

		-- buffer1 is moved to up
		api.move_buffer_up("buffer1")
		check_buffer(1, 98, "buffer1")
		check_buffer(2, 97, "buffer2")
		check_buffer(3, 96, "buffer3")

		-- buffer2 is moved to up
		api.move_buffer_up("buffer2")
		check_buffer(1, 97, "buffer2")
		check_buffer(2, 98, "buffer1")
		check_buffer(3, 96, "buffer3")

		-- buffer3 to down
		api.move_buffer_down("buffer3")
		check_buffer(1, 97, "buffer2")
		check_buffer(2, 98, "buffer1")
		check_buffer(3, 96, "buffer3")

		-- buffer1 to down
		api.move_buffer_down("buffer1")
		check_buffer(1, 97, "buffer2")
		check_buffer(2, 96, "buffer3")
		check_buffer(3, 98, "buffer1")

		-- move buffer1 on top
		api.move_buffer_top("buffer1")
		check_buffer(1, 98, "buffer1")
		check_buffer(2, 97, "buffer2")
		check_buffer(3, 96, "buffer3")
	end)
end)
