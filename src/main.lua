game={}

function _init()
	init_vars()
	show_menu()
end

function _update()
	game.upd()
end

function _draw()
 game.drw()
end

function show_menu()
 music(63)
 game.upd=menu_update
 game.drw=menu_draw
 blnk={
  colr={0,2,8,7,8,2},
  i=0,
  f=0,
  s=5
 }
 st=false
 fl_num=5
end

function menu_update()
	if btnp(4) or btnp(5) then
		st=true
		blnk.s=1
	end
	blnk.f+=1
	if blnk.f%blnk.s==0 then
		if blnk.i+1>#blnk.colr then
		 blnk.i=0
		else
		 blnk.i+=1
		end
	end
	if st==true and blnk.i==0 then
		fl_num-=1
		if fl_num==0 then
			mode="game"
			show_game()
		end
	end
end

function menu_draw()
	cls()
	sspr(12*8,0,32,32,28,24,64,64)
	print("press ❎ to start",30,100,blnk.colr[blnk.i])
end
-->8
--game
function show_game()
	deaths=0
	game.upd=game_update
	game.drw=game_draw
	music(0)
	gfx={}
	moons=0
	moon={}
	add_moon(40,30)
	add_moon(34*8,48*8)
	flag={}
	add_flag(3,46)
	add_flag(45,41)
	add_flag(69,60)
	add_flag(60,7)
	add_flag(55,22)
	game_reset()
end

function game_update()
	player_update()
	player_animate()
	for u in all(umb) do
	 u:update()
	end
	cam_update()
	
	for m in all(moon) do
	 m:update()
	end
	for f in all(flag) do
	 f:update()
	end
	for r in all(rain) do
	 r:update()
	end
	for g in all(gfx) do
	 g:update()
	end
	
 --debug
	if debug_on then
		debug_update()
	end
	
end

function game_draw()
	cls(0)
	for r in all(rain) do
	 r:draw()
	end
	map(0,0)
	print("jump : ❎",1*8,59*8,7)
	print("float : ❎ [while falling]",24*8,59*8,7)
	for u in all(umb) do
	 u:draw()
	end
	for m in all(moon) do
	 m:draw()
	end
	for f in all(flag) do
	 f:draw()
	end
	spr(player.sp,player.x,player.y,1,1,player.flp)
	drw_flt_mtr()
	
 for i=1,#enm do
  local myenm=enm[i]
  spr(myenm.spr,myenm.x,myenm.y)	
	end
	 

	if deaths>0 then
	 print("deaths:"..deaths,cam.x+2,cam.y+121,8)
	 print("deaths:"..deaths,cam.x+2,cam.y+120,7)
	end
	
	drw_mns(moons,2)
	for g in all(gfx) do
	 g:draw()
	end
	--debug
	if debug_on then
	 debug_draw()
	end
	
	
end

function game_reset()
 local px,py,flg_spwn=false
 for f in all(flag) do
  if f.up==true then
   px=f.x
   py=f.y
   flg_spawn=true
  end
 end
 if not flg_spawn then
  player_init(8,512-32)
  cam_init(8,512-32)
 else
  cam_init(px,py)
	 player_init(px,py)
	end
	
	umb={}
	add_umb()
	
	rain={}
	for i=1,100 do
	 add_rain()
	end
	
	enm={}
	local my_en={}
	my_en.x=90
	my_en.y=20
	my_en.spr=54
	add(enm,my_en)
	
end
-->8
--player
function player_init(_x,_y)
 player={
	 sp=1,--sprite
	 x=_x,
	 y=_y,
	 w=8,
	 h=8,
	 flp=false, 
	 dx=0,
	 dy=0,
	 max_dx=3.6,
	 umb_dy=1,
	 flt_mtr=10,
	 max_dy=4,
	 acc=0.7,
	 boost=5,
	 wljmp_frc=5,
	 wljmp_dx=5,
	 wljmp_dy=5,
	 wlclm_dy=5,
	 anim=0,
	 hb={
	  x1=0, y1=0,
	  x2=7, y2=7
	 },
		running=false,
		jumping=false,
		sliding=false,
		landed=false,
		floating=false,
		on_wall="none",
		prev_wall="none",
		--debug
		db={
		 x1r=0, y1r=0,
		 x2r=0, y2r=0,
		 c_u=false, c_d=false,
		 c_l=false, c_r=false
		}
	}
end

