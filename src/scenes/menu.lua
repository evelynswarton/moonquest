blink, start_game, flashes_remaining, bow_on =
    {  
        colors={0,2,8,7,8,2},
        index = 0,
        current_frame = 0,
        speed = 10
    }, false, 5, true

function menu.init()
    music(46)
end

function menu.update()
    if btnp(4) or btnp(5) then
        start_game=true
        blink.speed=1
    end
    blink.current_frame+=1
    if blink.current_frame%blink.speed==0 then
        if blink.index+1>#blink.colors then
            blink.index=0
        else
            blink.index+=1
        end
    end
    if start_game==true and blink.index==0 then
        flashes_remaining-=1
        if flashes_remaining==0 then
            state =game
            state.init()
        end
    end
    if (btnp(0) or btnp(1)) then
        bow_on = not bow_on
        sfx(62,-1,4,2)
    end
end

function menu.draw()
    cls()
    sspr(12*8,0,32,32,32+16,32+16)
    sspr(12*8,32,32,32,32+20,16)
    print("press ❎ to start", 30, 100, blink.colors[blink.index])
    local c=8
    if (btn(0) or btn(1)) c=7
    if bow_on then
        print("~ character: bobo ~", 26, 108, c)
    else
        print("~ character: scar ~", 26, 108, c)
        rectfill(51,43,56,47,0)
    end
end

