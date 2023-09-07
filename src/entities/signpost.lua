sign1 = 'press ❎ to jump'
sign2 = 'you can wall jump'
sign3 = 'collect moons!'
sign4 = 'hold ❎ to float'
sign5 = 'be careful...'

max_sign_width = 100

function init_signs()
    add_sign('controls:\n -⬅️➡️ to move\n -❎ to jump or float\n -🅾️ to interact', 3, 60)
    add_sign('the rain is getting out of control these days...', 5, 50)
    add_sign('if this weather doesn\'t let up, we will need to abandon this place etirely', 0, 34)
    add_sign('we should have brought our umbrellas. maybe we could have used them to float.', 12, 36)
    add_sign(sign5, 23, 44)
    add_sign('we tried our best to retrieve every moon here... but there are still 100 moons we couldn\'t recover', 8, 62)
    add_sign('this place is full of traps...', 32, 40)
end

function add_sign(message, x_tile, y_tile)
    add(signs, {
        x = x_tile * 8,
        y = y_tile * 8,
        w = 8,
        h = 8,
        is_hovered = false,
        is_active = false,
        text = message,
        hover_height = 0,
        text_index = 1,
        draw = function(self)
            if self.is_hovered and not self.is_active then 
                print('🅾️', self.x, self.y - self.hover_height, 13)
            end
            if self.is_active then
                local substring = sub(self.text, 0, flr(self.text_index))
                draw_rounded_textbox(self.x / 8, self.y / 8, substring)
            end
        end,
        update = function(self)
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
