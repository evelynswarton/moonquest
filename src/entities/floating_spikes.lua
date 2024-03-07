-- path = {pos1, pos2, ..., posn}
-- pos = {x = ?, y = ?}
function add_all_spikes()
    add_floating_spike(two_point_path(44, 61, 53, 61), 2)
    add_floating_spike(two_point_path(64, 62, 90, 62), 0.3)
    add_floating_spike(two_point_path(77, 63, 77, 59), 2)
    add_floating_spike(two_point_path(84, 63, 84, 59), 2)
    add_floating_spike(two_point_path(35, 60, 35, 55), 1)
    add_floating_spike(two_point_path(63, 56, 71, 56), 2)
    add_floating_spike(four_point_path(60, 59, 65, 63), 2)
    add_floating_spike(two_point_path(74, 57, 89, 57), 2)
    --[[
    add_floating_spike({
        {x = 16 * 8, y = 2 * 8},
        {x = 23 * 8, y = 2 * 8},
        {x = 30 * 8, y = 2 * 8},
        {x = 37 * 8, y = 2 * 8},
        {x = 45 * 8, y = 2 * 8},
        {x = 45 * 8, y = 4 * 8},
        {x = 37 * 8, y = 4 * 8},
        {x = 30 * 8, y = 4 * 8},
        {x = 23 * 8, y = 4 * 8},
        {x = 16 * 8, y = 4 * 8}}, 12)
    add_floating_spike({
        {x = 19 * 8, y = 1 * 8},
        {x = 19 * 8, y = 5 * 8}}, 2)
    add_floating_spike({
        {x = 23 * 8, y = 5 * 8},
        {x = 23 * 8, y = 1 * 8}}, 2)
    add_floating_spike({
        {x = 27 * 8, y = 1 * 8},
        {x = 27 * 8, y = 5 * 8}}, 2)
    add_floating_spike({
        {x = 31 * 8, y = 5 * 8},
        {x = 31 * 8, y = 1 * 8}}, 2)
    add_floating_spike({
        {x = 33 * 8, y = 6 * 8},
        {x = 43 * 8, y = 6 * 8}}, 1)
    --add_floating_spike(four_point_path(43, 16, 48, 11), 2)
    --add_floating_spike(four_point_path(44, 15, 47, 12), 2)
    add_floating_spike(two_point_path(43, 11, 48, 11), 1.7)
    for i,x_location in pairs({21, 24, 27, 30}) do
        if i%2==0 then
            add_floating_spike(two_point_path(x_location, 15, x_location, 9), 0.9)
        else
            add_floating_spike(two_point_path(x_location, 9, x_location, 15), 0.9)
        end
    end
    add_floating_spike(two_point_path(18, 16, 32, 16), 1)
    add_floating_spike(two_point_path(17, 9, 17, 18), 3)
    for y_loc in all({13, 14, 15}) do 
        add_floating_spike(two_point_path(10, y_loc, 15, y_loc), 0.2)
    end
    add_floating_spike(two_point_path(38, 20, 57, 20), 0.6)
    add_floating_spike(two_point_path(59, 1, 59, 20), 0.8)
    add_floating_spike(two_point_path(83, 12, 86, 12), 1)
    add_floating_spike(four_point_path(68, 8, 76, 15), 1)
    ]]
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

function add_floating_spike(path, speed, sprite_sheet, num_frames, frame_duration)
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
        t = 0,  -- Parameter for interpolation (0 to 1)
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
                self.t = 0
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
    
