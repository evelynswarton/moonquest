--num_moons_collected = 0
max_sign_width = 100
--moon_collection_sign = {''}

function init_signs()
    --add_sign('controls:\n -⬅️➡️ to move\n -❎ to jump or float\n -🅾️ to interact', 3, 60)
    --add_sign('hold ❎ to float', 12, 36)
    --add_sign('there are still 100 moons to collect!', 8, 62, true)
    --add_sign('hold ❎ : jump->float', 33, 59)
    --add_sign('controls:\n -⬅️➡️ to move\n -❎ to jump or float\n -🅾️ to interact', 19, 59)
    --add_sign('flags save ur progress!', 53, 58)
    --add_sign('u can wall jump!\nswitch sides to go higher', 60, 60)
    add_sign('here the rain never stops\n...\nnor does the sun rise...', 7, 37)
    add_sign('thick fog... biting cold.\nthe wind howls and howls\ncan you hear it?', 19, 34)
    add_sign('these floating moons\nthey shine brightly.\nthey call to you.', 29, 31)
    add_sign('you feel an urge\n\nan insatiable desire\n\nto collect all the moons.', 54, 37)
end

function add_sign(message, x_tile, y_tile, is_moon_counter)
    add(signs, {
        x = x_tile * 8,
        y = y_tile * 8,
        w = 8,
        h = 8,
        sprite = 103,
        is_hovered = false,
        is_active = false,
        text = message,
        hover_height = 0,
        text_index = 1,
        b = is_moon_counter or false,
        draw = function(self)
            if self.is_hovered and not self.is_active then 
                print('🅾️', self.x, self.y - self.hover_height, 13)
                --[[
                for i = 0, 15 do 
                    pal(i, 7)
                end
                spr(self.sprite, self.x + 1, self.y + 1)
                spr(self.sprite, self.x - 1, self.y + 1)
                spr(self.sprite, self.x + 1, self.y - 1)
                spr(self.sprite, self.x - 1, self.y - 1)
                for i = 0, 15 do 
                    pal(i, i)
                end
                spr(self.sprite, self.x, self.y)
                ]]--
            end
            if self.is_active then
                local substring = sub(self.text, 0, flr(self.text_index))
                draw_rounded_textbox(self.x / 8, self.y / 8, substring)
            end
        end,
        update = function(self)
            if self.b then
                self.text = 'there are still ' .. tostr(100 - num_moons_collected) .. ' moons to collect!'
            end
            self.is_hovered = touch(player, self)
            if self.is_hovered then
                self.hover_height = lerp(self.hover_height, 8, 0.5)
                if btnp(4) then
                    self.is_active = not self.is_active
                end 
            else
                self.hover_height = 0
                self.is_active = false
            end
            if self.is_active then
                self.text_index += 0.5
            end
        end
    })
end