function player_update()

	--physics
	player.dy+=gravity
	if player.floating then
	 if player.dy>player.umb_dy then
	  player.dy=player.umb_dy
	 end
	end
	if player.on_wall!="none" then
	 if player.dy>player.wljmp_frc then
	  player.dy=player.wljmp_frc
	 end
	 if player.dy>0.5 then
		 if player.on_wall=="l" then
		  add_dust(player.x,player.y,player.dx,player.dy)
		 else
		  add_dust(player.x+player.w,player.y,player.dx,player.dy)
		 end
		end
	end
	if player.sliding and abs(player.dx)>2 then
	 add_dust(player.x+player.w/2,player.y+player.h,player.dy,player.dy)
	end
	player.dx*=friction
	
	--controls
	if btn(⬅️) then
		player.dx-=player.acc
		player.running=true
		player.flp=true
	end
	if btn(➡️) then
		player.dx+=player.acc
		player.running=true
		player.flp=false
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
	and player.flt_mtr>0 then
	 if player.dy>player.umb_dy then
	  player.dy=player.umb_dy
	 end
	 player.floating=true
	 player.flt_mtr-=0.2
	else
	 player.floating=false
	end
	if player.on_wall!="none"
	or player.landed then
	 player.floating=false
	end
	
	--check hitbox for bad things
	if player.dx<0 and collide_map(player,"left",2)
	or player.dx>0 and collide_map(player,"right",2)
	or player.dy>0 and collide_map(player,"up",2)
	or player.dy<0 and collide_map(player,"down",2)
	then
	 sfx(63)
	 add_wipe(8)
	 deaths+=1
		game_reset()
	end
	
	--check if fallen off map
	if player.y>512 then
	 sfx(63)
	 add_wipe(8)
	 deaths+=1
		game_reset()
	end
	
	--check hitbox for good things
	for m in all(moon) do
		if touch(player,m) then
		 sfx(61)
		 moons+=1
		 add_swoosh(m.x+0.5*m.w,m.y+0.5*m.h)
		 del(moon,m)
		end
	end
	
	if not collide_map(player,"left",1)
	 and not collide_map(player,"right",1) then
	  player.on_wall="none"
	 end
	
	--check collision on y
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dy)
		
		if collide_map(player,"down",0) then
		 player.landed=true
		 player.flt_mtr=10
		 player.prev_wall="none"
		 player.falling=false
		 player.dy=0
		 player.y-=((player.y+player.h+1)%8)-1
		 player.db.c_d=true
		end
	elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up",1) then
		 player.dy=0
		 player.db.c_u=true
		end
	end
	
	--check collision on x
	--moving left
	if player.dx<0 then
	 player.dx=limit_speed(player.dx,player.max_dx)
	 if collide_map(player,"left",1) then
	 	player.dx=0
	 	player.on_wall="l"
	 	player.db.c_l=true
	 	while flr(player.x)%8!=0 do
	 	 player.x+=1
	 	end
	 else
	 	player.on_wall="none"
	 end
	elseif player.dx>0 then
	 
	 player.dx=limit_speed(player.dx,player.max_dx)
	 
	 if collide_map(player,"right",1) then
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
	player.x+=player.dx
	player.y+=player.dy

	--limit to map
	if player.x<map_start then
	 player.x=map_start
	end
	if player.x>map_end-player.w then
	 player.x=map_end-player.w
	end
end

function player_animate()
 if player.on_wall!="none" then
 	player.sp=5
	elseif player.jumping then
	 player.sp=6
	elseif player.falling then
	 player.sp=8
	elseif player.sliding then
	 player.sp=7
	elseif player.running then
	 if time()-player.anim>.1 then
	  player.anim=time()
	  player.sp+=1
	  if player.sp>4 then
	   player.sp=3
	  end
	 end
	else --player idle
		if time()-player.anim>.3 then
		 player.anim=time()
		 player.sp+=1
		 if player.sp>2 then
		  player.sp=1
		 end
		end
	end
end

function limit_speed(num,maximum)
 return mid(-maximum,num,maximum)
end
	
function drw_flt_mtr()
 if player.floating then
	 rectfill(player.x-1,player.y-9,
	  player.x+player.flt_mtr-2,player.y-9,
	  8)
	 rect(player.x-2,player.y-10,
	  player.x+8,player.y-8,7)
	end
end
-->8
--debug

function debug_update()

end

