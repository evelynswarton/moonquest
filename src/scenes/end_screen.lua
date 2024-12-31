function end_screen_init()
    game_over_location = {
        x = player.x,
        y = player.y 
    }
    music(46)
    if num_deaths == 0 then
        end_screen.text = 'so it is true... \n'..num_moons_collected..' moons found...\nand still with your flesh intact...\nyou impress me deeply.'
    else
        end_screen.text = num_moons_collected..' moons found...\nbut you have accrued a karmic debt...\nyou inherit the moon kingdom but curse generations to come.'
    end
    end_screen.index = 0
end

function end_screen.update()
    upd_objs(bg_graphics)
    upd_objs(rain)
    end_screen.index += 0.2
    if btnp(5) then
        end_screen.index += 0.2
    end
    if btnp(4) then
        player.x = game_over_location.x
        player.y = game_over_location.y
        state = game
    end
    player.x = 0
    player.y = 0
end

function end_screen.draw()
    cls()
    drw_objs(bg_graphics)
    drw_objs(rain)
    local substring=sub(end_screen.text,0,min(flr(end_screen.index),#end_screen.text))
    draw_rounded_textbox(0, 0, substring)
end
