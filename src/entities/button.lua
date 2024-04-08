-- usage:
-- button_signal[button.id] in {true, false}
-- depending on if button with given id is
-- pressed
button_signal = {}

function add_all_buttons() 
    -- id's just increment for every button we add
    -- 1, 2, 3, ...
    --add_button(18, 62, 13, 59) -- 1
    add_button(20, 59, 22, 56)
    add_button(0, 62, 1, 61)
    add_button(94, 62, 91, 59)
    add_button(93, 62, 91, 59)
    add_button(92, 62, 91, 59)
end

function add_button(x_tile, y_tile, x_target, y_target)
    add(buttons, {
        id = #buttons + 1,
        x = x_tile * 8,
        y = y_tile * 8,
        w = 8,
        h = 8,
        acitve = false,
        up_spr = 104,
        down_spr = 123,
        target_x = x_target,
        target_y = y_target,
        draw = function(self)
            local x, y = self.x, self.y
            if self.active then
                spr(self.down_spr, x, y)
            else
                spr(self.up_spr, x, y)
            end
        end,
        update = function(self)
            local active = false
            for ib in all(interactive_blocks) do 
                if touch(self, ib) then
                    active = true
                    destroy_target(self.target_x, self.target_y)
                end
            end
            self.active = active
            button_signal[self.id] = self.active
        end
    })
end

function destroy_target(x, y)
    curr_block = mget(x, y)
    if curr_block == 107 then 
        mset(x, y, 0)
        destroy_target(x - 1, y)
        destroy_target(x + 1, y)
        destroy_target(x, y - 1)
        destroy_target(x, y + 1)
        for i = 1, 10 do
            dust_x = x * 8 + rnd(8)
            dust_y = y * 8 + rnd(8)
            add_dust(dust_x, dust_y, 0, 0)
        end
    end
end
