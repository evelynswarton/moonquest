-- usage:
-- button_signal[button.id] in {true, false}
-- depending on if button with given id is
-- pressed
button_signal = {}

function add_all_buttons() 
    -- id's just increment for every button we add
    -- 1, 2, 3, ...
    add_button(18, 62) -- 1
end

function add_button(x_tile, y_tile)
    add(buttons, {
        id = #buttons + 1,
        x = x_tile * 8,
        y = y_tile * 8,
        w = 8,
        h = 8,
        acitve = false,
        up_spr = 104,
        down_spr = 123,
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
            for block in all(interactive_blocks) do 
                if touch(self, block) then
                    active = true
                end
            end
            self.active = active
            button_signal[self.id] = self.active
        end
    })
end