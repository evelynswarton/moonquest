menu, game, player, cam = {}, {}, {}, {}
state = menu

function _init()
    state = menu
    state.init()
end

function _update60()
    state.update()
end

function _draw()
    state.draw()
end


--num_moons_collected
function add_moon(_x,_y)
    add(moons,{
        sp={48,49,50,51,52,51,50,49},
        x = _x,
        y = _y + 4,
        w = 8,
        h = 8,
        flp=false,
        t = 0,
        i = 0,
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


function add_umb()
    add(umb,{
        x=0,
        y=0,
        ty=0,
        spd=0.8,
        pickup_anim=0,
        draw=function(self)
            if umbrella_collected then
                spr(9,self.x,self.y,1,1,true)
            else
                spr(9, umb_spawn_x, (umb_spawn_y) + 4 * sin(self.pickup_anim))
            end
        end,
        update=function(self)
            if umbrella_collected then
                self.ty=player.y+(player.h/2)-7
                self.x=player.x+5
                --interpolate to ty with t=spd
                self.y=(self.spd*self.y)+((1-self.spd)*self.ty)
                --top bound
                if self.y<self.ty-5 then
                    self.y=self.ty-5
                end
                if self.y>self.ty+2 then
                    self.y=self.ty+2
                end
            else
                self.pickup_anim += 0.01
            end
        end
    })
end




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
                    sfx(62, 3, 8, 4)
                end
                self.up=true
                for f in all(flags) do 
                    if f != self then
                        f.up = false 
                    end
                end
            end
            if player.x + 8 > self.x
                and player.x+8<=self.x+8
                and player.y+8>self.y
                and player.y<= self.y+8 then
                if not self.up then 
                    sfx(62, 3, 8, 4)
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
