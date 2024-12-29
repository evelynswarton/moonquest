function end_screen_init()
    music(46)
    if num_deaths == 0 then
        end_screen.text = '100 moons found...\nand still with your flesh intact...\nyou impress me deeply.'
    else
        end_screen.text = '100 moons found...\nbut you have accrued a karmic debt...\nyou inherit the moon kingdom but curse generations to come.'
    end
    end_screen.index = 0
end

function end_screen.update()
    end_screen.index += 0.2
    if btnp(5) then
        end_screen.index += 0.2
    end
    if btnp(4) then
        end_screen.hide = true
    end
end

function end_screen.draw()
    if not end_screen.hide then
        local substring=sub(end_screen.text,0,min(flr(end_screen.index),#end_screen.text))
        draw_rounded_textbox(player.x, player.y, substring)
    end
end