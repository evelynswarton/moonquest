fan_dat = {
	{ 72, 29, 0, 0.3 },
	{ 83, 30, 0, 0.3 },
	{ 88, 29, 0, 0.3 },
	{ 98, 28, 0, 0.3 },
	{ 114, 36, 0, 0.3 },
	{ 118, 36, 0, 0.3 },
	{ 85, 50, 0, 0.3 },
	{ 102, 63, 0, 0.3 },
	{ 116, 63, 0, 0.3 },
	{ 118, 63, 0, 0.3 },
	{ 120, 63, 0, 0.3 },
	{ 122, 63, 0, 0.3 },
	{ 125, 62, 0, 0.3 },
	{ 126, 43, 0, 0.3 },
	{ 126, 43, 0, 0.3 },
	{ 87, 17, 0, 0.3 },
}

function add_all_fans()
	for y = 50, 27, -8 do
		add_fan(63, y, 0, 0.3)
	end
	for f in all(fan_dat) do
		add_fan(f[1], f[2], f[3], f[4])
	end
end

function add_fan(x, y, r, f)
	add(fans, {
		x = x * 8,
		y = y * 8,
		force = f,
		field = { x = x * 8, y = y * 8 - 80, w = 16, h = 80 },
		rot = r % 4,
		sprite_sheet = { 89, 90, 91, 75, 91, 90, 89 },
		anim_idx = 0,
		frame = 0,
		draw = function(self)
			--pset(cam.x+1,cam.y+1,7)
			pal(6, 13)
			pal(7, 6)
			pal(13, 5)
			local secondary_anim_idx = (self.anim_idx + 2) % 4
			spr(self.sprite_sheet[self.anim_idx + 1], self.x, self.y)
			--spr(self.sprite_sheet[secondary_anim_idx+1],self.x+8,self.y,1,1,true)
			pal(6, 6)
			pal(7, 7)
			pal(13, 13)
			spr(self.sprite_sheet[secondary_anim_idx + 1], self.x, self.y)
			pal(6, 13)
			pal(7, 6)
			pal(13, 5)
			spr(self.sprite_sheet[secondary_anim_idx + 1], self.x + 8, self.y, 1, 1, true)
			pal(6, 6)
			pal(7, 7)
			pal(13, 13)
			spr(self.sprite_sheet[self.anim_idx + 1], self.x + 8, self.y, 1, 1, true)
			if debug_on then
				local f = self.field
				rect(f.x, f.y, f.x + f.w, f.y + f.h, debug_color)
			end
		end,
		update = function(self)
			self.frame += 1
			if self.frame >= 6 then
				self.frame = 0
				self.anim_idx += 1
				self.anim_idx = self.anim_idx % #self.sprite_sheet
			end
			if rnd(100) < 20 then
				local x, y, dx, dy
				if self.rot == 0 then
					x = self.x + rnd(16)
					y = self.y - 2
					dx = 0
					dy = self.force
				elseif self.rot == 1 then
				elseif self.rot == 2 then
				elseif self.rot == 3 then
				else
					error("fan rotation invalid")
				end

				add_dust(x, y, dx, dy)
			end
		end,
	})
end
