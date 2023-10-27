function add_circ()
    add(bg_graphics,{
        x = rnd(128),
        y = rnd(128),
        dx = (rnd(2) + 1) / 3,
        dy = (-rnd()) / 10,
        r = rnd(64),
        draw = function(self)
            fillp(-23131)
            circfill(cam.x + self.x, cam.y + self.y, self.r, 10)
            fillp()
        end,
        update = function(self)
            self.x += self.dx 
            self.y += self.dy
            if self.x > 128 + self.r then
                self.x = -self.r
            end
            if self.y < 0 - self.r then 
                self.y = 128 + self.r 
            end
        end
    })
end