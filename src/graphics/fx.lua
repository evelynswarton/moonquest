function add_dust(_x,_y,_dx,_dy)
    add(graphics,{
        x=_x,
        y=_y,
        dx=(rnd(1) * -sgn(_dx)),
        dy=_dy,
        r=rnd(3),
        draw=function(self)
            circfill(self.x,self.y,self.r,13)
        end,
        update=function(self)
            self.r -= 0.05
            if self.r < 0 then
                del(graphics, self)
            end
            if self.dy > -0.75 then
                self.dy= (self.dy - 0.75) / 2
            end
            if self.dx < -0.05 then
                self.dx += 0.05
            elseif self.dx > 0.05 then
                self.dx -= 0.05
            else
                self.dx=0
            end
            self.x += self.dx
            self.y += self.dy
        end
    })
end

function add_wipe(_c)
    add(graphics,{
        colr=_c,
        a=0,
        b=0,
        draw=function(self)
            local a = self.a
            local b = self.b
            local x = cam.x + 63
            local y = cam.y + 63
            for i = a, b do
                rect(x - i, y - i, x + i, y + i, self.colr)
            end
        end,
        update=function(self)
            self.b += 5
            if self.b >= 64 then
                self.a += 5
            end
            if self.a > 128 then
                del(graphics, self)
            end
        end
    })
end

function add_swoosh(_x,_y)
    add(graphics,{
        x=_x,
        y=_y,
        t=0,
        r=10,
        phi=4,
        thta=0,
        speed = 0.05,
        draw=function(self)
            for i=1,10 do
                local theta=(0.03*i)+self.thta
                local phi=(0.1*i)*self.phi
                local r=self.t
                circfill(self.x+r*cos(theta),self.y+r*sin(theta),phi,7)
            end
        end,
        update=function(self)
            self.t += 1
            self.thta = (self.speed * (self.t))
            if self.phi < 0 then
                del(graphics, self)
            end
            self.phi -= self.speed
        end
    })
end

function add_rain()
    add(rain,{
        x = flr(rnd(128)),
        y = flr(rnd(128)),
        l = flr(rnd(7)),
        s = (flr(rnd(3)) + 3) * 0.75,
        draw = function(self)
            for i = 1, self.l do
                local colr=0
                if i < 0.2 * self.l then
                    colr = 0
                elseif i < 0.7 * self.l then
                    colr = 13
                else
                    colr=1
                end
                pset(self.x+cam.x+i,self.y+cam.y-i,colr) 
            end
        end,
        update=function(self)
            -- move rain drop
            self.x -= self.s
            self.y += self.s
            -- loop rain drop
            if self.x<-4 then
                self.x+=132
            end
            if self.y > 132 then
                self.y -= 132
            end
        end
    })
end

function add_splashes_at_random(rain_percent)
    -- for any map tile within [cam.x, cam.x + 128] x [cam.y, cam.y + 128] with flag 0=TRUE
    -- give a 'rain_percent'% chance it will add a splash at that tile
    local x = flr(cam.x / 8)
    local y = flr(cam.y / 8)
    for x_tile = x, x + 16 do
        for y_tile = y, y + 16 do
            -- Check if flag 0 is TRUE (you may need to modify this part)
            if fget(mget(x_tile, y_tile), 0) then
                -- Calculate a random number between 0 and 99 (inclusive)
                local random_chance = flr(rnd(100))
                -- Check if the random chance is less than rain_percent
                if random_chance < rain_percent then
                    add_splash(x_tile, y_tile)
                end
            end
        end
    end
end

function add_splash(x_tile, y_tile)
    add(splashes, {
        ground = 8 * y_tile,
        x = 8 * x_tile + flr(rnd(8)),
        y = 8 * y_tile,
        dy = -flr(rnd(10)) / 10,
        dx = -flr(rnd(10)) / 50,
        t = 0,
        draw = function(self)
            pset(self.x, self.y, 7)
            pset(self.x + self.dx, self.y + self.dy, 13)
        end,
        update = function(self)
            self.t += 1
            if self.t >= 360 then
                del(splashes, self)
            end
            self.dy += 0.1
            self.x += self.dx
            self.y += self.dy
            if self.y > self.ground then
                del(splashes, self)
            end
        end
    })
end