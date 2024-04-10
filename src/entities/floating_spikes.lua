function add_all_spikes()
    add_floating_spike(two_point_path(44, 61, 53, 61), 2)
    add_floating_spike(two_point_path(64, 62, 90, 62), 0.3)
    add_floating_spike(two_point_path(35, 60, 35, 55), 1)
    add_floating_spike(two_point_path(63, 56, 71, 56), 2)
    add_floating_spike(two_point_path(74, 57, 89, 57), 2)
    local phase = 0
    for x = 75, 91 do
        add_floating_spike(two_point_path(x, 54, x, 52), .8, phase)
	phase += 0.09
    end
    add_floating_spike(two_point_path(66, 26, 66, 20), 2)
    add_floating_spike(two_point_path(86, 29, 86, 25), 2)
    add_floating_spike(two_point_path(96, 23, 108, 23), 2)
    add_floating_spike(two_point_path(98, 21, 98, 29), 2)
end

function two_point_path(x1, y1, x2, y2)
    return {{x = x1 * 8, y = y1 * 8}, {x = x2 * 8, y = y2 * 8}}
end

function four_point_path(x1, y1, x2, y2)
    return {
        {x = x1 * 8, y = y1 * 8},
        {x = x1 * 8, y = y2 * 8},
        {x = x2 * 8, y = y2 * 8},
        {x = x2 * 8, y = y1 * 8}
    }
end

function n_point_path(n, x_array, y_array)
    path = {}
    for i = 1, n do 
        path[i].x = x_array[i] * 8
        path[i].y = y_array[i] * 8
    end
    return path
end

function add_floating_spike(path, speed, phase)
    local x_positions = {}
    local y_positions = {}
    for point in all(path) do 
        add(x_positions, point.x)
        add(y_positions, point.y)
    end
    add(floating_spikes, {
        x_path = x_positions,
        y_path = y_positions,
        x = x_positions[1],
        y = y_positions[1],
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
            
            -- Interpolate between the current and next point
            self.x = lerp(self.x_path[self.current_point_index], self.x_path[(self.current_point_index % self.path_length) + 1], self.t)
            self.y = lerp(self.y_path[self.current_point_index], self.y_path[(self.current_point_index % self.path_length) + 1], self.t)
            
            -- Update animation frame
            self.frame_timer = self.frame_timer + dt
            if self.frame_timer >= self.frame_duration then
                self.frame_timer = self.frame_timer - self.frame_duration
                self.frame = (self.frame % self.num_frames) + 1
            end
        end,
        draw = function(self)
            -- Draw the current frame of the object's animation
            spr(self.sprite_sheet[self.frame], self.x, self.y)
        end
    })
end
    
