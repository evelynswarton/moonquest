function menu.init()
    logo_x = 0
    logo_y = 0
    music(63)
    blink = {
        colors = {0,2,8,7,8,2},
        index = 0,
        current_frame = 0,
        speed = 5
    }
    start_game = false
    flashes_remaining = 5
end

function menu.update()
    if btnp(4) or btnp(5) then
        start_game = true
        blink.speed = 1
    end
    blink.current_frame += 1
    if blink.current_frame % blink.speed == 0 then
        if blink.index + 1 > #blink.colors then
            blink.index = 0
        else
            blink.index += 1
        end
    end
    if start_game == true and blink.index == 0 then
        flashes_remaining -= 1
        if flashes_remaining == 0 then
            current_state = game
            current_state.init()
        end
    end
end

function menu.draw()
    cls()
    sspr(12 * 8, 0, 32, 32, 32 + 16, 32 + 16)
    sspr(12 * 8, 32, 32, 32, 32 + 20, 16)
    print("press ❎ to start", 30, 100, blink.colors[blink.index])
end
