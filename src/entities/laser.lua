-- table for all laser objs
lasers = {}

-- animation speed: fps
laser_animation_speed = 2

-- function to go through map and
-- spawn all lasers
function add_all_lasers()
    for x_tile = 0, 127 do
        for y_tile = 0, 63 do 
            if mget(x_tile, y_tile) == 59 then 
                add_laser(x_tile * 8, y_tile * 8, y_tile * 8)
                mset(x_tile, y_tile, 0)
            end
        end
    end
end

-- function to instantiate a laser
function add_laser(x, y)
    add(lasers, {
        x = x,
        y = y,
        w = 8,
        h = 8,
        t = 0,
        y_offset = 0,
        is_top = true,
        is_bottom = true,
        update = function(self)
            self.t += 1
            if self.t > laser_animation_speed then
                self.y_offset = (self.y_offset + 1) % 8
                self.t = 0
            end
            for l in all(lasers) do
                if l.y == self.y - 8 then 
                    self.is_top = false
                elseif l.y == self.y + 8 then
                    self.is_bottom = false
                end
            end
        end,
        draw = function(self)
            spr(59, self.x, self.y + self.y_offset)
            spr(59, self.x, self.y + self.y_offset - 8)
            if self.is_top then
                local r = rnd(2)
                local x, y = self.x + 3.5, self.y - 1
                circfill(x, y, r + 2, 8)
                circfill(x, y, r + 1, 14)
                circfill(x, y, r + 0, 7)
            end
            if self.is_bottom then
                local r = rnd(2)
                local x, y = self.x + 3.5, self.y + 8
                circfill(x, y, r + 2, 8)
                circfill(x, y, r + 1, 14)
                circfill(x, y, r + 0, 7)
            end
        end
    })
end
