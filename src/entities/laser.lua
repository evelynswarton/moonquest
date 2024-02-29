-- table for all laser objs
lasers = {}

-- animation speed: fps
laser_animation_speed = 4

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
function add_laser(x, y0, y1)
    add(lasers, {
        x = x,
        y0 = y0,
        y1 = y1,
        t = 0,
        y_offset = 0,
        update = function(self)
            self.t += 1
            if self.t > laser_animation_speed then
                self.y_offset += 1
                self.y_offset = self.y_offset % 8
                self.t = 0
            end
        end,
        draw = function(self)
            for y = (self.y0-1), (self.y1+1) do
                spr(self.x, y + self.y_offset, 59)
            end
        end
    })
end
