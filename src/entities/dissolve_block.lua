dissolve_speed = 0.55 
dissolve_respawn_duration = 180
dissolve_recovery_speed = 0.001

function init_dissolve_blocks()
    --[[
    add_dissolve_block(10,36)
    add_dissolve_block(11,36)
    add_dissolve_block(12,36)
    ]]
    for x_tile = 0,127 do
        for y_tile = 0,63 do
            if mget(x_tile, y_tile) == 54 then
                add_dissolve_block(x_tile, y_tile)
                mset(x_tile, y_tile, 0)
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
            x = x * 8,
            y = (y * 8) - 1,
            w = 8,
            h = 2
        },
        durability = 100,
        respawn_timer = 0,
        update = function(self)
            if touch(self.hb, player) then
                self.durability -= dissolve_speed
            else
                if self.durability > 0 then
                    self.durability = min(self.durability + dissolve_recovery_speed, 100)
                end
            end
            if self.durability >= 66 then
                mset(self.x_tile, self.y_tile, 54)
            elseif self.durability >= 33 then
                mset(self.x_tile, self.y_tile, 32)
            elseif self.durability > 0 then
                mset(self.x_tile, self.y_tile, 17)
            else
                mset(self.x_tile, self.y_tile, 0)
                if self.respawn_timer == 0 then
                    for i=1,10 do
                        local x=self.x+rnd(8)
                        local y=self.y+rnd(8)
                        add_dust(x,y,0,0)
                    end
                end
                self.durability = 0
                self.respawn_timer += 1
                if self.respawn_timer >= dissolve_respawn_duration then
                    self.respawn_timer = 0
                    self.durability = 100
                end
            end
        end,
        draw = function(self)
            --[[if touch(self.hb, player) then
                if self.durability > 66 then
                    rect(self.x, self.y, self.x + self.w, self.y + self.h, 11)
                end
                if self.durability > 33 then
                    rect(self.x, self.y, self.x + self.w, self.y + self.h, 14)
                else
                    rect(self.x, self.y, self.x + self.w, self.y + self.h, 8)
                end
            end]]
        end
    })
end
