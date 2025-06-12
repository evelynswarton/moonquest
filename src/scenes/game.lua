function upd_obj(x) x:update() end
function upd_objs(xs) foreach(xs,upd_obj) end

game_over = false

function game.update()
    player_update()
    player_animate()
    add_splashes_at_random(10)
    upd_objs(bg_graphics)
    upd_objs(splashes)
    upd_objs(umb)
    upd_objs(moons)
    upd_objs(flags)
    upd_objs(fans)
    upd_objs(rain)
    upd_objs(graphics)
    upd_objs(floating_spikes)
    upd_objs(interactive_blocks)
    upd_objs(dissolve_blocks)
    upd_objs(buttons)
    upd_objs(signs)
    upd_objs(bows)
    cam_update()
    upd_objs(lasers)
    if (debug_on) debug_update()
        if not controls_on then
            pause_controls_end=time()
            if pause_controls_end - pause_controls_start >= pause_controls_duration then
                controls_on = true
            end
        end
        local umbrella_pickup={
            x=umb_spawn_x,
            y=umb_spawn_y,
            w=7,
            h=7
        }
        if (touch(player,umbrella_pickup)) umbrella_collected=true

        
        end

        function drw_obj(x) x:draw() end
        function drw_objs(xs) foreach(xs,drw_obj) end

        function game.draw()
            cls(0)
            pal(0,129,1)
            pal(10,1,1)
            pal(9,130,1)
            pal(1,131,1)
            pal(11,139,1)
            drw_objs(bg_graphics)
            drw_objs(rain)
            drw_objs(lasers) 
            map(0,0)
            drw_objs(splashes)
            drw_objs(umb)
            drw_objs(moons)
            drw_objs(flags)
            drw_objs(floating_spikes)
            drw_objs(fans)
            drw_objs(buttons)
            drw_objs(interactive_blocks)
            drw_objs(flags)
            spr(player.current_sprite,player.x,player.y,1,1,player.flp)
            if (bow_on) drw_objs(bows)
            if (debug_on) player_debug_draw()
            if (umbrella_collected) draw_float_meter() 
            drw_objs(signs)
            draw_moon_counter(num_moons_collected)
            draw_death_counter(num_deaths)
            drw_objs(graphics)
            if (debug_on) debug_draw()
        end

                        function game.reset()
                            local spawn_x,spawn_y,spawn_at_flag=false
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
                            for i=1,100 do
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
                            umbrella_collected, bg_graphics, graphics, moons, 
                            flags, 
                            buttons,
                            floating_spikes,
                            fans,
                            dissolve_blocks,
                            signs,
                            splashes,
                            bows,
                            game_objs =
                            false, {}, {}, {}, {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {}
                            --add_all_lasers()
                            for i = 0, 10 do 
                                add_circ()
                            end
                            num_moons_collected = 0
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
                            add_all_buttons()
                            add_all_spikes()
                            add_all_fans()
                            init_dissolve_blocks()
                            init_signs()
                            player_init(default_spawn_x,default_spawn_y)
                            add_bow()
                            game.reset()
                            num_deaths = 0
                            controls_on = true
                        end

-- fn : serialize_map()
-- returns string encoding
-- all map data
function serialize_map()
	local s = 'MAP-TILES:'
	for tx=0,127 do
		for ty=0,127 do
			-- $x[x-tile]y[y-tile]spr[sprite]
			s=s..
			  '$'..
			  'x'..tx..
			  'y'..ty..
			  'spr'..mget(tx,ty)	
		end
	end
	s=s..'FLAGS:'
	for f in all(fans) do
		-- $x[x-px]y[y-px]f[force]r[rot]
		s=s..
		  '$'..
		  'x'..f.x..
		  'y'..f.y..
		  'f'..f.force..
		  'r'..f.rot..
	end
	s=s..'BUTTONS:'
	for b in all(buttons) do
	end
	for spk in all(floating_spikes) do
	end
end
