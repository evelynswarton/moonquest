interactive_blocks = {}

grab_x_offset = 5
grab_y_offset = 3

block_gravity = 0.1
block_launch_force = 2

-- in frames, 3 seconds total
block_respawn_duration = 180 

function add_interactive_block(type, x, y)
    add(interactive_blocks, {
        type = 'block',
        spawn_x = x,
        spawn_y = y,
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
        is_dead = false,
        respawn_timer = 0,
        hb = {
            x1 = 0,
            x2 = 7,
            y1 = 0,
            y2 = 7
        },
        hover_height = 0,
        update = function(self)
            if not self.is_dead then
                if self.is_held then
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
                    move(self)
                    hover_key.update(self)
                end
                for l in all(lasers) do
                    if touch(l, self) then
                        ib_die(self)
                    end
                end
                if is_off_screen(self) then
                    ib_die(self)
                end
            else
                self.respawn_timer += 1
                if self.respawn_timer > block_respawn_duration then
                    ib_rspwn(self)
                end
            end
        end,
        draw = function(self)
            if not self.is_dead then
                spr(16, self.x, self.y)
                if self.is_hovered then
                    hover_key.draw(self)
                end
            end
        end,
    })
end

function ib_rspwn(blck)
    local _ENV = blck
    x = spawn_x
    y = spawn_y
    dx = 0
    dy = 0
    respawn_timer = 0
    is_dead = false
    is_held = false
    is_hovered = false
end

function ib_die(blck)
    blck.respawn_timer = 0
    blck.is_dead = true
    for i = 1,10 do
        add_dust(blck.x + rnd(8), blck.y + rnd(8), 0, 0)
    end
end
