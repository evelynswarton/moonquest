player = {
    current_sprite = 1,
    x = 0,
    y = 0,
    w = 8,
    h = 8,
    flp = false,
    dx = 0,
    dy = 0,
    max_dx = 1.5,
    max_dy = 100,
    umb_dy = 0.5,
    float_meter = 10,
    boost = 3.5,
    wljmp_frc = 1.5,
    wljmp_dx = 3.5,
    wljmp_dy = 3.5,
    wlclm_dy = 3.5,
    anim = 0,
    hb = {
        x1 = 0,
        x2 = 7,
        y1 = 0,
        y2 = 7
    },
    running = false,
    jumping = false,
    sliding = false,
    landed = false,
    floating = false,
    on_wall = "none",
    prev_wall = "none",
    --debug
    db = {
        x1r=0, y1r=0,
        x2r=0, y2r=0,
        c_u=false, c_d=false,
        c_l=false, c_r=false
    }
}

function player_init(_x,_y)
    player.x = _x
    player.y = _y
    player.dx = 0
    player.dy = 0
end

function player_update()
    -- physics
    player.dy += gravity
    if player.floating then
        if player.dy > player.umb_dy then
            player.dy = player.umb_dy
        end
    end
    if player.on_wall != "none" then
        if player.dy > 0 then
            player.dy = clamp(player.dy, max_wall_slide_speed)
        end
        --if abs(player.dy) > max_wall_slide_speed then
        --    player.dy = sgn(player.dy) * player.wljmp_frc
        --end
        if player.dy > 0.5 then
            if player.on_wall == "l" then
                add_dust(player.x, player.y, player.dx, player.dy)
            else
                add_dust(player.x + player.w, player.y, player.dx, player.dy)
            end
        end
    end
    if player.sliding and abs(player.dx) > 0.75 then
        add_dust(player.x + player.w / 2, player.y + player.h, player.dx, player.dy)
    end
    player.dx *= (1 - floor_friction)

    -- controls
    if controls_on then
        if btn(⬅️) then
            player.dx -= acceleration
            player.running = true
            player.flp = true
        end
        if btn(➡️) then
            player.dx += acceleration
            player.running = true
            player.flp = false
        end

        --slide
        if player.running
            and not btn(⬅️)
            and not btn(➡️)
            and not player.falling
            and not player.jumping then
            player.running=false
            player.sliding=true
        end

        --jump
        if btnp(❎)
            and player.landed then
            player.dy-=player.boost
            sfx(62)
            player.landed=false

            --let go of ❎ for short hop
        elseif not btn(❎)
            and player.jumping then
            player.dy=0
            player.jumping=false

            --wall jump left
        elseif btnp(❎)
            and player.on_wall=="l" then
            sfx(62)
            if player.prev_wall=="l" then
                player.dy=-1*player.wlclm_dy
            else
                player.dy=-1*player.wljmp_dy
            end
            player.prev_wall="l"
            player.dx+=player.wljmp_dx
            player.jumping=true

            --wall jump right
        elseif btnp(❎)
            and player.on_wall=="r" then
            sfx(62)
            if player.prev_wall=="r" then
                player.dy=-1*player.wlclm_dy
            else
                player.dy=-1*player.wljmp_dy
            end
            player.prev_wall="r"
            player.dx-=player.wljmp_dx
            player.jumping=true

            --float
        elseif btn(❎)
        and player.falling 
        and player.float_meter > 0 then
            if player.dy>player.umb_dy then
                player.dy=player.umb_dy
            end
            player.floating = true
            player.float_meter -= float_depletion_rate
        else
            player.floating=false
        end
    end
    if player.on_wall!="none"
        or player.landed then
        player.floating=false
    end

    --check hitbox for bad things
    if player.dx < 0 and collides_with_map(player, "left", 2)
    or player.dx > 0 and collides_with_map(player, "right", 2)
    or player.dy > 0 and collides_with_map(player, "up", 2)
    or player.dy < 0 and collides_with_map(player, "down", 2)
    
    --check if fallen off map
    or player.y > 512 then
        sfx(63)
        add_wipe(8)
        num_deaths += 1
        game.reset()
        controls_on = false
        pause_controls_start = time()
    end
    for spike in all(floating_spikes) do 
        if touch(player, spike) then
            sfx(63)
            add_wipe(8)
            num_deaths += 1
            game.reset()
            controls_on = false
            pause_controls_start = time()
        end
    end

    --check hitbox for good things
    for m in all(moons) do
        if touch(player,m) then
            sfx(60)
            num_moons_collected += 1
            add_swoosh(m.x + 0.5 * m.w, m.y + 0.5 * m.h)
            del(moons, m)
        end
    end

    if not collides_with_map(player,"left",1)
        and not collides_with_map(player,"right",1) then
        player.on_wall="none"
    end

    --check collision on y
    if player.dy>0 then
        player.falling=true
        player.landed=false
        player.jumping=false

        player.dy=clamp(player.dy,player.max_dy)

        if collides_with_map(player,"down",0) then
            player.landed=true
            player.float_meter = 10
            player.prev_wall="none"
            player.falling=false
            player.dy=0
            player.y-=((player.y+player.h+1)%8)-1
            player.db.c_d=true
        end
    elseif player.dy<0 then
        player.jumping = true
        player.falling = false 
        player.floating = false
        if collides_with_map(player,"up",1) then
            player.dy=0
            player.db.c_u=true
        end
    end

    --check collision on x
    --moving left
    if player.dx < 0 then
        if collides_with_map(player, "left", 1) then
            player.dx = 0
            player.on_wall = "l"
            player.db.c_l = true
            while flr(player.x) % 8 != 0 do
                player.x += 1
            end
        else
            player.on_wall = "none"
        end
    elseif player.dx > 0 then
        if collides_with_map(player, "right", 1) then
            player.dx=0
            player.on_wall="r"
            player.db.c_r=true
            while flr(player.x)%8!=0 do
                player.x-=1
            end
        else
            player.on_wall="none"
        end
    else
        player.db.c_u=false
        player.db.c_d=false
        player.db.c_l=false
        player.db.c_r=false
    end
    --stop sliding
    if player.sliding then
        if abs(player.dx)<.2
            or player.running then
            player.dx=0
            player.sliding=false
        end
    end
    --move
    player.dx = clamp(player.dx, player.max_dx)
    player.dy = clamp(player.dy, player.max_dy)
    player.x += player.dx
    player.y += player.dy
    --limit to map
    if player.x < map_start then
        player.x = map_start
    end
    if player.x>map_end-player.w then
        player.x=map_end-player.w
    end
end

function player_animate()
    if player.on_wall!="none" then
        player.current_sprite=5
    elseif player.jumping then
        player.current_sprite=6
    elseif player.falling then
        player.current_sprite=8
    elseif player.sliding then
        player.current_sprite=7
    elseif player.running then
        if time()-player.anim>.1 then
            player.anim=time()
            player.current_sprite+=1
            if player.current_sprite>4 then
                player.current_sprite=3
            end
        end
    else --player idle
        if time()-player.anim>.3 then
            player.anim=time()
            player.current_sprite+=1
            if player.current_sprite>2 then
                player.current_sprite=1
            end
        end
    end
end
