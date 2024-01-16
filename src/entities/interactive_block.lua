interactive_blocks = {}

grab_x_offset = 5
grab_y_offset = 3

block_gravity = 0.1
block_launch_force = 2

function add_interactive_block(type, x, y)
    add(interactive_blocks, {
        type = 'block',
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        w = 7,
        h = 7,
        max_dx = 10,
        max_dy = 10,
        is_held = false,
        is_hovered = false,
        hb = {
            x1 = 0,
            x2 = 7,
            y1 = 0,
            y2 = 7
        },
        hover_height = 0,
        update = function(self)
            if self.is_held then
                -- set location to player location
                self.is_hovered = false
                if player.flp then
                    self.x = player.x - grab_x_offset
                else
                    self.x = player.x + grab_x_offset
                end
                self.y = player.y - 2

                -- throw block
                if btnp(4) then
                    local sign = 1
                    if player.flp then
                        sign = -1
                    end
                    self.dx = sign * 2
                    self.dy = -1
                    self.is_held = false
                end
            else
                for fan in all(fans) do 
                    if touch(self, fan.field) then 
                        self.dy -= fan.force
                    end
                end
                -- move do physics when not held
                --collision(self)
                move(self)
                hover_key.update(self)
            end
        end,
        draw = function(self)
            spr(16, self.x, self.y)
            if self.is_hovered then
                hover_key.draw(self)
            end
        end
    })
end
