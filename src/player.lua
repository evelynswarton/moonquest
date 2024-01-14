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
    state = "idle",
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

function player_physics_update()
     -- physics
     player.dy += gravity

     -- bound floating fall speed
     if state_is('floaitng') then
         if player.dy > player.umb_dy then
             player.dy = player.umb_dy
         end
     end

     -- bound wall slide speed
     if state_is('onleft') or state_is('onright') then
         if player.dy > 0 then
             player.dy = clamp(player.dy, max_wall_slide_speed)
         end
         -- wall slide dust
         if player.dy > 0.5 then
             if state_is('onleft') then
                 add_dust(player.x, player.y, rnd(1), player.dy)--, player.dx, player.dy)
             else
                 add_dust(player.x + player.w, player.y, -rnd(1), player.dy)--, player.dx, player.dy)
             end
         end
     end
     -- ground slide dust
     if state_is('sliding') then
        if abs(player.dx) > 0.75 then
            add_dust(player.x + player.w / 2, player.y + player.h, player.dx, player.dy)
        end 
        if abs(player.dx) < 0.1 then 
            set_state('idle')
        end
     end
     player.dx *= (1 - floor_friction) 
end

function player_controller_update()
    -- l/r movement
    if btn(⬅️) then
        player.dx -= acceleration
        if on_ground() then set_state('running') end
        player.flp = true
    end
    if btn(➡️) then
        player.dx += acceleration
        if on_ground() then set_state('running') end
        player.flp = false
    end

    --slide
    if state_is('running')
        and not btn(⬅️)
        and not btn(➡️) then
        set_state('sliding')
    end

    --jump
    if state_is('jumping') and player.dy >= 0 then 
        set_state('falling')
    end
    if btnp(❎) and on_ground() then
        player.dy -= player.boost
        sfx(62, 3, 4, 4)
        set_state('jumping')
    --let go of ❎ for short hop
    elseif not btn(❎) and state_is('jumping') then
        player.dy = 0
        set_state('falling')
    --wall jump left
    elseif btnp(❎) and state_is('onleft') then
        sfx(62, 3, 4, 4)
        if player.prev_wall == "l" then
            player.dy = -1 * player.wlclm_dy
        else
            player.dy= -1 * player.wljmp_dy
        end
        player.prev_wall = "l"
        player.dx += player.wljmp_dx
        set_state('jumping')
        --player.jumping=true
    --wall jump right
    elseif btnp(❎) and state_is('onright') then
        sfx(62, 3, 4, 4)
        if player.prev_wall == "r" then
            player.dy = -1 * player.wlclm_dy
        else
            player.dy = -1 * player.wljmp_dy
        end
        player.prev_wall = "r"
        player.dx -= player.wljmp_dx
        set_state('jumping')
        --player.jumping=true

    --float
    elseif btn(❎) and (state_is('falling') or state_is('floating')) and player.float_meter > 0 then
        if player.dy > player.umb_dy then
            player.dy = player.umb_dy
        end
        set_state('floating')
        --player.floating = true
        player.float_meter -= float_depletion_rate
        --set_state('falling')
        --player.floating=false
    end
end

