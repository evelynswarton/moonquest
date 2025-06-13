spk_dat={
	{2,44,61,53,61,2},
	{2,64,62,90,62,0.3},
	{2,35,60,35,55,1},
	{2,63,56,71,56,2},
	{2,74,57,89,57,2},
	{2,66,26,66,20,2},
	{2,86,29,86,25,2},
	{2,96,23,108,23,2},
	{2,98,21,98,29,2},
	{2,95,41,95,33,2},
	{2,82,36,82,33,1},
	{2,72,42,76,42,1.5},
	{2,95,51,95,47,2},
	{2,97,47,97,51,2},
	{2,67,50,67,47,2},
	{2,113,28,113,31,2},
	{2,117,28,117,31,2},
	{2,121,28,121,31,2},
	{2,101,9,101,17,4},
	{2,96,17,96,9,4},
	{2,84,3,90,3,2},
	{4,97,3,99,5,8},
	{2,114,8,118,8,4},
	{2,116,9,116,0,4},
	{'n',{106,111,111,110,110,109,109,108,108,106},{0,0,6,6,5,5,4,4,3,3},30}
}

function add_spk(s)
	if (s[1]==2) add_floating_spike(two_point_path(s[2],s[3],s[4],s[5]),s[6])
	if (s[1]==4) add_floating_spike(four_point_path(s[2],s[3],s[4],s[5]),s[6])
	if (s[1]=='n') add_floating_spike(n_point_path(s[2],s[3]),s[4])
end

function add_all_spikes()
	local phase=0
	for x=75,91 do
		add_floating_spike(two_point_path(x, 54, x, 52), .8, phase)
		phase += 0.09
	end
	foreach(spk_dat,add_spk)
	--serialize_fl_spikes()
end

function serialize_fl_spikes()
	s='fl_spk_dat=[=['
	for fl_spk in all(floating_spikes) do
		s=s..fl_spk:serialize()
	end
	return s..']=]'
end

function two_point_path(x1, y1, x2, y2)
	return {{x=x1*8,y=y1*8},{x=x2*8,y=y2*8}}
end

function four_point_path(x1, y1, x2, y2)
	return {
		{x = x1 * 8, y = y1 * 8},
		{x = x1 * 8, y = y2 * 8},
		{x = x2 * 8, y = y2 * 8},
		{x = x2 * 8, y = y1 * 8}
	}
end

function n_point_path(xs,ys)
	path={}
	for i=1,#xs do 
		path[i]={
			x=xs[i]*8,
			y=ys[i]*8
		}
	end
	return path
end

function add_floating_spike(path,speed,phase)
	local x_positions={}
	local y_positions={}
	for p in all(path) do 
		add(x_positions,p.x)
		add(y_positions,p.y)
	end
	add(floating_spikes, {
		x_path=x_positions,
		y_path=y_positions,
		x=x_positions[1],
		y=y_positions[1],
		w = 8,
		h = 8,
		path_length = #x_positions,
		speed = speed,
		t = phase or 0,  -- Parameter for interpolation (0 to 1)
		current_point_index = 1,
		frame = 1,  -- Current frame of animation
		frame_duration = .05,  -- Time between frame changes
		frame_timer = 0,  -- Timer for frame changes
		sprite_sheet = {105, 106, 121, 122},  -- Your sprite sheet image
		num_frames = 4,  -- Total number of frames in animation
		update = function(self, dt)
			local dt = 1/60
			self.t = self.t + self.speed * dt / self.path_length
			-- If self.t exceeds 1, wrap around and adjust it
			if self.t >= 1 then
				self.current_point_index = self.current_point_index + 1
				if self.current_point_index > self.path_length then
					self.current_point_index = 1 -- Wrap around to the beginning
				end
				while self.t >= 1 do
					self.t -= 1
				end
			end
			self.x = lerp(self.x_path[self.current_point_index], self.x_path[(self.current_point_index % self.path_length) + 1], self.t)
			self.y = lerp(self.y_path[self.current_point_index], self.y_path[(self.current_point_index % self.path_length) + 1], self.t)

			self.frame_timer = self.frame_timer + dt
			if self.frame_timer >= self.frame_duration then
				self.frame_timer = self.frame_timer - self.frame_duration
				self.frame = (self.frame % self.num_frames) + 1
			end
		end,
		draw = function(self)
			spr(self.sprite_sheet[self.frame], self.x, self.y)
		end,
		serialize = function(self)
			-- first char: path_length
			s=enc95(self.path_length)
			for i=1,self.path_length do
				x=cel(self.x_path[i])
				y=cel(self.y_path[i])
				s=s..xy_pair_enc(x,y)
			end
			s=s..':'..s.speed..':'..s.t
			return s
		end
	})
end