function debug_draw()
	print("debug:on",cam.x,cam.y,11)
	print("on_wall:"..player.on_wall,cam.x,cam.y+10,11)
 print("flags:"..#flag,cam.x,cam.y+16,11)
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
end
-->8
--cam

function cam_init(_x,_y)
 cam={
  x=_x,
  y=_y,
  tx=0,
  ty=0,
  spd=.9,
  lk=20
 }
end

function cam_update()
 cam.tx=player.x-64
	if player.flp then
  cam.tx-=cam.lk
 else
 	cam.tx+=cam.lk
 end
 cam.ty=player.y-64
 
 cam.x=(cam.spd*cam.x)+((1-cam.spd)*cam.tx)
 cam.y=(cam.spd*cam.y)+((1-cam.spd)*cam.ty)
	--do not go off of the map
	--left bound
	if cam.x<map_start then
	 cam.x=map_start
	end
	--right bound
	if cam.x>map_end-128 then
	 cam.x=map_end-128	
	end
	--top bound
	if cam.y<map_top then
		cam.y=map_top
	end
	--bottom bound
	if cam.y>map_bottom-128 then
		cam.y=map_bottom-128
	end
	
	camera(cam.x,cam.y)
end
-->8
--variables

function init_vars()
	gravity=0.35
	friction=0.88
	
	--map limits
	map_start=0
	map_end=1024
	map_top=0
	map_bottom=64*8

	debug_on=false
end
-->8
--collisions

function collide_map(obj,dir,flag)
	--obj=table needs x,y,w,h,hb
	local x=obj.x
	local y=obj.y
	local dx=obj.dx
	local dy=obj.dy
	local w=obj.w
	local h=obj.h
	local hb=obj.hb
	
	--collision box
	local x1=0 local y1=0
	local x2=0 local y2=0
	
	--placing collision box
	if dir=="left" then
		x1=x+hb.x1-1
		y1=y+hb.y1+dy
		
		x2=x+hb.x1-1
		y2=y+hb.y2+dy-3
		
	elseif dir=="right" then
		x1=x+hb.x2+1
		y1=y+hb.y1+dy
		
		x2=x+hb.x2+1
		y2=y+hb.y2+dy-3
	
	elseif dir=="up" then
	 x1=x+hb.x1+3
	 y1=y+hb.y1+dy
	 
	 x2=x+hb.x2-3
	 y2=y+hb.y1+dy
	
	elseif dir=="down" then	
	 x1=x+hb.x1+dx
	 y1=y+h
	 
	 x2=x+hb.x2+dx
	 y2=y+h
	end
	
	--debug
	if debug_on then
		player.db.x1r=x1
		player.db.y1r=y1
		player.db.x2r=x2
		player.db.y2r=y2
	end
	
	--pixels to tiles
	x1/=8 y1/=8
	x2/=8 y2/=8
	
	--check collide (finally)
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
	 return true
	else
		return false
	end
end

function touch(o1,o2)
 if o1.x+o1.w<o2.x
 or o2.x+o2.w<o1.x
 or o1.y+o1.h<o2.y
 or o2.y+o2.h<o1.y then
  return false
 else
  return true
 end
end
-->8
--effects
function add_rain()
 add(rain,{
  x=flr(rnd(128)),
	 y=flr(rnd(128)),
	 l=flr(rnd(7)),
	 s=flr(rnd(3))+3,
	 draw=function(self)
	 	for i=1,self.l do
	 		local colr=0
	 		if i<0.2*self.l then
	 		 colr=0
	   elseif i<0.7*self.l then
	    colr=13
	   else
	    colr=1
	   end
	   pset(self.x+cam.x+i,self.y+cam.y-i,colr) 
	  end
	 end,
	 update=function(self)
	  self.x-=self.s
			if self.x<-4 then
				self.x+=132
			end
			self.y+=self.s
			if self.y>132 then
				self.y-=132
			end
	 end
 })
end

function add_swoosh(_x,_y)
 add(gfx,{
  x=_x,
  y=_y,
  t=0,
  r=10,
  phi=4,
  thta=0,
  draw=function(self)
   for i=1,10 do
    local theta=(0.03*i)+self.thta
    local phi=(0.1*i)*self.phi
    local r=self.t
    circfill(self.x+r*cos(theta),self.y+r*sin(theta),phi,7)
   end
  end,
  update=function(self)
   self.t+=1
   self.thta=(0.1*(self.t))
   if self.phi<0 then
    del(gfx,self)
   end
   self.phi-=0.1
  end
 })
end

function add_wipe(_c)
 add(gfx,{
  colr=_c,
  a=0,
  b=0,
  draw=function(self)
   local a=self.a
   local b=self.b
   local x=cam.x+63
   local y=cam.y+63
   for i=a,b do
    rect(x-i,y-i,x+i,y+i,self.colr)
   end
  end,
  update=function(self)
   self.b+=10
   if self.b>=64 then
    self.a+=10
   end
   if self.a>128 then
    del(gfx,self)
   end
  end
 })
end

function add_dust(_x,_y,_dx,_dy)
 add(gfx,{
  x=_x,
  y=_y,
  dx=_dx+rnd(1)-1,
  dy=_dy,
  r=rnd(3),
  draw=function(self)
   circfill(self.x,self.y,self.r,13)
  end,
  update=function(self)
   self.r-=0.1
   if self.dy>-1.5 then
    self.dy=(self.dy - 1.5)/2
   end
   if self.dx<-0.1 then
    self.dx+=0.1
   elseif self.dx>0.1 then
    self.dx-=0.1
   else
    self.dx=0
   end
   self.x+=self.dx
   self.y+=self.dy
  end
 })
end
-->8
--moons
function add_moon(_x,_y)
 add(moon,{
  sp={48,49,50,51,52,51,50,49},
  x=_x,
  y=_y,
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
		 self.i=flr(t%l)+1
   --float up&down
   self.y=self.y+sin(0.05*self.t)
   self.t+=0.5
  end
 })
end

function drw_mns(_n,_m)
 for i=0,_n do
  spr(17,cam.x+120,cam.y+8*i)
 end
 for i=_n,_m-1 do
  spr(16,cam.x+120,cam.y+8*i)
 end
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
 add(flag,{
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
    if not self.up then sfx(61) end
    self.up=true
   end
   if player.x+8>self.x
   and player.x+8<=self.x+8
   and player.y+8>self.y
   and player.y<= self.y+8 then
    if not self.up then sfx(61) end
    self.up=true
   end
   if self.up then
    self.anm_idx+=0.5
    if self.anm_idx>=self.anm_len then
     self.anm_idx=0
    end
   end
  end
 })
end