function player_collider_update()
    --check hitbox for bad things
    if player.dx < 0 and collides_with_map(player, "left", 2)
    or player.dx > 0 and collides_with_map(player, "right", 2)
    or player.dy > 0 and collides_with_map(player, "up", 2)
    or player.dy < 0 and collides_with_map(player, "down", 2)
    --check if fallen off map
    or player.y > 512 then
        player_die()
    end
    -- check if touched a floating spike
    for spike in all(floating_spikes) do 
        if touch(player, spike) then
            player_die()
        end
    end
    --check hitbox for good things
    for m in all(moons) do
        if touch(player,m) then
            sfx(62, 3, 0, 4)
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
    if player.dy > 0 then
        -- m
        if btn(5) then set_state('floating') else set_state('falling') end
        player.dy = clamp(player.dy, player.max_dy)
        -- touch ground
        if collides_with_map(player, "down", 0) then
            -- fix state
            if btn(0) or btn(1) then set_state('running') 
            elseif abs(player.dx) >= 0.1 then set_state('sliding')
            else set_state('idle') end
            -- reset float meter
            player.float_meter = 10
            -- reset wall jump
            player.prev_wall= "none"
            -- stop falling
            player.dy = 0
            -- snaps player to y grid
            player.y -= ((player.y+player.h+1)%8)-1
            player.db.c_d=true
        end
    elseif player.dy < 0 then
        -- if moving up must be jumping or floating 
        if btn(5) then set_state('jumping')
        else set_state('floating') end    
        -- bump head
        if collides_with_map(player,"up",1) then
            player.dy = 0
            player.db.c_u=true
        end
    end
    -- fan physics
    for fan in all(fans) do 
        if touch(player, fan.field) then
            if btn(5) and player.float_meter > 0 then
                set_state('floating')
                player.dy -= fan.force
            else 
                player.dy -= fan.force / 2
            end
        end
    end

    --check collision on x
    --moving left
    if player.dx < 0 then
        if collides_with_map(player, "left", 1) then
            player.dx = 0
            set_state('onleft')
            --player.on_wall = "l"
            player.db.c_l = true
            while flr(player.x) % 8 != 0 do
                player.x += 1
            end
        elseif adjacent_to_tile(player, 1) == 'l' then
            set_state('onleft')
        else
            player.on_wall = "none"
        end
    elseif player.dx > 0 then
        if collides_with_map(player, "right", 1) then
            player.dx = 0
            set_state('onright')
            player.on_wall = "r"
            player.db.c_r = true
            while flr(player.x) % 8 != 0 do
                player.x -= 1
            end
        elseif adjacent_to_tile(player, 1) == 'r' then
            set_state('onright')
        else
            player.on_wall = "none"
        end
    else
        local dir = adjacent_to_tile(player, 1)
        if dir == 'l' then
            set_state('onleft')
        elseif dir == 'r' then
            set_state('onright')
        else
            player.db.c_u=false
            player.db.c_d=false
            player.db.c_l=false
            player.db.c_r=false
        end
    end
end

function player_update()
    player_physics_update()
    -- controls
    if controls_on then
       player_controller_update()
    end
    if on_ground() and state_is('floating') then 
        print('error: floating while on ground', cam.x, cam.y + 64, debug_color)
    end
    player_collider_update()
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
    if player.x > map_end - player.w then
        player.x = map_end - player.w
    end
end

function player_animate()
    if state_is('onleft') or state_is('onright') then
        player.current_sprite = 5
    elseif state_is('jumping') then
        player.current_sprite = 6
    elseif state_is('falling') or state_is('floating') then
        player.current_sprite=8
    elseif state_is('sliding') then
        player.current_sprite=7
    elseif state_is('running') then
        if time() - player.anim > .1 then
            player.anim = time()
            player.current_sprite += 1
            if player.current_sprite > 4 then
                player.current_sprite = 3
            end
        end
    elseif state_is('idle') then --player idle
        if time()-player.anim > .3 then
            player.anim=time()
            player.current_sprite += 1
            if player.current_sprite > 2 then
                player.current_sprite = 1
            end
        end
    end
end

function on_ground()
    if collides_with_map(player, "down", 0) or state_is('landed') or state_is('running') or state_is('idle') or state_is('sliding') then 
        return true 
    end
    return false
end

function state_is(s)
    return player.state == s
end

function set_state(s)
    player.state = s
end

function player_debug_draw()
    print(player.state, player.x, player.y + player.h + 2, debug_color)
end

function player_die()
    sfx(62, 3, 12, 4)
    add_wipe(8)
    num_deaths += 1
    game.reset()
    controls_on = false
    pause_controls_start = time()
end