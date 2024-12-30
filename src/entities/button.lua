--[[
	Lock:
		A lock that accepts a key. Then the gate is
		open via destroying each block in a contiguous
		region.
		Attributes:
				x : int [x tile of lock] 
				y : int [y tile of lock]
			xtarg : int [x tile of first block in gate]
			ytarg : int [y tile of first block in gate]

]]

-- Data for locks
lockdat = {
	{ 20, 59, 22, 56 },
	{ 0, 62, 1, 61 },
	{ 94, 62, 91, 59 },
	{ 93, 62, 91, 59 },
	{ 92, 62, 91, 59 },
	{ 105, 34, 102, 32 },
	{ 103, 48, 102, 48 },
	{ 103, 48, 103, 51 },
	{ 80, 18, 78, 17 },
	{ 80, 18, 74, 17 },
}
function add_all_buttons()
	foreach(lockdat, function(b)
		add_button(b[1], b[2], b[3], b[4])
	end)
end

function add_button(x_tile, y_tile, x_target, y_target)
	add(buttons, {
		x = x_tile * 8,
		y = y_tile * 8,
		w = 8,
		h = 8,
		acitve = false,
		up_spr = 104,
		down_spr = 123,
		target_x = x_target,
		target_y = y_target,
		draw = function(self)
			local x, y = self.x, self.y
			if self.active then
				spr(self.down_spr, x, y)
			else
				spr(self.up_spr, x, y)
			end
		end,
		update = function(self)
			local active = false
			for ib in all(interactive_blocks) do
				if touch(self, ib) then
					active = true
					destroy_target(self.target_x, self.target_y)
				end
			end
			self.active = active
		end,
	})
end

function destroy_target(x, y)
	curr_block = mget(x, y)
	if curr_block == 107 then
		mset(x, y, 0)
		destroy_target(x - 1, y)
		destroy_target(x + 1, y)
		destroy_target(x, y - 1)
		destroy_target(x, y + 1)
		for i = 1, 10 do
			dust_x = x * 8 + rnd(8)
			dust_y = y * 8 + rnd(8)
			add_dust(dust_x, dust_y, 0, 0)
		end
	end
end
