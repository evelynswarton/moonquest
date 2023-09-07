-- path = {pos1, pos2, ..., posn}
-- pos = {x = ?, y = ?}
function add_all_spikes()
    add_floating_spike({
        {x = 26 * 8, y = 42 * 8},
        {x = 26 * 8, y = 40 * 8},
        {x = 28 * 8, y = 40 * 8},
        {x = 28 * 8, y = 42 * 8}}, 5)
    add_floating_spike({
        {x = 12 * 8, y = 27 * 8},
        {x = 24 * 8, y = 27 * 8}}, 1.5) 
    add_floating_spike({
        {x = 31 * 8, y = 26 * 8},
        {x = 31 * 8, y = 35 * 8}}, 1.5) 
    add_floating_spike({
        {x = 5 * 8, y = 19 * 8},
        {x = 5 * 8, y = 28 * 8}}, 1.5) 
    add_floating_spike({
        {x = 2 * 8, y = 19 * 8},
        {x = 2 * 8, y = 28 * 8}}, 1.5) 
    add_floating_spike({
        {x = 5 * 8, y = 1 * 8},
        {x = 5 * 8, y = 15 * 8}}, 2) 
    add_floating_spike({
        {x = 1 * 8, y = 5 * 8},
        {x = 9 * 8, y = 5 * 8}}, 4) 
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
    