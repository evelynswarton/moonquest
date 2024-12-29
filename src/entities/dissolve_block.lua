dissolve_respawn_duration = 360

function init_dissolve_blocks()
	for xt = 0, 127 do
		for yt = 0, 63 do
			if mget(xt, yt) == 54 then
				add_dissolve_block(xt, yt)
				mset(xt, yt, 0)
			end
		end
	end
end

function add_dissolve_block(x, y)
	add(dissolve_blocks, {
		x = x * 8,
		y = y * 8,
		x_tile = x,
		y_tile = y,
		w = 8,
		h = 8,
		hb = {
			x = (x * 8) - 1,
			y = (y * 8) - 1,
			w = 10,
			h = 2,
		},
		durability = 3,
		respawn_timer = 0,
		touching_player = false,
		update = function(self)
			if not self.touching_player then
				if touch(self.hb, player) then
					self.touching_player = true
				end
			else
				if not touch(self.hb, player) then
					self.touching_player = false
					self.durability -= 1
				end
			end
			if not controls_on then
				self.durability = 3
			end
			if self.durability > 2 then
				mset(self.x_tile, self.y_tile, 54)
			elseif self.durability > 1 then
				mset(self.x_tile, self.y_tile, 32)
			elseif self.durability > 0 then
				mset(self.x_tile, self.y_tile, 17)
			else
				mset(self.x_tile, self.y_tile, 0)
				if self.respawn_timer == 0 then
					for i = 1, 10 do
						local x = self.x + rnd(8)
						local y = self.y + rnd(8)
						add_dust(x, y, 0, 0)
					end
				end
				self.durability = 0
				self.respawn_timer += 1
				if self.respawn_timer >= dissolve_respawn_duration then
					self.respawn_timer = 0
					self.durability = 3
				end
			end
		end,
	})
end
