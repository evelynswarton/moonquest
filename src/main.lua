-- game state modules
menu = {}
game = {}

-- variable to store current game state
current_state = menu

-- declare player variable as global
player = {}
cam = {}

function _init()
    current_state = menu
    current_state.init()
end

function _update60()
    current_state.update()
end

function _draw()
    current_state.draw()
end

function game.init()
    music(0)
    graphics = {}
    num_moons_collected = 0
    moons = {}
    flags = {}
    for tile_x = 0, 127 do
        for tile_y = 0, 127 do 
            if fget(mget(tile_x, tile_y), moon_flag) then
                add_moon(tile_x * 8, tile_y * 8)
            elseif fget(mget(tile_x, tile_y), save_flag) then
                add_flag(tile_x, tile_y)
            end
        end
    end
    floating_spikes = {}
    add_all_spikes()
    signs = {}
    splashes = {}
    init_signs()
    player_init(default_spawn_x, default_spawn_y)
    game.reset()
    num_deaths = 0
    controls_on = true
end

function game.update()
    player_update()
    player_animate()
    add_splashes_at_random(10)
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
    if debug_on then
        debug_update()
    end
    if not controls_on then
        pause_controls_end = time()
        if pause_controls_end - pause_controls_start >= pause_controls_duration then
            controls_on = true
        end
    end
end
function game.draw()
    cls(0)
    for drop in all(rain) do
        drop:draw()
    end
    map(0,0)
    --print("jump : ❎", 1 * 8, 59 * 8, 7)
    --print("float : ❎ [while falling]", 24 * 8, 59 * 8, 7)
    for splash in all(splashes) do
        splash:draw()
    end
    for u in all(umb) do
        u:draw()
    end
    for m in all(moons) do
        m:draw()
    end
    for f in all(flags) do
        f:draw()
    end
    for spike in all(floating_spikes) do 
        spike:draw()
    end
    spr(player.current_sprite, player.x, player.y, 1, 1, player.flp)
    drw_flt_mtr()
    for i = 1, #enm do
        local myenm=enm[i]
        spr(myenm.spr, myenm.x, myenm.y)	
    end
    draw_moon_counter(num_moons_collected)
    draw_death_counter(num_deaths)
    for g in all(graphics) do
        g:draw()
    end
    if debug_on then
        debug_draw()
    end
    for s in all(signs) do 
        s:draw()
    end
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
    enm={}
    local my_en={}
    my_en.x=90
    my_en.y=20
    my_en.spr=54
    add(enm, my_en)
end

function limit_speed(num,maximum)
    return mid(-maximum,num,maximum)
end

-->8
--debug

function debug_update()

end

function debug_draw()
    print("debug:on", cam.x, cam.y, 11)
    print("controls_on:"..(controls_on and 'true' or 'false'), cam.x, cam.y + 10, 11)
    print("flags:"..#flags, cam.x, cam.y + 16, 11)
    rect(
    player.db.x1r,
    player.db.y1r,
    player.db.x2r,
    player.db.y2r,
    11
    )
    print("c<⬆️>:"..(player.db.c_u and 'true' or 'false'),player.x,player.y-10)
    print("c<⬇️>:"..(player.db.c_d and 'true' or 'false'),player.x,player.y-16)
    print("c<⬅️>:"..(player.db.c_l and 'true' or 'false'),player.x,player.y-22)
    print("c<➡️>:"..(player.db.c_r and 'true' or 'false'),player.x,player.y-28)
    print('ram:'..stat(0), cam.x, cam.y + 128 - 6, 11)
    print('cpuTot:'..stat(1), cam.x, cam.y + 128 - 12, 11)
    print('cpuSys:'..stat(2), cam.x, cam.y + 128 - 18, 11)
end


-->8
--effects



-->8
--num_moons_collected
function add_moon(_x,_y)
    add(moons,{
        sp={48,49,50,51,52,51,50,49},
        x=_x,
        y=_y + 4,
        w=8,
        h=8,
        flp=false,
        t=0,
        i=1,
        rev_anim=false,
        draw=function(self)
            spr(self.sp[self.i],self.x,self.y,1,1,self.flp)
            circ(self.x+4,self.y+4,1.3*(sin(0.1*self.t)+8),13)
        end,
        update=function(self)
            local t=self.t
            local l=#(self.sp)
            --flip only during short window
            if t%l<=4.01 
                and t%l>=3.99 then
                self.flp=(not self.flp)
            end
            --set index based on time
            self.i = flr(t % l) + 1
            --float up&down
            self.y = self.y + 0.25 * sin(0.05 * self.t)
            self.t += 0.25
        end
    })
end

-->8
--umbrella
function add_umb()
    add(umb,{
        x=0,
        y=0,
        ty=0,
        spd=0.8,
        draw=function(self)
            spr(9,self.x,self.y,1,1,true)
        end,
        update=function(self)
            self.ty=player.y+(player.h/2)-7
            self.x=player.x+5
            --interpolate to ty with t=spd
            self.y=(self.spd*self.y)+((1-self.spd)*self.ty)
            --top bound
            if self.y<self.ty-5 then
                self.y=self.ty-5
            end
            --bottom bound
            if self.y>self.ty+2 then
                self.y=self.ty+2
            end
        end
    })
end


-->8
--flag
function add_flag(_x,_y)
    add(flags, {
        x=_x*8,
        y=_y*8,
        up=false,
        sp=18,
        flg_sp=19,
        dwn_sp=23,
        anm_len=4,
        anm_idx=0,
        draw=function(self)
            spr(self.sp,self.x,self.y)
            if self.up==false then spr(self.dwn_sp,self.x-4,self.y-1)
            else spr(self.flg_sp+self.anm_idx,self.x-4,self.y-1)
            end
        end,
        update=function(self)
            if player.x>self.x
            and player.x<=self.x+8
            and player.y>self.y
            and player.y<=self.y+8 then
                if not self.up then 
                    sfx(61)
                end
                self.up=true
                for f in all(flags) do 
                    if f != self then
                        f.up = false 
                    end
                end
            end
            if player.x+8>self.x
            and player.x+8<=self.x+8
            and player.y+8>self.y
            and player.y<= self.y+8 then
                if not self.up then 
                    sfx(61)
                end
                self.up=true
                for f in all(flags) do 
                    if f != self then
                        f.up = false 
                    end
                end
            end
            if self.up then
                self.anm_idx+=0.2
                if self.anm_idx>=self.anm_len then
                    self.anm_idx=0
                end
            end
        end
    })
end
