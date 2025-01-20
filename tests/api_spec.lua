local eq = assert.are.same
local api = require("buffon.api")

local table_length = function(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

describe("api", function()
	it("full test", function()
		-- 3 + 1(blank) buffers are added, but there only have to be 3 (the blank is ignored)
		for i = 1, 3 do
			api.add_buffer("buffer" .. i, 99 - i)
		end
		api.add_buffer("", 100)
		eq(table_length(api.get_buffers_by_name()), 3)
		eq(api.buffers_counter(), 3)

		-- check orderings
		eq(api.get_buffer_by_order(0).id, 98)
		eq(api.get_buffer_by_order(0).name, "buffer1")
		eq(api.get_buffer_by_order(1).id, 97)
		eq(api.get_buffer_by_order(1).name, "buffer2")
		eq(api.get_buffer_by_order(2).id, 96)
		eq(api.get_buffer_by_order(2).name, "buffer3")
		eq(api.get_buffer_by_order(99), nill)

		-- buffer2 is deleted and buffer3's order will be set to 1 (instead 2)
		api.delete_buffer("buffer2")
		eq(table_length(api.get_buffers_by_name()), 2)
		eq(table_length(api.get_buffers_by_order()), 2)
		eq(api.buffers_counter(), 2)

		eq(api.get_buffer_by_name("buffer1").order, 0)
		eq(api.get_buffer_by_name("buffer2"), nil)
		eq(api.get_buffer_by_name("buffer3").order, 1)
		eq(api.get_buffer_by_order(0).name, "buffer1")
		eq(api.get_buffer_by_order(1).name, "buffer3")
		eq(api.get_buffer_by_order(2), nil)

		-- buffer1 is deleted. only buffer3 will be present with order 0
		api.delete_buffer("buffer1")
		eq(table_length(api.get_buffers_by_name()), 1)
		eq(table_length(api.get_buffers_by_order()), 1)
		eq(api.buffers_counter(), 1)

		eq(api.get_buffer_by_order(0).name, "buffer3")
		eq(api.get_buffer_by_name("buffer3").order, 0)
		eq(api.get_buffer_by_name("buffer1"), nil)
		eq(api.get_buffer_by_order(1), nil)

		-- finally, if buffer3 is deleted, the buffers's list will be empty
		api.delete_buffer("buffer3")
		eq(table_length(api.get_buffers_by_name()), 0)
		eq(table_length(api.get_buffers_by_order()), 0)
		eq(api.buffers_counter(), 0)
	end)

	it("change order", function()
		for i = 1, 3 do
			api.add_buffer("buffer" .. i, 99 - i)
		end

		local check_order = function(name, order)
			eq(api.get_buffer_by_name(name).order, order)
			eq(api.get_buffer_by_order(order).name, name)
		end

		eq(api.buffers_counter(), 3)
		check_order("buffer1", 0)
		check_order("buffer2", 1)
		check_order("buffer3", 2)

		-- buffer1 is moved to up
		api.move_buffer_up("buffer1")
		check_order("buffer1", 0)
		check_order("buffer2", 1)
		check_order("buffer3", 2)

		-- buffer2 is moved to up
		api.move_buffer_up("buffer2")
		check_order("buffer2", 0)
		check_order("buffer1", 1)
		check_order("buffer3", 2)

		-- buffer3 to down
		api.move_buffer_down("buffer3")
		check_order("buffer2", 0)
		check_order("buffer1", 1)
		check_order("buffer3", 2)

		-- buffer1 to down
		api.move_buffer_down("buffer1")
		check_order("buffer2", 0)
		check_order("buffer3", 1)
		check_order("buffer1", 2)

		-- move buffer1 on top
		api.move_buffer_top("buffer1")
		check_order("buffer1", 0)
		check_order("buffer2", 1)
		check_order("buffer3", 2)
	end)
end)
