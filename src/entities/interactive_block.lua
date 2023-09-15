interactive_blocks = {}

grab_x_offset = 5
grab_y_offset = 3

block_gravity = 0.1
block_launch_force = 2
-- TODO: seperate physics and collider logic from player so we can use here
function add_interactive_block(type, x, y)
    add(inteactive_blocks, {
        type = type,
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        is_held = false,
        update = function(self)
            if self.is_held then 
                if player.flip then
                    self.x = player.x - grab_x_offset
                else
                    self.x = player.x + grab_x_offset
                end
                if not btnp('🅾️') then
                    local sign = 1
                    if player.flip then
                        sign = -1
                    end
                    self.dx = sign * 2
            else
                self.dy += block_gravity
                self.dx *= 0.5
            end
        end,
        draw = function(self)
            spr(16, self.x, self.y)
        end
    }
end