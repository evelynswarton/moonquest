function game.update()
    player_update()
    player_animate()
    add_splashes_at_random(10)
    for c in all(bg_graphics) do 
        c:update() 
    end
    for splash in all(splashes) do
        splash:update()
    end
    for u in all(umb) do
        u:update()
    end
    cam_update()
    for m in all(moons) do
        m:update()
    end
    for f in all(flags) do
        f:update()
    end
    for fan in all(fans) do 
        fan:update()
    end
    for r in all(rain) do
        r:update()
    end
    for g in all(graphics) do
        g:update()
    end
    for spike in all(floating_spikes) do 
        spike:update()
    end
    for s in all(signs) do 
        s:update()
    end
    for block in all(interactive_blocks) do
        block:update()
    end
    for block in all(dissolve_blocks) do
        block:update()
    end
    for button in all(buttons) do 
        button:update()
    end
    for laser in all(lasers) do
        laser:update()
    end
    if debug_on then
        debug_update()
    end
    if not controls_on then
        pause_controls_end = time()
        if pause_controls_end - pause_controls_start >= pause_controls_duration then
            controls_on = true
        end
    end
    local umbrella_pickup = {
        x = umb_spawn_x,
        y = umb_spawn_y,
        w = 7,
        h = 7
    }
    if touch(player, umbrella_pickup) then
        umbrella_collected = true
    end
end

function draw_obj(x) x:draw() end

function game.draw()
 cls(0)
 pal(0,129,1)
 pal(10,1,1)
 pal(9,130,1)
 pal(1,131,1)
 pal(11,139,1)
 foreach(bg_graphics,draw_obj)
 foreach(rain,draw_obj)
 foreach(lasers,draw_obj) 
 map(0,0)
 foreach(splashes,draw_obj)
 foreach(umb,draw_obj)
 foreach(moons,draw_obj)
 foreach(flags,draw_obj)
 foreach(floating_spikes,draw_obj)
 foreach(fans,draw_obj)
 foreach(buttons,draw_obj)
 foreach(interactive_blocks,draw_obj)
 foreach(flags,draw_obj)
 spr(player.current_sprite,player.x,player.y,1,1,player.flp)
 if (debug_on) player_debug_draw()
 if (umbrella_collected) draw_float_meter() 
 foreach(signs,draw_obj)
 draw_moon_counter(num_moons_collected)
 draw_death_counter(num_deaths)
 foreach(graphics,draw_obj)
 if (debug_on) debug_draw()
end

function game.reset()
    local spawn_x, spawn_y, spawn_at_flag = false
    for f in all(flags) do
        if f.up == true then
            spawn_x = f.x
            spawn_y = f.y
            spawn_at_flag = true
        end
    end
    if not spawn_at_flag then
        player_init(default_spawn_x, default_spawn_y)
        cam_init(default_spawn_x, default_spawn_y)
    else
        cam_init(spawn_x, spawn_y)
        player_init(spawn_x, spawn_y)
    end
    umb = {}
    add_umb()
    rain={}
    for i = 1, 100 do
        add_rain()
    end
    for ib in all(interactive_blocks) do
        ib_rspwn(ib)
    end
    for db in all(dissolve_blocks) do
        db.durability = 3
        db.is_dead = false
    end
end

function game.init()
    music(30)
    umbrella_collected = false
    bg_graphics = {}
    add_all_lasers()
    for i = 0, 10 do 
        add_circ()
    end
    graphics = {}
    num_moons_collected = 0
    moons = {}
    flags = {}
    for tile_x = 0, 127 do
        for tile_y = 0, 127 do 
            local x, y = tile_x * 8, tile_y * 8
            if fget(mget(tile_x, tile_y), moon_flag) then
                add_moon(x, y)
                if not debug_on then mset(tile_x, tile_y, 0) end
            elseif fget(mget(tile_x, tile_y), save_flag) then
                add_flag(tile_x, tile_y)
                if not debug_on then mset(tile_x, tile_y, 0) end
            elseif fget(mget(tile_x, tile_y), block_flag) then
                add_interactive_block('blank', x, y)
                if not debug_on then mset(tile_x, tile_y, 0) end
            end
        end
    end

    buttons = {}
    add_all_buttons()

    floating_spikes = {}
    add_all_spikes()

    fans = {}
    add_all_fans()

    dissolve_blocks = {}
    init_dissolve_blocks()

    signs = {}
    splashes = {}
    init_signs()
    player_init(default_spawn_x, default_spawn_y)


    game.reset()
    num_deaths = 0
    controls_on = true
end
