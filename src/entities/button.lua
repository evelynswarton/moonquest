function add_all_buttons() 
    add_button(18, 62)
end

function add_button(x_tile, y_tile)
    add(buttons, {
        id = #buttons,
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
        end
    })
end