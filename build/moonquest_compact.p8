pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
---------------------------
-- ~ * + moonquest + * ~ --
--       ^^^^^^^^^       --
-- a 1z1gh0st experience --
---------------------------

-- file can be built with flatten_cart.py
-- each included file is assigned to one tab
-- for the source code in its original format
-- see github.com/1z1gh0st

-->8
--src/main.lua
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


--umbrella
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
				--bottom bound
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
-->8
--src/player.lua
player = {
 type = 'player',
 current_sprite = 1,
 x = 0,
 y = 0,
 w = 7,
 h = 7,
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
 wlclm_dy = 1.8,
 anim = 0,
 hb = {
  x1 = 0,
  x2 = 7,
  y1 = 0,
  y2 = 7
 },
 hurtbox = {
  x = 2,
  y = 2,
  w = 2,
  h = 2,
  dx = 0,
  dy = 0,
  hb = {
   x1 = 0,
   x2 = 2,
   y1 = 0,
   y2 = 2
  }
 },
 running = false,
 jumping = false,
 sliding = false,
 landed = false,
 floating = false,
 on_wall = "none",
 prev_wall = "none",
 first_wall = true,
 state = "idle",
 wall_hang_time = 15,
 wall_hang_timer = 0,
 --debug
 db = {
  x1=0, y1=0,
  x2=0, y2=0
 }
}

function player_init(_x, _y)
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
   player.dx = 0
  end
  end
  player.dx *= (1 - floor_friction) 
end

function player_controller_update()
 -- l/r movement
 if btn(⬅️) then
  if state_is('onright') then
   player.dx = 0
   if player.wall_hang_timer < player.wall_hang_time then
    player.wall_hang_timer += 1
   else
    player.dx -= acceleration
    player.wall_hang_timer = 0
   end
  else
   player.dx -= acceleration
   if on_ground() then set_state('running') end
   player.flp = true
  end
 end
 if btn(➡️) then
  if state_is('onleft') then
   player.dx = 0
   if player.wall_hang_timer < player.wall_hang_time then
    player.wall_hang_timer += 1
   else
    player.dx += acceleration
    player.wall_hang_timer = 0
   end
  else
   player.dx += acceleration
   if on_ground() then set_state('running') end
   player.flp = false
  end
 end
 if state_is('onleft') and not btn(1) then player.wall_hang_timer = 0 end
 if state_is('onright') and not btn(0) then player.wall_hang_timer = 0 end
 -- slide
 if state_is('running')
  and not btn(⬅️)
  and not btn(➡️) then
  set_state('sliding')
 end
 -- jump
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
   player.first_wall = false
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
   player.first_wall = false
  else
   player.dy = -1 * player.wljmp_dy
  end
  player.prev_wall = "r"
  player.dx -= player.wljmp_dx
  set_state('jumping')
 --float
 elseif btn(❎) and (state_is('falling') or state_is('floating')) and player.float_meter > 0 then
  if player.dy > player.umb_dy then
   player.dy = player.umb_dy
  end
  set_state('floating')
  player.float_meter -= float_depletion_rate
 end
end

function player_collider_update()
 --check hitbox for bad things
 local hb = player.hurtbox
 if player.dx < 0 and collides_with_map(hb, 'left', 2)
 or player.dx > 0 and collides_with_map(hb, 'right', 2)
 or player.dy > 0 and collides_with_map(hb, 'up', 2)
 or player.dy < 0 and collides_with_map(hb, 'down', 2)
 --check if fallen off map
 or player.y > 512 then
  player_die()
 end
 -- check if touched a floating spike
 for spike in all(floating_spikes) do 
  if touch(player.hurtbox, spike) then
   player_die()
  end
 end
 --check hitbox for good things
 for m in all(moons) do
  if touch(player, m) then
   sfx(62, 3, 0, 4)
   num_moons_collected += 1
   add_swoosh(m.x + 0.5 * m.w, m.y + 0.5 * m.h)
   del(moons, m)
  end
 end

 -- if falling, check ground collision
 if player.dy > 0 then
  if btn(5) then set_state('floating') else set_state('falling') end
  player.dy = clamp(player.dy, player.max_dy)
  -- touch ground
  while ((collides_with_map2(
  player.x,
  player.y + player.dy,
  player.w,
  player.h,
  'down') & 1) != 0) do
   -- fix state
   if btn(0) or btn(1) then set_state('running') 
   elseif abs(player.dx) >= 0.1 then set_state('sliding')
   else set_state('idle') end
   player.first_wall = true
   player.float_meter = 10
   player.prev_wall= "none"
   player.db.c_d = true
   player.dy -= 1
   if player.dy < 0 then
    player.dy = 0
    break
   end
  end
 elseif player.dy < 0 then
  if btn(5) then set_state('jumping')
  else set_state('floating') end 
  while (collides_with_map2(
  player.x,
  player.y + player.dy,
  player.w,
  player.h,
  'up') & 2) != 0 do
   player.dy += 1
   player.db.c_u=true
   if player.dy > 0 then 
    player.dy = 0
    break
   end
  end
 end
 if (on_ground() and flr(player.y) % 8 != 0 and player.dy == 0) then 
  player.y = flr(player.y) - (flr(player.y) % 8)
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
  while (collides_with_map2(
  player.x + player.dx,
  player.y,
  player.w,
  player.h,
  'left') & 2) != 0 do
   player.dx += 1
   if not on_ground() then set_state('onleft') end
   player.db.c_l = true
   if player.dx > 0 then 
    player.dx = 0
    break
   end
   --while flr(player.x) % 8 != 0 do
   -- player.x += 1
   --end
  end
  if adjacent_to_tile(player, 1) == 'l' and not on_ground() then
   set_state('onleft')
  else
   player.on_wall = "none"
   player.db.c_l = false
  end
 elseif player.dx > 0 then
  while (collides_with_map2(
  player.x + player.dx,
  player.y,
  player.w,
  player.h,
  'right') & 2) != 0 do
   player.dx -= 1
   if not on_ground() then set_state('onright') end
   player.on_wall = "r"
   player.db.c_r = true
   if player.dx < 0 then 
    player.dx = 0
    break
   end
   --while flr(player.x) % 8 != 0 do
   -- player.x -= 1
   --end
  end
  if adjacent_to_tile(player, 1) == 'r' and not on_ground() then
   set_state('onright')
  else
   player.on_wall = "none"
   player.db.c_r = false
  end
 else
  if not on_ground() then 
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
 player.hurtbox.dx = player.dx
 player.hurtbox.dy = player.dy
 player.hurtbox.x = player.x + 2
 player.hurtbox.y = player.y + 2
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
 if state_is('sliding') then
  if abs(player.dx) < 0.2
   or state_is('running') then
   player.dx = 0
   set_state('sliding')
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
 if not umbrella_collected then
  player.float_meter = 0
 end
end

function player_animate()
 if state_is('onleft') or state_is('onright') then
  player.current_sprite = 5
  if state_is('onleft') then player.flp = true end
  if state_is('onright') then player.flp = false end
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
 if collides_with_map(player, 'down', 0) or state_is('landed') or state_is('running') or state_is('idle') or state_is('sliding') then 
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
 rect(player.x + 1, player.y + 1, player.x + 6, player.y + 4, 8)
 
 print('left = '..tostr(player.db.c_l), cam.x + 1, cam.y + 37, debug_color)
 print('right = '..tostr(player.db.c_r), cam.x + 1, cam.y + 43, debug_color)
 print('y=['..tostr(player.y)..']', cam.x + 1, cam.y + 49, debug_color)
end

function player_die()
 sfx(62, 3, 12, 4)
 add_wipe(8)
 num_deaths += 1
 controls_on = false
 pause_controls_start = time()
 game.reset()
end
-->8
--src/camera.lua
function cam_init(spawn_x, spawn_y)
 cam = {
  x = spawn_x,
  y = spawn_y,
  target_x = 0,
  target_y = 0,
  look_ahead_distance = 20
 }
end

function cam_update()
 -- TODO: why the fuck do i have this line?
 cam.target_x = player.x - 64
 -- put the camera target to the correct location
 if player.flp then
  cam.target_x -= cam.look_ahead_distance
 else
  cam.target_x += cam.look_ahead_distance
 end
 -- TODO: WHYYYYY FUCKING WHYYYYY
 cam.target_y = player.y - 64

 -- TODO: just use a lerp
 cam.x = (cam_speed * cam.x) + ((1 - cam_speed) * cam.target_x)
 cam.y = (cam_speed * cam.y) + ((1 - cam_speed) * cam.target_y)

 -- camera bounds
 if cam.x < map_start then
  cam.x = map_start
 end
 if cam.x > map_end - 128 then
  cam.x = map_end-128	
 end
 if cam.y < map_top then
  cam.y = map_top
 end
 if cam.y > map_bottom - 128 then
  cam.y = map_bottom - 128
 end

 -- assign camera to location
 camera(cam.x, cam.y)
end

-->8
--src/entities/button.lua
-- usage:
-- button_signal[button.id] in {true, false}
-- depending on if button with given id is
-- pressed
button_signal = {}

function add_all_buttons() 
 -- id's just increment for every button we add
 -- 1, 2, 3, ...
 --add_button(18, 62, 13, 59) -- 1
 add_button(20, 59, 22, 56)
 add_button(0, 62, 1, 61)
 add_button(94, 62, 91, 59)
 add_button(93, 62, 91, 59)
 add_button(92, 62, 91, 59)
 add_button(119, 35, 116, 34)
 add_button(120, 35, 116, 34)
 add_button(121, 35, 116, 34)
 add_button(122, 35, 116, 34)
 add_button(123, 35, 116, 34)
end

function add_button(x_tile, y_tile, x_target, y_target)
 add(buttons, {
  id = #buttons + 1,
  x = x_tile * 8,
  y = y_tile * 8,
  w = 8,
  h = 8,
  acitve = false,
  up_spr = 104,
  down_spr = 123,
  target_x = x_target,
  target_y = y_target,
  draw = function(self)
   local x, y = self.x, self.y
   if self.active then
    spr(self.down_spr, x, y)
   else
    spr(self.up_spr, x, y)
   end
  end,
  update = function(self)
   local active = false
   for ib in all(interactive_blocks) do 
    if touch(self, ib) then
     active = true
     destroy_target(self.target_x, self.target_y)
    end
   end
   self.active = active
   button_signal[self.id] = self.active
  end
 })
end

function destroy_target(x, y)
 curr_block = mget(x, y)
 if curr_block == 107 then 
  mset(x, y, 0)
  destroy_target(x - 1, y)
  destroy_target(x + 1, y)
  destroy_target(x, y - 1)
  destroy_target(x, y + 1)
  for i = 1, 10 do
   dust_x = x * 8 + rnd(8)
   dust_y = y * 8 + rnd(8)
   add_dust(dust_x, dust_y, 0, 0)
  end
 end
end
-->8
--src/entities/dissolve_block.lua
--dissolve_speed = 0.55 
dissolve_respawn_duration = 360

function init_dissolve_blocks()
 --[[
 add_dissolve_block(10,36)
 add_dissolve_block(11,36)
 add_dissolve_block(12,36)
 ]]
 for x_tile = 0,127 do
  for y_tile = 0,63 do
   if mget(x_tile, y_tile) == 54 then
    add_dissolve_block(x_tile, y_tile)
    mset(x_tile, y_tile, 0)
   end
  end
 end
end

function add_dissolve_block(x, y)
 add(dissolve_blocks, {
  x = x * 8,
  y = y * 8,
  x_tile = x,
  y_tile = y,
  w = 8,
  h = 8,
  hb = {
   x = (x * 8) - 1,
   y = (y * 8) - 1,
   w = 10,
   h = 2
  },
  durability = 3,
  respawn_timer = 0,
  touching_player = false,
  update = function(self)
   if not self.touching_player then 
    if touch(self.hb, player) then
     self.touching_player = true
    end
   else
    if not touch(self.hb, player) then
     self.touching_player = false
     self.durability -= 1
    end
   end
   if not controls_on then
    self.durability = 3
   end
   if self.durability > 2 then
    mset(self.x_tile, self.y_tile, 54)
   elseif self.durability > 1 then
    mset(self.x_tile, self.y_tile, 32)
   elseif self.durability > 0 then
    mset(self.x_tile, self.y_tile, 17)
   else
    mset(self.x_tile, self.y_tile, 0)
    if self.respawn_timer == 0 then
     for i=1,10 do
      local x=self.x+rnd(8)
      local y=self.y+rnd(8)
      add_dust(x,y,0,0)
     end
    end
    self.durability = 0
    self.respawn_timer += 1
    if self.respawn_timer >= dissolve_respawn_duration then
     self.respawn_timer = 0
     self.durability = 3
    end
   end
  end,
  draw = function(self)
   --[[if touch(self.hb, player) then
    if self.durability > 66 then
     rect(self.x, self.y, self.x + self.w, self.y + self.h, 11)
    end
    if self.durability > 33 then
     rect(self.x, self.y, self.x + self.w, self.y + self.h, 14)
    else
     rect(self.x, self.y, self.x + self.w, self.y + self.h, 8)
    end
   end]]
  end
 })
end
-->8
--src/entities/fan.lua
function add_all_fans()
 for y = 50, 27, -8 do
  add_fan(63, y, 0, 0.3)
 end
 add_fan(72, 29, 0, 0.3)
 add_fan(83, 30, 0, 0.3)
 add_fan(88, 29, 0, 0.3)
 add_fan(98, 25, 0, 0.2)
 add_fan(109, 33, 0, 0.3)
 add_fan(116, 33, 0, 0.3)
 add_fan(121, 32, 0, 0.3)
end

function add_fan(x, y, r, f)
 add(
  fans, {
   x = x * 8,
   y = y * 8,
   force = f,
   field = { x = x * 8, y = y * 8 - 32, w = 16, h = 32 },
   rot = r % 4,
   sprite_sheet = { 89, 90, 91, 75, 91, 90, 89 },
   anim_idx = 0,
   frame = 0,
   draw = function(self)
    --pset(cam.x+1,cam.y+1,7)
    pal(6, 13)
    pal(7, 6)
    pal(13, 5)
    local secondary_anim_idx = (self.anim_idx + 2) % 4
    spr(self.sprite_sheet[self.anim_idx + 1], self.x, self.y)
    --spr(self.sprite_sheet[secondary_anim_idx+1],self.x+8,self.y,1,1,true)
    pal(6, 6)
    pal(7, 7)
    pal(13, 13)
    spr(self.sprite_sheet[secondary_anim_idx + 1], self.x, self.y)
    pal(6, 13)
    pal(7, 6)
    pal(13, 5)
    spr(self.sprite_sheet[secondary_anim_idx + 1], self.x + 8, self.y, 1, 1, true)
    pal(6, 6)
    pal(7, 7)
    pal(13, 13)
    spr(self.sprite_sheet[self.anim_idx + 1], self.x + 8, self.y, 1, 1, true)
    if debug_on then
     local f = self.field
     rect(f.x, f.y, f.x + f.w, f.y + f.h, debug_color)
    end
   end,
   update = function(self)
    self.frame += 1
    if self.frame >= 6 then
     self.frame = 0
     self.anim_idx += 1
     self.anim_idx = self.anim_idx % #self.sprite_sheet
    end
    if rnd(100) < 20 then
     local x, y, dx, dy
     if self.rot == 0 then
      x = self.x + rnd(16)
      y = self.y - 2
      dx = 0
      dy = self.force
     elseif self.rot == 1 then
     elseif self.rot == 2 then
     elseif self.rot == 3 then
     else
      error('fan rotation invalid')
     end

     add_dust(x, y, dx, dy)
    end
   end
  }
 )
end
-->8
--src/entities/floating_spikes.lua
function add_all_spikes()
 add_floating_spike(two_point_path(44, 61, 53, 61), 2)
 add_floating_spike(two_point_path(64, 62, 90, 62), 0.3)
 add_floating_spike(two_point_path(35, 60, 35, 55), 1)
 add_floating_spike(two_point_path(63, 56, 71, 56), 2)
 add_floating_spike(two_point_path(74, 57, 89, 57), 2)
 local phase = 0
 for x = 75, 91 do
  add_floating_spike(two_point_path(x, 54, x, 52), .8, phase)
	phase += 0.09
 end
 add_floating_spike(two_point_path(66, 26, 66, 20), 2)
 add_floating_spike(two_point_path(86, 29, 86, 25), 2)
 add_floating_spike(two_point_path(96, 23, 108, 23), 2)
 add_floating_spike(two_point_path(98, 21, 98, 29), 2)
end

function two_point_path(x1, y1, x2, y2)
 return {{x = x1 * 8, y = y1 * 8}, {x = x2 * 8, y = y2 * 8}}
end

function four_point_path(x1, y1, x2, y2)
 return {
  {x = x1 * 8, y = y1 * 8},
  {x = x1 * 8, y = y2 * 8},
  {x = x2 * 8, y = y2 * 8},
  {x = x2 * 8, y = y1 * 8}
 }
end

function n_point_path(n, x_array, y_array)
 path = {}
 for i = 1, n do 
  path[i].x = x_array[i] * 8
  path[i].y = y_array[i] * 8
 end
 return path
end

function add_floating_spike(path, speed, phase)
 local x_positions = {}
 local y_positions = {}
 for point in all(path) do 
  add(x_positions, point.x)
  add(y_positions, point.y)
 end
 add(floating_spikes, {
  x_path = x_positions,
  y_path = y_positions,
  x = x_positions[1],
  y = y_positions[1],
  w = 8,
  h = 8,
  path_length = #x_positions,
  speed = speed,
  t = phase or 0,  -- Parameter for interpolation (0 to 1)
  current_point_index = 1,
  frame = 1,  -- Current frame of animation
  frame_duration = .05,  -- Time between frame changes
  frame_timer = 0,  -- Timer for frame changes
  sprite_sheet = {105, 106, 121, 122},  -- Your sprite sheet image
  num_frames = 4,  -- Total number of frames in animation
  update = function(self, dt)
   local dt = 1/60
   self.t = self.t + self.speed * dt / self.path_length
   -- If self.t exceeds 1, wrap around and adjust it
   if self.t >= 1 then
    self.current_point_index = self.current_point_index + 1
    if self.current_point_index > self.path_length then
     self.current_point_index = 1 -- Wrap around to the beginning
    end
		while self.t >= 1 do
			self.t -= 1
		end
   end
   
   -- Interpolate between the current and next point
   self.x = lerp(self.x_path[self.current_point_index], self.x_path[(self.current_point_index % self.path_length) + 1], self.t)
   self.y = lerp(self.y_path[self.current_point_index], self.y_path[(self.current_point_index % self.path_length) + 1], self.t)
   
   -- Update animation frame
   self.frame_timer = self.frame_timer + dt
   if self.frame_timer >= self.frame_duration then
    self.frame_timer = self.frame_timer - self.frame_duration
    self.frame = (self.frame % self.num_frames) + 1
   end
  end,
  draw = function(self)
   -- Draw the current frame of the object's animation
   spr(self.sprite_sheet[self.frame], self.x, self.y)
  end
 })
end
 
-->8
--src/entities/interactive_block.lua
interactive_blocks = {}

grab_x_offset = 5
grab_y_offset = 3

block_gravity = 0.1
block_launch_force = 2

-- in frames, 3 seconds total
block_respawn_duration = 180 

function add_interactive_block(type, x, y)
 add(interactive_blocks, {
  type = 'block',
  spawn_x = x,
  spawn_y = y,
  x = x,
  y = y,
  dx = 0,
  dy = 0,
  w = 7,
  h = 7,
  max_dx = 10,
  max_dy = 10,
  is_held = false,
  is_hovered = false,
  is_dead = false,
  respawn_timer = 0,
  hb = {
   x1 = 0,
   x2 = 7,
   y1 = 0,
   y2 = 7
  },
  hover_height = 0,
  update = function(self)
   if not self.is_dead then
    if self.is_held then
     self.is_hovered = false
     if player.flp then
      self.x = player.x - grab_x_offset
     else
      self.x = player.x + grab_x_offset
     end
     self.y = player.y - 2

     -- throw block
     if btnp(4) then
      local sign = 1
      if player.flp then
       sign = -1
      end
      self.dx = sign * 2
      self.dy = -1
      self.is_held = false
     end
    else
     for fan in all(fans) do 
      if touch(self, fan.field) then 
       self.dy -= fan.force
      end
     end
     move(self)
     hover_key.update(self)
    end
    for l in all(lasers) do
     if touch(l, self) then
      ib_die(self)
     end
    end
    if is_off_screen(self) then
     ib_die(self)
    end
   else
    self.respawn_timer += 1
    if self.respawn_timer > block_respawn_duration then
     ib_rspwn(self)
    end
   end
  end,
  draw = function(self)
   if not self.is_dead then
    spr(16, self.x, self.y)
    if self.is_hovered then
     hover_key.draw(self)
    end
   end
  end,
 })
end

function ib_rspwn(blck)
 local _ENV = blck
 x = spawn_x
 y = spawn_y
 dx = 0
 dy = 0
 respawn_timer = 0
 is_dead = false
 is_held = false
 is_hovered = false
end

function ib_die(blck)
 blck.respawn_timer = 0
 blck.is_dead = true
 for i = 1,10 do
  add_dust(blck.x + rnd(8), blck.y + rnd(8), 0, 0)
 end
end
-->8
--src/entities/laser.lua
-- table for all laser objs
lasers = {}

-- animation speed: fps
laser_animation_speed = 2

-- function to go through map and
-- spawn all lasers
function add_all_lasers()
 for x_tile = 0, 127 do
  for y_tile = 0, 63 do 
   if mget(x_tile, y_tile) == 59 then 
    add_laser(x_tile * 8, y_tile * 8, y_tile * 8)
    mset(x_tile, y_tile, 0)
   end
  end
 end
end

-- function to instantiate a laser
function add_laser(x, y)
 add(lasers, {
  x = x,
  y = y,
  w = 8,
  h = 8,
  t = 0,
  y_offset = 0,
  is_top = true,
  is_bottom = true,
  update = function(self)
   self.t += 1
   if self.t > laser_animation_speed then
    self.y_offset = (self.y_offset + 1) % 8
    self.t = 0
   end
   for l in all(lasers) do
    if l.y == self.y - 8 then 
     self.is_top = false
    elseif l.y == self.y + 8 then
     self.is_bottom = false
    end
   end
  end,
  draw = function(self)
   spr(59, self.x, self.y + self.y_offset)
   spr(59, self.x, self.y + self.y_offset - 8)
   if self.is_top then
    local r = rnd(2)
    local x, y = self.x + 3.5, self.y - 1
    circfill(x, y, r + 2, 8)
    circfill(x, y, r + 1, 14)
    circfill(x, y, r + 0, 7)
   end
   if self.is_bottom then
    local r = rnd(2)
    local x, y = self.x + 3.5, self.y + 8
    circfill(x, y, r + 2, 8)
    circfill(x, y, r + 1, 14)
    circfill(x, y, r + 0, 7)
   end
  end
 })
end
-->8
--src/entities/signpost.lua
--num_moons_collected = 0
max_sign_width = 100
--moon_collection_sign = {''}

function init_signs()
 --add_sign('controls:\n -⬅️➡️ to move\n -❎ to jump or float\n -🅾️ to interact', 3, 60)
 --add_sign('hold ❎ to float', 12, 36)
 --add_sign('there are still 100 moons to collect!', 8, 62, true)
 --add_sign('hold ❎ : jump->float', 33, 59)
 --add_sign('controls:\n -⬅️➡️ to move\n -❎ to jump or float\n -🅾️ to interact', 19, 59)
 --add_sign('flags save ur progress!', 53, 58)
 --add_sign('u can wall jump!\nswitch sides to go higher', 60, 60)
 add_sign('here the rain never stops\n...\nnor does the sun rise...', 7, 37)
 add_sign('thick fog... biting cold.\nthe wind howls and howls\ncan you hear it?', 19, 34)
 add_sign('these floating moons\nthey shine brightly.\nthey call to you.', 29, 31)
 add_sign('you feel an urge\n\nan insatiable desire\n\nto collect all the moons.', 54, 37)
end

function add_sign(message, x_tile, y_tile, is_moon_counter)
 add(signs, {
  x = x_tile * 8,
  y = y_tile * 8,
  w = 8,
  h = 8,
  sprite = 103,
  is_hovered = false,
  is_active = false,
  text = message,
  hover_height = 0,
  text_index = 1,
  b = is_moon_counter or false,
  draw = function(self)
   if self.is_hovered and not self.is_active then 
    print('🅾️', self.x, self.y - self.hover_height, 13)
    --[[
    for i = 0, 15 do 
     pal(i, 7)
    end
    spr(self.sprite, self.x + 1, self.y + 1)
    spr(self.sprite, self.x - 1, self.y + 1)
    spr(self.sprite, self.x + 1, self.y - 1)
    spr(self.sprite, self.x - 1, self.y - 1)
    for i = 0, 15 do 
     pal(i, i)
    end
    spr(self.sprite, self.x, self.y)
    ]]--
   end
   if self.is_active then
    local substring = sub(self.text, 0, flr(self.text_index))
    draw_rounded_textbox(self.x / 8, self.y / 8, substring)
   end
  end,
  update = function(self)
   if self.b then
    self.text = 'there are still ' .. tostr(100 - num_moons_collected) .. ' moons to collect!'
   end
   self.is_hovered = touch(player, self)
   if self.is_hovered then
    self.hover_height = lerp(self.hover_height, 8, 0.5)
    if btnp(4) then
     self.is_active = not self.is_active
    end 
   else
    self.hover_height = 0
    self.is_active = false
   end
   if self.is_active then
    self.text_index += 0.5
   end
  end
 })
end

-->8
--src/graphics/bg.lua
function add_circ()
 add(bg_graphics,{
  x = rnd(128),
  y = rnd(128),
  dx = (rnd(2) + 1) / 3,
  dy = (-rnd()) / 10,
  r = rnd(54),
  draw = function(self)
   fillp(-23131)
   circfill(cam.x + self.x, cam.y + self.y, self.r, 10)
   fillp()
   --circfill(cam.x + self.x, cam.y + self.y, self.r * 0.8, 10)
  end,
  update = function(self)
   self.x += self.dx 
   self.y += self.dy
   if self.x > 128 + self.r then
    self.x = -self.r
   end
   if self.y < 0 - self.r then 
    self.y = 128 + self.r 
   end
  end
 })
end-->8
--src/graphics/fx.lua
function add_dust(_x,_y,_dx,_dy)
 add(graphics,{
  x=_x,
  y=_y,
  dx=_dx,
  dy=_dy,
  r=rnd(3),
  draw=function(self)
   circfill(self.x,self.y,self.r,13)
  end,
  update=function(self)
   self.r -= 0.05
   if self.r < 0 then
    del(graphics, self)
   end
   if self.dy > -0.75 then
    self.dy= (self.dy - 0.75) / 2
   end
   if self.dx < -0.05 then
    self.dx += 0.05
   elseif self.dx > 0.05 then
    self.dx -= 0.05
   else
    self.dx=0
   end
   self.x += self.dx
   self.y += self.dy
  end
 })
end

function add_wipe(color, speed)
 add(graphics,{
  a = 0,
  b = 0,
  draw=function(self)
   local a = self.a
   local b = self.b
   local x = cam.x + 63
   local y = cam.y + 63
   for i = a, b do
    --fillp(-32736)
    rect(x - i, y - i, x + i, y + i, 8)
    --fillp()
   end
  end,
  update=function(self)
   self.b += 5
   if self.b >= 64 then
    self.a += 5
   end
   if self.a > 128 then
    del(graphics, self)
   end
  end
 })
end

function add_swoosh(_x,_y)
 add(graphics,{
  x=_x,
  y=_y,
  t=0,
  r=10,
  phi=4,
  thta=0,
  speed = 0.05,
  draw=function(self)
   for i=1,10 do
    local theta=(0.03*i)+self.thta
    local phi=(0.1*i)*self.phi
    local r=self.t
    circfill(self.x+r*cos(theta),self.y+r*sin(theta),phi,7)
   end
  end,
  update=function(self)
   self.t += 1
   self.thta = (self.speed * (self.t))
   if self.phi < 0 then
    del(graphics, self)
   end
   self.phi -= self.speed
  end
 })
end

function add_rain()
 add(rain,{
  x = flr(rnd(128)),
  y = flr(rnd(128)),
  l = flr(rnd(7)),
  s = (flr(rnd(3)) + 3) * 0.75,
  draw = function(self)
   for i = 1, self.l do
    local colr=0
    if i < 0.2 * self.l then
     colr = 0
    elseif i < 0.7 * self.l then
     colr = 13
    else
     colr=1
    end
    pset(self.x+cam.x+i,self.y+cam.y-i,colr) 
   end
  end,
  update=function(self)
   -- move rain drop
   self.x -= self.s
   self.y += self.s
   -- loop rain drop
   if self.x<-4 then
    self.x+=132
   end
   if self.y > 132 then
    self.y -= 132
   end
  end
 })
end

function add_splashes_at_random(rain_percent)
 -- for any map tile within [cam.x, cam.x + 128] x [cam.y, cam.y + 128] with flag 0=TRUE
 -- give a 'rain_percent'% chance it will add a splash at that tile
 local x = flr(cam.x / 8)
 local y = flr(cam.y / 8)
 for x_tile = x, x + 16 do
  for y_tile = y, y + 16 do
   -- Check if flag 0 is TRUE (you may need to modify this part)
   if fget(mget(x_tile, y_tile), 0) then
    -- Calculate a random number between 0 and 99 (inclusive)
    local random_chance = flr(rnd(100))
    -- Check if the random chance is less than rain_percent
    if random_chance < rain_percent then
     add_splash(x_tile, y_tile)
    end
   end
  end
 end
end

function add_splash(x_tile, y_tile)
 add(splashes, {
  ground = 8 * y_tile,
  x = 8 * x_tile + flr(rnd(8)),
  y = 8 * y_tile,
  dy = -flr(rnd(10)) / 10,
  dx = -flr(rnd(10)) / 50,
  t = 0,
  draw = function(self)
   pset(self.x, self.y, 7)
   pset(self.x + self.dx, self.y + self.dy, 13)
  end,
  update = function(self)
   self.t += 1
   if self.t >= 360 then
    del(splashes, self)
   end
   self.dy += 0.1
   self.x += self.dx
   self.y += self.dy
   if self.y > self.ground then
    del(splashes, self)
   end
  end
 })
end-->8
--src/graphics/ui.lua
function draw_moon_counter(number)
 sspr(8, 16, 24, 8, cam.x + 128 - 17 - 8, cam.y + 1)
 print(tostr(number), cam.x + 128 - 7 - 8, cam.y + 2, 7)
end

function draw_death_counter(number)
 sspr(32, 16, 24, 8, cam.x + 128 - 17 - 8, cam.y + 10)
 print(tostr(number), cam.x + 128 - 6 - 8, cam.y + 11, 7)
end

function draw_rounded_rectangle(x, y, width, height, radius, color)
 rectfill(x + radius, y, x + width - radius - 1, y + height - 1, color)
 rectfill(x, y + radius, x + width - 1, y + height - radius, color)
 circfill(x + radius, y + radius, radius, color)
 circfill(x + width - radius - 1, y + radius, radius, color)
 circfill(x + radius, y + height - radius - 1, radius, color)
 circfill(x + width - radius - 1, y + height - radius - 1, radius, color)
end

function draw_rounded_textbox(x_tile, y_tile, text)
 local max_width = 100
 local radius = 2
 local padding = 2
 local text_color = 7 -- Change this to your desired text color
 local background_color = 13 -- Change this to your desired background color

 -- Calculate the width of the text box based on the text length and the maximum width
 local text_width = min(max_width, #text * 4 + 2 * padding)
 local width = text_width + 2 * radius

 -- Split the text into lines based on the width
 local lines = split_text(text, text_width)

 -- Calculate the height based on the number of lines
 local line_height = 8
 local height = (#lines * line_height) + (2 * padding)

 -- Calculate the position to center the textbox above the tile
 local x = x_tile * 8 + 4 - width / 2
 local y = y_tile * 8 - height - 8

 -- Keeping text box on screen
 x = max(x, cam.x + 2)
 y = max(y, cam.y + 2)
 while x + width > cam.x + 128 do
  x -= 1
 end
 while y + height > cam.y + 128 do 
  y -= 1
 end

 -- Draw box
 draw_rounded_rectangle(x, y, width, height, radius, background_color)
 -- Draw each line of text
 for i, line in ipairs(lines) do
  print(line, x + padding, y + padding + (i - 1) * line_height, text_color)
 end
end

function split_text(text, max_width_pixels)
 local result = {}
 local start = 1
 local length = #text
 local line_width = 0
 local char_width = 4
 while start <= length do
  local end_pos = start
  line_width = 0
  while end_pos <= length do
   local char = sub(text, end_pos, end_pos)
   if char == '\n' then
    local line = sub(text, start, end_pos - 1)
    add(result, line)
    start = end_pos + 1
    break
   else
    line_width = line_width + char_width

    if line_width <= max_width_pixels then
     end_pos = end_pos + 1
    else
     local line = sub(text, start, end_pos - 1)
     add(result, line)
     start = end_pos
     break
    end
   end
  end
  if end_pos > length then
   local line = sub(text, start, length)
   add(result, line)
   break
  end
 end
 return result
end

function draw_float_meter()
 if state_is('floating') then
  rectfill(player.x - 1, player.y - 9,
  player.x + player.float_meter - 2, player.y - 9,
  8)
  rect(player.x-2,player.y-10,
  player.x+8,player.y-8, 2)
 end
end

-- ⬅️➡️⬆️⬇️❎🅾️
hover_key = {
 draw = function(obj)
  print('🅾️', obj.x, obj.y - obj.hover_height, 13)
 end,
 update = function(obj)
  obj.is_hovered = touch(player, obj) and not obj.is_held
  if obj.is_hovered then
   obj.hover_height = lerp(obj.hover_height, 8, 0.5)
   if btnp(4) then
    obj.is_held = true
    obj.is_hovered = false
   end
  else
   obj.hover_height = 0
  end
 end
}
-->8
--src/scenes/menu.lua
function menu.init()
 logo_x = 0
 logo_y = 0
 --music(46)
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
-->8
--src/scenes/game.lua

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

function game.draw()
 -- Clear the screen every frame
 cls(0)
 pal(0, 129, 1)
 pal(10, 1, 1)
 pal(9, 130, 1)
 pal(1, 131, 1)
 pal(11, 139, 1)
 for c in all(bg_graphics) do 
  c:draw() 
 end
 -- First render background rain
 for drop in all(rain) do
  drop:draw()
 end
 for l in all(lasers) do 
  l:draw()
 end

 -- Render map
 map(0,0)

 -- Render everything else
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
 for fan in all(fans) do 
  fan:draw()
 end
 for button in all(buttons) do 
  button:draw()
 end
 for block in all(interactive_blocks) do
  block:draw()
 end
 for block in all(dissolve_blocks) do
  block:draw()
 end
 -- Render player
 spr(player.current_sprite, player.x, player.y, 1, 1, player.flp)
 if debug_on then 
  player_debug_draw()
 end

 -- Float meter for umbrella
 if umbrella_collected then
  draw_float_meter()
 end
 for i = 1, #enm do
  local myenm=enm[i]
  spr(myenm.spr, myenm.x, myenm.y)	
 end
 for s in all(signs) do 
  s:draw()
 end
 draw_moon_counter(num_moons_collected)
 draw_death_counter(num_deaths)
 for g in all(graphics) do
  g:draw()
 end
 if debug_on then
  debug_draw()
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
 for ib in all(interactive_blocks) do
  ib_rspwn(ib)
 end
 for db in all(dissolve_blocks) do
  db.durability = 3
  db.is_dead = false
 end
 enm={}
 local my_en={}
 my_en.x=90
 my_en.y=20
 my_en.spr=54
 add(enm, my_en)
end

function game.init()
 --music(30)
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

-->8
--src/utility/collision.lua
function collides_with_block(obj, dir)
 for block in all(interactive_blocks) do
 end
end
--[[
 O*******
 ********
 ********
 ********
 ********
 ********
 ********
 O******* [left]

 *******O
 ********
 ********
 ********
 ********
 ********
 ********
 *******O [right]

 O******O
 ********
 ********
 ********
 ********
 ********
 ********
 ******** [up]

 ********
 ********
 ********
 ********
 ********
 ********
 ********
 O******O [down]
]]--

function collides_with_map2(x, y, w, h, dir)
 local x1, x2, y1, y2
 if dir == 'left' then
  x1, x2 = x / 8, x / 8
  y1, y2 = y / 8, (y + h) / 8
 elseif dir == 'right' then
  x1, x2 = (x + w) / 8, (x  + w) / 8
  y1, y2 = y / 8, (y + h) / 8
 elseif dir == 'up' then
  x1, x2 = x / 8, (x + w) / 8
  y1, y2 = y / 8, y / 8
 else 
  x1, x2 = x / 8, (x + w) / 8
  y1, y2 = (y + h) / 8, (y + h) / 8
 end
 return fget(mget(x1, y1)) | fget(mget(x2, y2))
end

function collides_with_map(obj, dir, flag)
 -- token saving? idek
 local x = obj.x
 local y = obj.y
 local dx = obj.dx
 local dy = obj.dy
 local w = obj.w
 local h = obj.h
 local hb = obj.hb

 --collision box
 local x1 = 0
 local x2 = 0
 local y1 = 0
 local y2 = 0

 --placing collision box
 if dir == "left" then
  x1 = x + hb.x1 - 1
  x2 = x + hb.x1 - 1
  y1 = y + hb.y1 + dy
  y2 = y + hb.y2 + dy - 3
 elseif dir == "right" then
  x1 = x + hb.x2 + 1
  x2 = x + hb.x2 + 1
  y1 = y + hb.y1 + dy
  y2 = y + hb.y2 + dy - 3
 elseif dir == "up" then
  x1 = x + hb.x1 + 3
  x2 = x + hb.x2 - 3
  y1 = y + hb.y1 + dy
  y2 = y + hb.y1 + dy
 elseif dir == "down" then	
  x1 = x + hb.x1 + dx
  x2 = x + hb.x2 + dx
  y1 = y + h
  y2 = y + h
 end

 --debug
 if debug_on then
  player.db.x1=x1
  player.db.y1=y1
  player.db.x2=x2
  player.db.y2=y2
 end

 --pixels to tiles
 x1 /= 8
 x2 /= 8
 y1 /= 8
 y2 /= 8

 --check collide (finally)
 if fget(mget(x1, y1), flag)
 or fget(mget(x1, y2), flag)
 or fget(mget(x2, y1), flag)
 or fget(mget(x2, y2), flag) then
  return true
 else
  return false
 end
end
--[[
function collides_with_map(_obj, _dir, _flag)
 local x = _obj.x
 local y = _obj.y
 local dx = _obj.dx
 local dy = _obj.dy
 local w = _obj.w
 local h = _obj.h
 local x1, x2, y1, y2
 if _dir == 'left' then
  x1 = x
  x2 = x + dx
  y1 = y
  y2 = y + h
 elseif _dir == "right" then
  x1 = x + w
  x2 = x + w + dx
  y1 = y
  y2 = y + h
 elseif _dir == "up" then
  x1 = x
  x2 = x + w
  y1 = y
  y2 = y + dy
 elseif _dir == "down" then	
  x1 = x
  x2 = x + w
  y1 = y + h
  y2 = y + h + dy
 end
 --debug
 if debug_on and _obj == player then
  player.db.x1 = x1
  player.db.y1 = y1
  player.db.x2 = x2
  player.db.y2 = y2
 end
 x1 /= 8
 x2 /= 8
 y1 /= 8
 y2 /= 8
 return fget(mget(x1, y1), _flag)
 or fget(mget(x1, y2), _flag)
 or fget(mget(x2, y1), _flag)
 or fget(mget(x2, y2), _flag)
end
]]
function touch(a, b)
 if a.x + a.w < b.x
  or b.x + b.w < a.x
  or a.y + a.h < b.y
  or b.y + b.h < a.y then
  return false
 else
  return true
 end
end

function adjacent_to_tile(obj, flag)
 local x1 = (obj.x - 1) / 8
 local x2 = (obj.x + obj.w + 1) / 8
 local y1 = (obj.y + 2) / 8
 local y2 = (obj.y + obj.h - 2) / 8
 if fget(mget(x1, y1), flag)
 or fget(mget(x1, y2), flag) then 
  return 'l'
 elseif fget(mget(x2, y1), flag)
 or fget(mget(x2, y2), flag) then
  return 'r'
 else
  return 'none'
 end
end

function is_off_screen(obj)
 local _ENV = obj
 return x > 1016 or x + w < 0 or y > 504 or y + h < 0
end
-->8
--src/utility/constants.lua
-- constants for player spawn location
--default_spawn_x = 102 *8 or 2 * 8
--default_spawn_y = 21 * 8 or 35 * 8

default_spawn_x = 2 * 8
default_spawn_y = 35 * 8
pause_controls_duration = 0.75

-- physics constants
gravity = 0.18 or 0.19
floor_friction = 0.11
max_wall_slide_speed = 0.8

-- map limit constants
map_start = 0
map_end = 1024
map_top = 0
map_bottom = 64 * 8

-- player constants
float_depletion_rate = 0.1
acceleration = 0.15

-- camera constants
cam_speed = .925

-- debugging constant
debug_on = false
debug_color = 12

-- flag constants
save_flag = 3
moon_flag = 4
block_flag = 5
umb_spawn_x = default_spawn_x or 45 * 8
umb_spawn_y = default_spawn_y or 35 * 8
-->8
--src/utility/math.lua
function distance(x1, y1, x2, y2)
 return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function lerp(a, b, t)
 return a + (b - a) * t
end

function clamp(num,maximum)
 return mid(-maximum,num,maximum)
end

function center(x1, y1, x2, y2)
 return (x2 - x1) / 2, (y2 - y1) / 2
end-->8
--src/utility/debug.lua
debug_info = {}

function error(message) 
 local x, y = 2, 120
 if cam.x != nil and cam.y != nil then
  x += cam.x
  y += cam.y
 end
 print(message, x, y, debug_color)
end

function log(s)
 add(debug_info, s)
end

function debug_update()
 debug_info[1] = ' ram:'..stat(0)
 debug_info[2] = 'cput:'..stat(1)
 debug_info[3] = 'cpus:'..stat(2)
end

function debug_draw()
 -- Everything we are logging
 for i, message in ipairs(debug_info) do
  print(message, cam.x, cam.y + (i - 1) * 6, debug_color)
 end
 -- Hitbox display
 rect(
  player.db.x1,
  player.db.y1,
  player.db.x2,
  player.db.y2,
  11
 )
 print('dx = '..tostr(player.dx), cam.x, cam.y + 4 * 6, debug_color)
 print('dy = '..tostr(player.dy), cam.x, cam.y + 5 * 6, debug_color)
end-->8
--src/utility/physics.lua
function collision(obj)
 local collisions = 0
 if obj.dy > 0 then
  collisions = collides_with_map2(obj.x, obj.y + obj.dy, obj.w, obj.h, 'down')
  while (collisions & 1) != 0 and (obj.type != 'block' or (collisions & 64) == 0) do  
   obj.dy -= 1
   if obj.dy < 0 then 
    obj.dy = 0
    break
   end
   collisions = collides_with_map2(obj.x, obj.y + obj.dy, obj.w, obj.h, 'down')
  end
 elseif obj.dy < 0 then
  collisions = collides_with_map2(obj.x, obj.y + obj.dy, obj.w, obj.h, 'up')
  while (collisions & 2) != 0 and (obj.type != 'block' or (collisions & 64) == 0) do
   obj.dy += 1
   if obj.dy > 0 then 
    obj.dy = 0
    break
   end
   collisions = collides_with_map2(obj.x, obj.y + obj.dy, obj.w, obj.h, 'up')
  end
 end
 if obj.dx < 0 then
  collisions = collides_with_map2(obj.x + obj.dx, obj.y, obj.w, obj.h, 'left')
  while (collisions & 2) != 0 and (obj.type != 'block' or (collisions & 64) == 0) do
   obj.dx += 1
   if obj.dx > 0 then 
    obj.dx = 0 
    break
   end
   collisions = collides_with_map2(obj.x + obj.dx, obj.y, obj.w, obj.h, 'left')
  end
 elseif obj.dx > 0 then
  collisions = collides_with_map2(obj.x + obj.dx, obj.y, obj.w, obj.h, 'right')
  while (collisions & 2) != 0 and (obj.type != 'block' or (collisions & 64) == 0) do
   obj.dx -= 1
   if obj.dx < 0 then 
    obj.dx = 0 
    break
   end
   collisions = collides_with_map2(obj.x + obj.dx, obj.y, obj.w, obj.h, 'right')
  end
 end
end

function move(obj, flags)
 if obj.dy == 0 then
  obj.dx *= (1 - floor_friction)
 end
 obj.dy += gravity
 collision(obj, flags)
 obj.x += obj.dx
 obj.y += obj.dy
 if obj.x < map_start then
  obj.x = map_start
 elseif obj.x > map_end - obj.w then
  obj.x = map_end - obj.w
 end
end

__gfx__
00000000077777700000000007777770077777700000777007777770000000000777777070888800000000008000000800700000070000000000000000000000
00000000777277270777777077727727777277270077777777727727077777707772772708888280000000000000000007700000077007770007770077000777
00070070777877877772772777787787777877870777727777787787777277277778778788822200000000000000000007770000777077277077277007700070
00007700777777777778778777777777777777770727787777777777777877877777777788262000000000000000000007777007770072227072227007770070
00007700777777777777777777777777777777770787777777777777777777777777777788227000000d00000000000007707777070072227072227007070070
00070070077777707777777707777770077777700077777707777770777777770777777082200600000000000000000000700770070072827072827007077070
000000000070060007777770007006000070060000777777007006000777777670000006080000d00d000d0000000000d0700070070078887078887007007770
000000000070060000700600070006000070600000077700070060000077006000000000000006d0d0d0000080000008d07d0000070078887078887007000770
067767600660660000007000e0000ee0000eee000eee0000ee00000000000000000000000000000000011000e000000e07700000d70077877077877007000070
6dddddd66dd06d0600007000ee00eeee0eeeeeeeeeeee0eeeee00eee0000000d0000000000000000000110000000000007700000070007770007770077700777
7dddddd6600d00d600007000eee8e8e0ee8eeee0eeeeeee0eeeeeee0000000d10000000000000000000110000000000000700000070000000000000000000000
ddd88dd60ddd0dd600007000e8eeeee0eeee8ee0e8e8eee08e8eee80000000d111111111111110000001d11100000000007000d007077700000000d000000777
6d588d5d05d055dd00007000e88e88e0e8e88e808e8e8ee00ee8eee000000d1d11111111111d1000000111110000000000700000070007777777777777777700
65d5d5d6000d00000000600088e8e88eee8808ee880088ee088ee8ee00000111000000000001100000000000000000000070d00007000d00000d0d00000d0000
dd5d5d5d005505500000600008888000e8800000800008000008880000000d10000000000001100000000000000000000070000d0700ddd000000d00000d0000
0dddddd00000dd0000077700000000000000000000000000000000000000d100000000000001100000000000e000000e0000000007700d000d000d0000dd0070
066066600eeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeee0000000000000000000011000000110009000000900000000000000000000ddd0000d0070
6dd06dd6e2222222222222222222222ee2222222222222222222222e0000000000000000000110000001100000000000000077777770070000000d0000000770
6d6d0dd6e22272272222222222222228e2277722722222222222222e000000000000000000011000000110000000000000777770007700770000000700770077
dddd0dd682222722222222222222222e827272722222222222222228000110000001111100011000111d100000000000077d7000000770700777077007070070
d5d055dde2722727222222222222222ee27777727222222222222228000d10000001d11100011000111110000000000007d77000000070700070070007070070
000d000d82277222222222222222222882227722222222222222222e000110000001100000011000000000000000000077d70000000070700070077007000070
d555555082222222222222222222222882222222222222222222222800011000000110000001100000000000000000007dd70000000070700070070000700070
0dddddd008888888888888888888888008888888888888888888888000011000000110000001100000000000900000097dd70000000070700070070000770070
00000700000007000000700000070000000700000000800006666660000110000000000000000000000110000887e0007dd77000000070770770077000070070
0000007000000700000007000000700000070000000880006ddd6dd600011000000000000000000000011000088780007ddd7000000070077700000707700070
0000007700000070000007000000700000070000000878006d6dddd60001100000000000000000000000000000e788007ddd770077777000000dddd000000070
000000770000007000000700000070000007000000887800ddddddd6000d10000001d1111111d100111111110087e80007ddd7777dd770000ddd00dd00000070
000000770000007000000700000070000007000000887880d5d555dd000110000001111111111100111111110087e800077ddddddd7d77000d00000dd0000070
700007770700077000700700000770000007000008888880d55d555d0000000000000000000000000000000000e7e8000077ddddd77dd7770000dd00ddd00070
077777700000070000707700000770000007000008887888d555555d0000000000000000000000000001100008e788000007777777000000000dddd000dd0000
0077770000777700000770000007000000070000888888880dddddd0000000000000000000000000000110000887e80000000770000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
331313313133331313333133b33331333333133b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
113333333333133333313331b31333131313333b00000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000
313131311313311313133331b1311333133133130000000000000000000000300000000000000000000000000000000700000000000000000000000000000000
131933911331311919113131b33131331311133b000000b00000000003b000b00bb0000000006000006600000000000600000000077777777777000000000000
911113131939119111313913333111913113131300b0030b00003000b0030030000b00b000066d000666d0000000000600000777777777777777777766000000
919199399131919993193191b31391199111311b0b000003000b00000b030300000b0b03000060000666d0030000000d00077777777777777777777776660000
991999919999991919339999311119999191111303003003300303000003030003030300030060030666d0300000000607777776667777776667777777666000
31919191911911139999999931191999991911130000700000000006666666666000000000000000000000000000000007777668887777778886677767666660
31111919999111119999999931911999999119130000600000006666066667606660000000000000000000000000000077777882286777768228877777766666
3311911999191111999999993111119999119113000766000066767606d67d606776600000000000000000000000000077777828288777788282877777676666
3119191999919111999999993119919999199113006676007667d7660d66d60066d7d70007770000007700000000770077776872728777782727877777666666
3111119999111111999999993111191999911113006766d000d666d600d66d00d6666d6776667700076677000007667077778278828777782782877776766666
313119999991911999999999311911999919111306d76660000ddd6d00ddd000dd6dd60076666677076666770007666777778878888777788788877777666666
93111919999911919999999931119919991191130d6d66d000000dd6000d0000ddd000006ddddd6606dddd660006ddd677778eeee8777778eeee877777676666
1191999999999919999999993191199991991113ddd66ddd0000000d000d0000d0000000066666000066660000006660777778ee88777778eee8777776666666
0bbbbbbbbbbbbbbbbbbbbbb031919199999911130bbbbbb031191113000f40000000000000007000000000600100030077777888877777778887777777666666
b1333133311311311331313b3111999991919113b331333b31199113fffffff40000000000066000700007000030b30077777777777777777777777777766666
3515151515111551115115133111199999111113b313333331991913f44f4ff40000000000066000067076000b30010067777777777777777777777776666666
03333333333333333333333031191199119111133333133b31199113fffffff40000000076766d6600666000001b01b067777777776777777776777677666666
0030303003003030030303303111191111111113b313331b31191913f4f4f4f400000000066d66d0000d6d000030030067767777777777777777777777766666
00300030030000300300030031111119111111133119133331199113fffffff4000000000006d000006d0dd0b300103067776767776776767777767776666666
0000003000000030000003003311111111111133b3119113319191130004400000eee800000dd00000d0000d1300103b06777777777777777777777676766666
00000000000000000000000003333333333333303119911b31191113000f4000068888600000d0000d0000000100301006666676677667767776777767666666
0bbbbbb09999999999999999999999990bbbbbb0319999130bbbbbbbbbbbbbbbbbbbbbb070000006007000000000000000667666667777667666676666666660
b313313b991991999199191191991919b333333b31199113b3333333313133313333313b07000760006600000000000000006666766666666676666667666660
35551513911919119991919119119199b313131b31911313b3313113131313111331331b06606d00006d07660000000000000066666666666666667666666600
03333330191111119999191111199919313133333111911331311393993391919319313300676600000676d00000000000000000766666666666666666660000
00030300111191199991111911119999b119313b31391113b1319913913999391931913b0006d600006dd6000000000000000000776600000000076660000000
00030000111111111919111111191919b11311133111111331111311191111111919111b006d0dd066d0dd000000000000000000776600000000077660000000
000300001111111199111111111199993311113b331111333311111111111111111111330dd000d000006d000000000000000007776600000000777660000000
000000003333333391911113311191990333333003333330033333333333333333333330d000000d00000d000688886000000007776600000000777660000000
25450000000000070000757575750000062600000000000066000000348700000064000000640000550074000000000055000000000000000000000035668500
00656600b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b68500b0000000000000000063556600b00047850000006547000000
254500000000000000000000000000000000000000000000660000006685000000560000000700655685470000000065568500000063000000000000356685b0
00656600000000000000000000000000000000000000000000000000000000b600000000b6850000000000000000000055344500000047855555556547000000
25450000000000000000000000000000000054760000000057000000668500000066000000000065668500000000006566850000000000000000000035668500
00656600000000000000000000000000000000000000000000000000000000b600000000b68500070000000000000055340545b6b6b647857575756547000000
25450000000000000000000000000000000616162600000000000000668500006566b00000000065668500940000006566850000000000000000630035668500
00656600000000000000000000000000000000000000000000000000000000b600000000b6b65555555555555555556717174600000047000000000047000000
25450000000000000000000000000000000000000000000000000000668500006566260000000065668500470000006566850000000000000000000035668500
00656600000000000000000000000000000000000000000000000000000000b60000000000000000000000000000000000000000b00047474747474747000000
254584746484647694005555556400b1548455555555557484640000668555555566555555555565668574846454846566855464b18476a40000000035668500
b0656600000000000000000000000000000000000000000000000000000000b6000000000000000000000000000000000000000000000000000000b600000000
7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777787000000b035668500
00656600000000000000000000000000000000000000000000000000000000b6000000000000000000000000000000000000000000000000000000b600000000
0000000000000000000000000000000000000000000000000000000000667575757575000000000000000000000000000000757565354585000000b035668500
00656600000000000000000000000000000000000000000000000000000000b6000000000000000000000000000000000000000000000000000000b600000000
0000000000000000000000000000000000000000b0000000000000000066850000000000000000000000000000000000b000000065354585000000b035668583
81656600000000000000000000000000000000000000000000000000000000b60000000000000000000000000000000000000000b1000000000000b600000000
0000000000000000000000000000000000b000000000000000b1000000660000000000000000000000000000000000000000000065354585000000b035668500
00656600000000000000000000000000000000000000000000000000000000b6000000000000000000000000000000000000061616162600000000b600000000
00000000b000000000b000000000b00000000000000000000056000000660000003414144455000000005534141444000000000000354585000000b035668500
b0656600000000000000000000000000000000000000000000000000000000b6000000000000000000000000000000000000000000000000000000b600000000
000000000000000000000000000000000000006400000000006600000066000000361717461616161616163617174600000000b000354585000000b035668500
00656600000000000000000000000000000000000000000000000000000000b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b600000000
0000a40000000000000000940000000000000056850000000066000000660000000066000000000000000000656600000000000000354585000000b035668500
00656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000007000000000000000007000000005500003644850000006600000066000000006600000000b0b00000b0656600000000000000354585000000b035668500
00656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555000000005555555555555556000074668785000066850000660000000066000000654700000000656600000065341414054585000000b035668500
00656677777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777448500006534777777777777460000344685000000668500b0660000000066000000000000000000656600000065361717174685000000b036668500
b0000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
450084b0668500006566000000000000000034468500000000660000006600000000660000000000000000006566000000000000000000000000000065668500
00000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45003414458500006557006484640000000066850000000065660000656600000000660007000000000000006566850000000000000000000000000065668500
00000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500361746000000000000061656850064006685000000653466b000656685000065665555555555000000006566850000000000000000000000007465668500
00000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45007500000000000000000000668500470066850000656777660000005785000065367777777787000047006566850000062600000000000000000765351477
77777777777777774400003677777777777777777777777777777777440000000000000000000000000000000000000000000000000000000000000000000000
4500000000647484640000b18466850000006685000000653666000000000000000000000000000000000000656685000000000084745484b1740000653545b2
00000000000000656600007272727272727272727272727272727272367777777777440000000000000000000000000000000000000000000000000000000000
45006454006777778700061616162600000036448500000065660064748454640000547484945484745400006566850000000000061616161626000065354500
b0000000000000656600009292929292929292929292929292929292000000000000660000000000000000000000000000000000000000000000000000000000
45000626005555555555555555555500740000364485000000367777777714777777777777777777777777774466555555555555555555555555555555354500
00000000000000656600b17373737373737373737373737373737373000000006300660000000000000000000000000000000000000000000000000000000000
45555555553424041424140424144485470000b33687850000000000000066850000b07265660000000000003677777777777777777777777777777777174616
26000000000000653677777777777777777777777777777777777744850000000000660000000000000000000000000000000000000000000000000000000000
14241404142717171717171717174685000000b30000b600000000000000668500000092656600b0000000000000000000000000000000000000000000000083
81818181818181937575757575757575757575757575757575756566850000000000660000000000000000000000000000000000000000000000000000000000
17171717174675757575757575757500000000b30000b6000000b000000066850000009265660000000000b00000000000000000000000000000000000000000
00000000000000000000838181818181818181818181818181936566850000000000660000000000000000000000000000000000000000000000000000000000
00b67575757500000000000000000000000000560000b60000000000b20066856300009265570000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000006536777777440000660000000000000000000000000000000000000000000000000000000000
00b60000000000000000000000b0000000000066648456546474846400a4668500000092000000000000655600000000b0000000000000000000000000000000
000000636300000000000000000000000000000000000000000000b6000000660000660000000000000000000000000000000000000000000000000000000000
00b600b20000b0000000000000000000000000367777177777777777777746850000007300000000636365660000000000000000000064740000000000000000
000000000000000000b0000000000000000000000000b000000000b6000000570000660000000000000000000000000000000000000000000000000000000000
b0b600b000000000000054000000000000740000000000b3000000000000000000000000000000000000656683818181818181818193344400b1000000000000
000000000000000000000000000000000000000000000000000000b6000000b30000660000000000000000000000000000000000000000000000000000000000
005600a400000000000007000000000000070000000000b3000000b1000064845464000000547484000065660000630000000063000035451616260000006363
838181818181818181818181818181818181818181818181818193b6000000b30000660000000000000000000000000000000000000000000000000000000000
77460007000000000000000000000000000000003444635663342404242424242444000006161626000065660000000000000000000035450000000000000000
00000006162600006363630000000063630000000000630000000067777777777777460000000000000000000000000000000000000000000000000000000000
__label__
h1h1h1h1h1h1h1h1h1h1h1h1hdh1h1h1h1h1h1h1h1h1h1hjh1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhjhhhhhhhh1h1h1h1h1h1h1h1
1h1h1h1j1h1h1h1h1h1h1h1hdh1h1h1h1h1h1h1h1h1h1hjh1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdeeeeeeeeeeeeeeeeeeeeee1h
h1h1h1j1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hdh1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhde2222222227772222222222e1
1h1h1d1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hdh1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhe22272272272722222222228h
h1h1d1h1hjh1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hdh1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhh82222722227772222222222e1
1h1d1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhe2722727222272222222222eh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhh8227722222227222222222281
1h1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhh822222222222222222222228h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhjhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhhhe8888888888888888888888h1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1hhhhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhe8e8eeeh7hhhhhhhh1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1d1h1h1h1hhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8eeeeeeeeeeeeeeeeeeeeeeh1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhe2222222222772277722222eh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhe2277722722272222722222e1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh827272722222722777222228h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhe277777272227227222222281
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh82227722222777277722222eh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222222222222222222281
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhh8888888888888888888888hh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhhhhh3333j33rhhhhhhhhhhhhj
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhhhhhhr3j333jrhhhhhhhhhhhjh
h1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjij333hhhhhhhhhhdhh
1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1h1h1h1h1h1hjh1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhr3jjijj3hhhhhhhhhdhhh
h1h1h1h1h1h1h1h1h1h1h1h1d1h1h1h1h1h1h1h1hdh1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhh3jjiijjrhhhhhhhhhhhhh
1h1h1h1h1h1h1h1h1h1h1h1d1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhh3jjijjj3hhhhhhhhhhhhh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhjh3jjiijj3hhhhhhhhhhhhh
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhh3jiijij3hhhhhhhhhhhhh
h1h1h1j1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhh3jjiijj3hhhhhhhhhhhhh
1h1h1d1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjijij3hhhhhhhhhhhhh
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhhh3hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjiijj3hhhhhhhhhh1h1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhrhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jijijj3hhhhh1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhh3hh3h3hhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhhhhhd3jjijjj3hh1h1h1h1h1h1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhhhhrrrrrrh6hhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhhhhdh3jjijjj3h1h1h1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1hhhhhhhhhhhhhr33j333r666hhhhhhhhhhdhhhhhhhhhhhhhhhhhjhhhhhdhh3jjiijj31h1h1h1h1h1h1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1j1h1h1h1hhhhhjhhhhhhr3j3333367766hhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhh3jiijij3h1h1h1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1d1h1h1h1hhhhhjhhhjhhh3333j33r66d7d7hhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhh3jjiijj31h1h1h1h1hjh1
1h1h1h1hjh1h1h1h1h1h1h1h1h1h1h1h1h1h1d1h1h1h1hhhhrdhhhhhhhhr3j333jrd6666d67hhhhhhhhhhhhhhhhhhhhdhhhhhhhhhh13jjijij3h1h1h1h1hjh1h
d1h1h1hjh1h1h1h1h1j1h1h1h1h1h1h1h1h1d1h1h1h1hrhh3drhhhhhhhh3jjij333dd6dd6hhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhh1h3jjiijj31h1h1h1hdh1h1
1h1h1hdh1h1h1h1h1j1h1h1h1h1h1h1h1h1h1h1h1h1hrdhhdh3hjhhhhhhr3jjijj3dddhhhhhhhhhhhhhhhhhhhhhhhjhhhhhjhhhh1h13jijijj3h1h1h1hdh1h1h
h131hdh1h1h1h1h1d1h1h1h1h1h1h1h1h1h1h1h1h1hh37h37h3jhhhhhhh3jjiijjrdhhhhhdhhhhhhhhhhhhhhhhhhjhhhhhhhhhh1h1h3jjijjj31h1h1hdh1h1h1
rr1hdh1h1h1h1h1d1h1h1h1h1h1h1h1h1h1h1h171h1hrrrrrrdhhhhhhhh3jijijiirrrrrrrh6hhhhhhhhhhhhhhhjhhhhhhhh1h1h1h13jjijjj3h1h1h1h1h1h1h
j3r1h1h1h1h1h1d1h1h1h1h1h1h1h1h1h1h1h1h6h1hr33j333rhhhhhhhh3jjjiiii3333j33r666hhhhhhhhhhhhdhhhhhhhh1h1h1h1h3jjiijj31h1h1h1h1h1h1
5j3h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h766hhr3j33333hhhhhhhh3jjjjiiij3j3333r67766hhhhhhhhhdhhhhhhhh1h1h1h1h13jiijij3h1h1h1h1h1h1h
33h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h6676hh3333j33rhhhhhhhh3jjijjiij33j33j366d7d7hhhhhhhhhhhhhhhh1h1h1h1h1h3jjiijj31h1h1h1h1h1h1
3h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h16766dhr3j333jrhhhhhhhh3jjjjijjj3jjj33rd6666d67hhhhhhhhhhhhh1h1h1h1h1h13jjijij3h1h1h1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h16dd666h3jjij333hhhhhhhh3jjjjjji3jj3j3j3dd6dd6hhhhhhhhhhhhhhhh1h1h1h1h1h3jjiijj31h1h1h1h1h1h1
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hd6d66dhr3jjijj3hhhhhhhh33jjjjjjijjj3jjrdddhhhdhhhhhhhhhhhhhh1h1h1h1h1h13jijijj3h1h1h1h1h1h1h
h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hddd66ddd3jjiijjrhhhhhhhhh3333333ijijjjj3dhhhhh7hhhhhhhhhhhhh1h1h1h1h1h1h3jjijjj31h1h1h1h1h1h1
1h1h1h171h1h1h171h1h1h171h1h1h171h1hrrrrrrriiiijjj3hhhhhhhhhhhhhhhh3jjijjj3rrrrrrrh6hhhhhhhhhh1h1h1h1h1h1h13jjijjj361h1h1h1h1h1h
h1h1h1h6h1h1h1h6h1h1h1h6h1h1h1h6hhhr3333j33ijijijj3hhhhhhhhhhhhhhhh3jjiijj333333j3r666hhhhjhh1h1h1h1h1h1h1h3jjiijj3666h1h1h1h1h1
6h1h1h766h1h1h766h1h1h766h1h1h766hhr3j333j3iijjjjj3hhhhhhhhhhhhhhhr3jiijij3j33j33jr67766hhhh1h1h1h1h1h1h1h13jiijij3677661h1h1h1h
61h1h66761h1h66761h1h66761h1h6676hhrj3jj333jjijjjj3hhhhhhhhhhhhhh3h3jjiijj3i3ji3j3366d7d7hh1h1h1h1h1h1h1h1h3jjiijj366d7d71h1h1h1
6d1h16766d1h16766d1h16766d1h16766dhr33j3j33jjjjjjj3hhhhhhhhh3rhhhrh3jjijij3ji3jij3rd6666d67h1h1h1h1h1h1h1h13jjijij3d6666d67h1h1h
66h16d7666h16d7666h17d7666hh6d7666h333jjjijjjjjjjj3hhhhhhhhdd73hh3h3jjiijj3jijijjjrdd6dd6hh1h1h1h1h1h1h1h1h3jjiijj3dd6dd61h1h1h1
6d1hd6d66d1hd6d66d1hd6d66dhhd6d76d1r3j3ijjijjjjjj33hhhhhhhhhrh3h3hh3jijijj3jjjjjj33dddhhhh1h1h1h1h1h1h1h1h13jijijj3ddd1h1h1h1h1h
dddddd66dddddd66dddddd67dd7ddd6dddd3jjjjiii3333333hhhhhhhhhhhh3h3hh3jjijjj33333333hdhhhhh1h1h1h1h1h1h1h1h1h3jjijjj3dh1h1h1h1h1h1
rrrrrrrrrrrrrrrrrrrrrrrdrrdrrrrrrrriiiijjj3hhhhhhhhhhhhhhhhhrrrrrrriiiijjj36hhhhhhhhhhhhhh1h1h1h1h1h1h1h1h13jjijjj361hjh1h1h1h1h
33j3j3j333j3j3j333j3j3j333j3j3j333jijijijj3hhhhhhhhhhhhhhhhr3333j33ijijijj3666hhhhhhhhhhh1h1h1h1h1h1h1h1h1h3jjiijj3666h1h1h1h1h1
3jjj3j3j3jjj3j3j3jjj3j3j3jjj3j3j3jjiijjjjj3hhhhhhhhhhhhhhhhr3j333j3iijjjjj367766hhhhhhhh1h1h1hjh1hjh1h1h1h13jiijij3677661h1h1h1h
jijii33ijijii33ijijii33ijijii33ijijjjijjjj3hhhhhhhhhhhhhhhhrj3jj333jjijjjj366d7d7hhhhhhhh1h1h1h1h1h1h1h1h1h3jjiijj366d7d71h1h1h1
i3iij3iii3iij3iii3iij3iii3iij3iii3ijjjjjjj3hhhhhhhhhhhhhhhhr33j3j33jjjjjjj3d6666d67hhhhh1h1h1h1h1h1h1h1h1h13jjijij3d6666d67h1h1h
jjjjijjjjjjjijjjjjjjijjjjjjjijjjjjjjjjjjjj3hhhhhhhhhhhhhhhh333jjjijjjjjjjj3dd6d22222222222h1h1h1h1h1h1h1h1h3jjiijj3dd6dd61h1h1h1
jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj33hhhhhhhhhhhhhhhhr3j3ijjijjjjjj33dddh2888hhhhh121h1h1h1h1h1h1h1h13jijijj3ddd1h1h1h1h1h
333333333333333333333333333333333333333333hhhhhhhhhhhhhhhhh3jjjjiii3333333hdhhh22222222222h1h1h1h1h1h1h1h1h3jjijjj3dh1h1h1h1h1h1
hhhhhhhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhrrrrrrriiiijjj36hhhhhhhhhhhhhhhhhh1h1h1h1h1h1h1h1h1h1h13jjijjj3h1h1h1h1h1h1h
hhhhhhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhr3333j33ijijijj3666hhhhhhhhhhhhhhhhh1h1h1h1h1h1h1h1h1h1h3jjiijj31h1h1h1h1h1h1
hhhhhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhr3j333j3iijjjjj367766hhhhhhhhhhhhhh1h8888171h1h1h1h1h1h13jiijij3hjh1h1h1h1h1h
hhhhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhrj3jj333jjijjjj366d7d7hhhhhhhhhhhhhh8288881h1h1h1h1h1h1h3jjiijj31h1h1h1h1h1h1
hhhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdr33j3j33jjjjjjj3d6666d67hhhhhhjhhhh1h2228881h1h1h1h1h1h13jjijij3h1h1h1h1h1h1h
hhdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdh333jjjijjjjjjjj3dd6dd6hhhhhhhdhhhh1h1h26288h1h1h1h1h1h1h3jjiijj31h1h1h1h1h1h1
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhr3j3ijjijjjjjj33dddhhhhhhhhhdhhhhhh1h1722881h1h1h1h1h1h13jijijj3h1h1h1h1h1h1h
hhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjjjiii3333333hdhhhhhhhhhhhhhh77777761h228h1h1h1h1h1h1h3jjijjj31h1h1h1h1h1h1
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhhh3jjijjj36hhhhhhhhhhhhhhhhhhhhh72772777h1h8h1h1h1h1h1h1h63jjijjj3h1h1h1h1h1h1h
hhhhhhhhhhhhhhhhhhhhhhhhhhhhdhhhhhhhhhhhhhhhhhhhhhh3jjiijj3666hhhhhhhhhhhhhhhhhhh787787771h1h1h1h1h1h1h66663jjiijj31h1h1h1h1h1h1
hhhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jiijij367766hhhhhhhhhhhhhhhhh77777777h1h1h1h1h1h16676763jiijij3h1h1h1h1h1h1h
hhhhhhhhhhhhhhhhhhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjiijj366d7d7hhhhhhhhhhhhhhhh777777771h1h1h1h1h7667d7663jjiijj31h1h1h1h1h1h1
hhhhrrhhhhhhhhhhhdhhh66hhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjijij3d6666d67hhhhhhhhhhhhhhh7777771h1h1h1h1h1d1d666d63jjijij3h1h1h1h1h1h1h
hhhhhhrhhrhhhhh3dhhh666dhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjiijj3dd6dd6hhhhhhhhhhhhhhhh6hhh1h171h1h1h1h1h1h1ddd6d3jjiijj31h1h1h1h1h1h1
d7hhdhrhrh3hdhrdhhhh666dhh3hhhhhhhhhhhhhhhhhhhhhhhh3jijijj3dddhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1h1h1h1h1hdd63jijijj3h1h1h1h1h1h1h
3hhh7h3h3hh3hh3h3hhh666dh3hhhhhhhhhhhhhhhhhhhhhhhhh3jjijjj3dhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1h1h1h1h1h1h1d3jjijjj31h1h1h1h1h1h1
rrrrrrrrrrrhrrrrrrrrrrrrrrh6hhhhhhhhhhhhhhhhhhhhhhh3jjijjj36hhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1h1h6hrrrrrrr3jjijjj3h1h1h1h1h1h1h
j333jj3jj3jr3333j3333333j3r666hhhhhhhhhhhhhhhhhhhhh3jjiijj3666hhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h6666r3333j333jjiijj31h1h1h1h1h1h1
5j5j5jjj55jr3j333j3j33j33jr67766hhhhhhhhhhhhhhhhhhh3jiijij367766hhhhhhhhhhhhhhhhhhhhhh1h1h1h1667676r3j333j33jiijij3h1h1h1h1h1h1h
33333333333rj3jj333i3ji3j3366d7d7hhhhhhhhhhhhhhhhhh3jjiijj366d7d7hhhhhhhhhhhhhhhhhhhhhh1h1h7667d766rj3jj3333jjiijj31h1h1h1h1h1h1
h3hh3hh3h3hr33j3j33ji3jij3rd6666d67hhhhhhhhhhhhhhhh3jjijij3d6666d67hhhhhhhhhhhhhhhhhhh1h1h1h1d666d6r33j3j333jjijij3h1h1h1h1h1h1h
h3hh3hhhh3h333jjjijjijijjjrdd6dd6hhhhhh3hhhhhhhhhhh3jjiijj3dd6dd6hhhhhhhhhhhhhhhhhhhhhh1h1h1h1ddd6d333jjjij3jjiijj31h1h1h1h1h1h1
h3hhhhhhh3hr3j3ijjijjjjjj33dddhhhhhhhhrh7hhhhhjhhhh3jijijj3dddhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1hdd6r3j3ijji3jijijj3h1h1h1h1h1h1h
hhhhhhhhhhh3jjjjiii3333333hddhhhhhh3hh3hdhhhhjhhjhh3jjijjj3dhhhhhhhhhhhhhhhhhhhhhhhhhhh1h17dh1h1h1d3jjjjiii3jjijjj31h1h1h1h1h1h1
hhhhhhhhhhh3jjijjj36hhhhhhhdhhhhhhhhrrrrrrhhdhhdhhh3jjijjj36hhhhhhhhhhhhhhhhhhhhhhhhhhhh1hdhrrrrrrrrrrrrrrr3jjijjj3h1h1h1h1h1h1h
hhhhhhhhhhh3jjiijj3666hhhhhhhhhhhhhr333333rdhhdhhhh3jjiijj3666hhhhhhhhhhhhhhhhhhhhhhhhh6666r33333333j3j333j3jjiijj31h1h1h1h1h1h1
hhhhhhhhhhh3jiijij367766hhhhhhhhhhhr3j3j3jrhhhhhhhh3jiijij367766hhhhhhhhhhhhhhhhhhhhh667676r33j3jj3j3j3j3jj3jiijij3h1h1h1h1h1h1h
hhhhhhhhhhh3jjiijj366d7d7hhhhhhhhhh3j3j3333hhhhhhhh3jjiijj366d7d7hhhhhhhhhhhhhhhhhh7667d7663j3jj3i3ii33ijij3jjiijj31h1h1h1h1h1h1
hhhhhhhhhhh3jjijij3d6666d67hhhhhhhhrjji3j3rhhhhhhhh3jjijij3d6666d67hhhhhhhhhhhhhhhhhhd666d6rj3jiij3ij3iii3i3jjijij3h1h1h1h1h1h1h
hhhhhhhhhhh3jjiijj3dd6dd6hhhhhhhhhhrjj3jjj3hhhhhhhh3jjiijj3dd6dd6hhhhhhhhhhhhhhhhhhhdhddd6d3jjjj3jjjijjjjjj3jjiijj31h1h1h1h1h1h1
hhhhhhhhhhh3jijijj3dddhhhhhhhhhhhhh33jjjj3rhhhhhhhh3jijijj3dddhhhhhhhhhhhhhhhhhhhhhdhhhhdd633jjjjjjjjjjjjjj3jijijj3h1h1h1h1h1h1h
hhhhhhhhhhh3jjijjj3dhhhhhhhhhhhhhhhh333333hhhhhhhhh3jjijjj3dhhjhhhhhhhhhhhhhhhhhhhhhhhhhhjd13333333333333333jjijjj31h1h1h1h1h1h1
hhhhhhhhhhh3jjijjj36hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjijjj36hdhhhhhhhhhhhhhhhhhhhhhhhhhhjhhh1h1h1h63jijijii3jjijjj3h1h1h1h1h1h1h
hhhhhhhhhhh3jjiijj3666hhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjiijj3666hhhhhhhhhhhhhhhhhhhhhhhhhdhhh1h1h66663jjjiiii3jjiijj31h1h1h1h1hjh1
hhhhhhhhhjh3jiijij367766jhhhhhhhhhhhhhhhhhhhhhhhhhh3jiijij367766hhhhhhhhhhhhhhhhhhhhhhdhhhhh16676763jjjjiii3jiijij3h1h1h1h1hjh1h
hhhhhhhhjhh3jjiijj366d7d7hhhhhhhhhhhhhhhhhhhhhhhhhh3jjiijj366d7d7hhhhhhhhhhhhhhhhhhhhdhhhhh7667d7663jjijjii3jjiijj31h1h1h1hdh1h1
hhhjrrhdhhh3jjijijdd6666d67hhhhhhhjhhhhhhhhhhhhhhhh3jjijij3d6666d67hhhhhhhhhhhhhhhhhhhhhhhhhhd666d63jjjjijj3jjijij3h1h1h1hdh1h1h
hhdhhhrhhrh3jjiijj3dd6dd6hhhhhhhhdhhhhhhhhhhhhhhhhh3jjiijj3dd6dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhddd6d3jjjjjji3jjiijj31h1h1hdh1h1h1
hdhh7drhrh33jijijj3dddhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jijijj3dddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd633jjjjjj3jijijj3h1h1hhh1h1h1h
7hhhdh3h3hh3jjijjj3dhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjijjj3dhhh7jhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1d133333333jjijjj31h1h1h1h1h1h1
rrrrrrrrrrrrrrrrrrrrrrrrrrhhhhhhhhhhhhhhhhhhhhhhhhh3jijijiirrrrdrrh6hhhhhhhhhhhhhhhhjhhhhhhhhhhh1h1h1h1h1h63jjijjj3h1h1h1h1h1h1h
j3j3jj3jj3j3jj3jj3jj33j3j3rhhhhhhhhhhhhhhhhhhhhhhhh3jjjiiii3333j33r666hhhhhhhhhhhhhjhhhhhhhhhhhhh1h1h1h66663jjiijj31h1h1h1h1h1h1
55jj5jjj55jj5jjj55jjj5jj5j3hhhhhhhhhhhhhhhhhhhhhhhh3jjjjiiij3j3333r67766hhhhhhhhhhdhhhhhhhhhhhhhhh1h16676763jiijij3h1h1h1h1h1h1h
33333333333333333333333333hhhhhhhhhhhhhhhhhhhhhhhhh3jjijjiij33j33j366d7d7hhhhhhhhdhhhhhhhhhhhhhhhhh7667d7663jjiijj31h1h1h1h1h1h1
h3hh3hh3h3hh3hh3h3hh3h3h33hhhhhhhhhhhhhhhhhhhhhhhhh3jjjjijjj3jjj33rd6666d67hhhhhdhhhhhhhhhhhhhhhhhhh1d666d63jjijij3h1h1h1h1h1h1h
h3hh3hhhh3hh3hhhh3hh3hhh3hhhhhhhhhhhhhhhhjhhhhhhhhh3jjjjjji3jj3j3j3dd6dd6hhhhhhhhhhhhjhhhhhhhhhhhhhhhhddd6d3jjiijj31h1h1h1hjh1h3
h3hhhhhhh3hhhhhhh3hhhhhh3hhhhhhhhhhhhhhhjhhhhh1h1h133jjjjjjijjj3jjrdddhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdd63jijijj3d1h1h1hjh1hrh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhjhhhhhhhhdh1h1h1h1h1h13333333ijijjjj3dhhhdjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1d3jjijjj31h1h1hdh3h131
hhhhhhh7hhhhhhh7hhhhhhh7hhhhhdhhhhhh1hdh1h1h1h1h1h1h1h1h1h13jijijiirrrrrrrh6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh13jijijiirrrrrrrrrrrrr
hhhhhhh6hhhhhhh6hhhhhhh6hhhhhhhhh1h1h1h1h1h1h1h1h1h1h1h1h1h3jjjiiii3333j33r666hhhhhhhhhhhhhhhhhhhhhhhhhhhhh3jjjiiii3j3j333j3j3j3
6hhhhh766hhhhh766hhhhh766hhhhhhh1h1h1h1h1hrh1h1h1h1h1h1h1h13jjjjiiij3j3333r67766hhhhhhhhhhhhhhhhhhhhhhhhhhh3jjjjiiij3j3j3jjj3j3j
6hhhh6676hhhh6676hhhj6676hhhh1h1h1h1h1h1h3h1h1h1h1h1h1h1h1h3jjijjiij33j33j366d7d7hhhhhhhhhhhhhhhhhhhhhhhhhh3jjijjiiii33ijijii33i
6dhhh6766dhhh6766dhdh6766dhh1h1h1h1h3r1h1rjh1h1h1h1h1h1h1h13jjjjijjj3jjj33rd6666d67hhhhhhhhhhhhhhhhhhhhhhhh3jjjjijjij3iii3iij3ii
66hh6d7666hh6d76667h6d7666h1h1h1h1hrh131h3h1h1h1h1h1h1j1h1h3jjjjjji3jj3j3j3dd6dd6hhhhhhhhhhhhhhhhhhhhhhhhhh3jjjjjjijijjjjjjjijjj
6dhhd6dd6dhhddd66ddhd6d66d1h1h1h1h1hrh3h3h1h1h1h1h1h1d1h1h133jjjjjjijjj3jjrddd1hhhhhhhhhhhhhhhhhhhhhhhhhhhh33jjjjjjjjjjjjjjjjjjj
dddddd67dddddd6dd7dddd66ddd1h1h1h1h1h13d31h1h1h1h1h1h1h1h1h13333333ijijjjj3dh1d1hhhhhhhhhhhhhhhhhhhhhhhhhhhh33333333333333333333
rrrrrrrrrrrrrrrrrdrrrrrrrr161h1h1h1hrrrrrr1h1h1h1h1h1h1h1h1h1h1h1h13jijijiirrrrrrrh6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1h1h
33jj3333j333j3333j33333j33r666h1h1hr333333r1h1h1h1j1h1h1h1h1h1h1h1h3jjjiiii33333j3r666hhhhhhhhhhhhhhhhhhhhhhjhhhhhhhh1h1h1h1h1h1
333333j333j3333j333j3j3333r677661h1r3j3j3jrh1h1h1j1h1h1h1h1h1h1h1h13jjjjiiij33j33jr67766hhhhhhhhhhhhhhhhhhhdhhhhhhhhhh1h1h1h1h1h
j3jj3j3333jj3j33jj3j33j33j366d7d71h3j3j33331h1h1d1h1h1h1h1h1h1h1h1h3jjijjiii3ji3j3366d7d7hhhhhhhhhhhhhhhhhdhhhhhhhhhh1h1h1h1h1h1
3ijjijj3j3jj33j3jjij3jjj33rd6666d67rjji3j3rh1h1d1h1h1h1h1h1h1h1h1h13jjjjijjji3jij3rd6666d67hhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1h
3j3jj3j3ij3ji3ijjij3jj3j3j3dd6dd61hrjj3jjj31h1h1h1h1h1h1h1h1h1h1h1h3jjjjjjijijijjjrdd6dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h1
i3ii3ji3jijij3jijiiijjj3jjrddd1h1h133jjjj3rh1h1h1h1h1h1h1h1h1h1h1h133jjjjjjjjjjjj33ddd1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1h
iijji33iiiiiiiiiijiijijjjj3dh1h1h1d1333333h1h1h1h1h1h1h1h1h1h1h1h1h133333333333333hdh1h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h1
iiiiiiiiiiiiiiiiiiiiiiijjj361h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hjh1h3hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1h1h1h

__gff__
0000000000000000000000100000000000031000000000000000000800000000030000000000000000000020000000000000000000000300000000000000000003030303030000000000000000000000020200020204040404000000000000000101010202030200000001430000000001020000030203030300000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000002700000000000000000000000000000000535400000000000000000000000000000000000000000000000000000000007400000000000000000074000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000b000029000000000000000000000b000000000053540b000000000000555555000000270000001b00000000000000000000003b00000000000000000074000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000002900000000000000000000000000000000535400000000000000434144000000290000007000000000000000000000003b00000000000000000074000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660000000029000000000000000000764461620000767171780000000000005352540038183a1818181818181818183900000000003b00000000000b00000074000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075000b000029000000000000000000006600000000575757570000000000005352540b0000290000005500000055000000000000004378000000000000000074000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b000000002900000000000000000000660000000000000000270000000000535254000000290000566536363674580000000000006655555555550000000074000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b000000003700000000000000000000660000000000000000290000000000637164000000290000566600000000000000000000005377777777785800000074000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655800005665001b00000000000000006600000000000000002900000000005757570000002900005666000b0000000000000000007500000000000000000074000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777778007677777777777741665800005666616162000000000000606600000000000000002900000000000000000000002900005666002b0000000000000000006b00000000000000000074000000
5254000000000000005653525254580000000000000000006600000000000000000000000000000000000000000000000000000000000000000000005366580b00566600000000000000000000750000000000000000370000000000000000000000370000566377777778580000000000006b00000074000000000074000000
525400000000000b005653525254580000000000000000006600000000000000000000000000000000000000000000000b00000000000000000000005366580000566600000000000000000000000000000000000000000000000036363636363636000000000000000000000000000000006b00000074000000000074000000
52540000000000000056637171645800000000000000000066000000486700000000000000000000700000000000000000000000000000000b0000005366580000566655555555555555555555555555555555555555555555555555555555555555555555000000000000000000000000006500000074580000005674000000
__sfx__
010f00001e3421e3421e3421e34200300203002134221342203422034220342203423a300373001c3421c3421e3421e342183002134221342213001e3421e342053000530025342253422334221342203421c342
010f00001e3421e3421e3421e34203300203002134221342233422334223342233423a3003730021342203421c3421c342183001934219342213001e3421e3421e3421e3421e3421e3451e3421c3421e3421c342
310f000031345313052d3452d30531345313052d3452d30534345343052d3452d30531345313052d3452d305363451c30018300323451930021300313451e3001e3001e300313451e3002d3451c300393451c300
310f00003934532300323452d3053934531305323452d3053634534305323452d3053634531305323452d305343451c30018300343451930021300363451e300313451e300363451e300313451c3003634531345
010f0000252551e2552d25526255252551e2552d25526255252551c2552c25526255252551c25528255252552525525200152002a2552a200152002525525200252551e2552d25526255252551e2552c25528255
010f0000262551e2552f25523255262551e2552f25523255262551e2552f25523255262551e2552f255232552525525205152052125521205152052525525205252551e2552d25525255252551e2552d25525255
3f0f00000626006260062600626006260062600926109260012600126001260012600126001260042610426006260062650020006260062650020006260062650020000200062600626006260062600626004260
3f0f000002260022600226002260022600226109260092600b2600b2600b2600b2600b2600b261002600026001260012650000001260012650000006260062600626006260062600626006260062600626006260
010f00001e3421e3421e3421e34200300203002534225342263422634226342263423a3003730026342263422834228342183002634226342213002534225342053000530025342253422334221342203421c342
010f00001e3421e3421e3422134121342213422334123342233422334223342233452334221342203421e3421c3421c3421c3421934119342193421e3411e3421e3421e3421e3421e3422534223342203421c342
010f0000213402134021345213402134021345203402134121340213402134021340213402134021340213452034020340203451c3401c3401c3451e340203412034020340203402034020340203402034020345
010f00001e3401e3401e3452134021340213451e3401e34121340213402134521300253402334021340203402034020340203451c3401c3401c3452034020340203451c3401c3401c34523340233402034020340
790f00002a2502a2312a2112525025231252112a2502a2312a2112525025231252112a2502a231252502523128250282312821125250252312521128250282312821125250252312521128250282312525025231
790f00002625026231262112525025231252112625026231262112525025231252112625026231252502523128250282312821125250252312521128250282312821125250252312521128250282312525025231
010f0000122401224000200122401224000200142401524115240152401524015240172401724019240192401c2411c2401c24019240192401924017240172401724019240192401924017240152401424010240
010f00001224012240002001224012240002001424015241152401524015240152451524015240172401724019241192401c2001924019240192001c2411c240172001924019240192001c240172401224010240
310f00000625006250062500625006250062500625006250062500625006250062500625006250062500625004251042500425004250042500425004250042500425004250042500425004250042500425004250
310f00000225002250022500225002250022500225002250022500225002250022500225002250022500225004251042500425004250042500425004250042500425004250042500425004250042500425004250
010f00001e3401e3401e34521340213402134525340253412a3402a3402a3451e305313402f3402d3402c3452c3402c3402c3452834028340283452c3402c3412c3453434134340343452f3402c3402834023340
010f00001f3421f3421f3421f34201300213002234222342213422134221342213423b300383001d3421d3421f3421f342193002234222342223001f3421f342063000630026342263422434222342213421d342
010f00001f3421f3421f3421f34204300213002234222342243422434224342243423b3003830022342213421d3421d342193001a3421a342223001f3421f3421f3421f3421f3421f3451f3421d3421f3421d342
010f000032355323052e3552e30532355323052e3552e30535355353052e3552e30532355323052e3552e305373551d30019300333551a30022300323551f3001f3001f300323551f3002e3551d3003a3551d300
010f00003a35533300333552e3053a35532305333552e3053735535305333552e3053735532305333552e305353551d30019300353551a30022300373551f300323551f300373551f300323551d3003735532355
010f0000262551f2552e25527255262551f2552e25527255262551d2552d25527255262551d25529255262552625526200162002b2552b200162002625526200262551f2552e25527255262551f2552d25529255
010f0000272551f2553025524255272551f2553025524255272551f2553025524255272551f25530255242552625526205162052225522205162052625526205262551f2552e25526255262551f2552e25526255
2f0f00000726007260072600726007260072600a2610a260022600226002260022600226002260052610526007260072650120007260072650120007260072650120001200072600726007260072600726005260
2f0f00000326003260032600326003260032610a2600a2600c2600c2600c2600c2600c2600c261012600126002260022650100002260022650100007260072600726007260072600726007260072600726007260
010f00001f3421f3421f3421f34201300213002634226342273422734227342273423b3003830027342273422934229342193002734227342223002634226342063000630026342263422434222342213421d342
010f00001f3421f3421f3422234122342223422434124342243422434224342243452434222342213421f3421d3421d3421d3421e3411e3421e3421f3411f3421f3421f3421f3421f3422634224342213421d342
010f00001324013240112401324013240112401324014240142401324011240142401324011240132400000013240132401124013240132401124013240142401424013240112401424013240112401324000000
010f00000e2300e2300c2300e2300e2300c2300e2300f2300f2300e2300c2300f2300e2300c2300e230000000e2300e2300c2300e2300e2300c2300e2300f2300f2300e2300c2300f2300e2300c2300e23000000
010f00001334013340133401334013340133400e3400e3400e3400e3400e3400e340073400734007340073401334013340133401334013340133400e3400e3400e3400e3400e3400e34007340073400734007340
010f00001323013230112301323013230112301323014230142301323011230142301323011230132300000013230132301123013230132301123013230142301423013230112301423013230112301323000000
010f00001824018240162401824018240162401824019240192401824016240192401824016240182400500018240182401624018240182401624018240192401924018240162401924018240162401824005000
010f00000c3400c3400c3400c3400c3400c340073400734007340073400734007340003400034000340003400c3400c3400c3400c3400c3400c34007340073400734007340073400734000340003400034000340
010f00001224012240102401224012240102401224013240132401224010240132401224010240122400000012240122401024012240122401024012240132401324012240102401324012240102401224000000
010f00000d2300d2300b2300d2300d2300b2300d2300e2300e2300d2300b2300e2300d2300b2300d230000000d2300d2300b2300d2300d2300b2300d2300e2300e2300d2300b2300e2300d2300b2300d23000000
010f00001234012340123401234012340123400d3400d3400d3400d3400d3400d340063400634006340063401234012340123401234012340123400d3400d3400d3400d3400d3400d34006340063400634006340
010f000025340253402130021340213402130023341233422334223342233422334223342233422134221342233402534000000233400000021340000001e3401e3401e3421e3421e3421e3421e3421934219342
010f000020340203401e3001c3401c3401d3001e3411e3411e3421e3421e3421e3421e3421e3421c3421c34226341263420000025342253421e3001e3401e3401e3401e3421e3421e3421e3421e3421e3421e342
010f00001c2301c23000200192001c2301c2301a2301a2301a2301a2301a2301a2301a2301a2301a2301a23019230192300020016200192301923012230122301223012230122301223012230122301223012230
010f00001523015230002001620010230102301923019230192301923019230192301923019230192301923019230192300020019200192301923012230122301223012230122301223012230122301223012230
170f00000d2400d2400d2400d2400d2400d2400b2400b2400b2400b2400b2400b2400b2400b2400b2400b24006240062400624006240062400624006240062400624006240062400624006240062400624006240
170f0000092400924009240092400924009240092400924009240092400924009240092400924009240092400d2400d2400d2400d240112401124011240062400624006240062400624006240062400624006240
010f000021340213401b3001c3401c3401a3001e3411e3411e3421e3421e3421e3421e3421e3421e3421e3421a3401a3421e34021340213421e3401a3401a3421c3401c342203402334023342213402834023340
010f00001523015230002001620010230102301923019230192301923019230192301923019230192301923015230152300020019200152301523015230152301723117230172301723017230172301723017230
010f00000924009240092400924009240092400924009240092400924009240092400924009240092400924002240022400224002240022400224002240022400424004240042400424004240042400424004240
3f0f00000625006250062500625006250062500925109250022500225002250022500225002250042510425006250062550020006250062550020006250062550020000200062500625006250062500625004250
2f0f00000724007240072400724007240072400a2410a240032400324003240032400324003240052410524007240072450120007240072450120007240072450120001200072400724007240072400724005240
010f00001e3401c3401a3401a3401a3401a3401a3401a3401a3401a3401a3401a3401c3401c3401c3401c3401e3401e3401e3401e3401e3401e3401e3401e3401e3401e34019340193401e3401e3402034020340
010f00002134021340213402134021341213402334123340233402334023340233401e3401e3401e3401e34026341263402634026340263402634025340253402534025340253402534020340203401c3401d340
490f00000627006270062700627006270062700627006270062700627006270062700627006270062700627001271012700127001270012700127001270012700127001270012700127001270012700127001270
490f00000227002270022700227002270022700227002270022700227002270022700227002270022700227002271022700227002270022700227004271042700427004270042700427005271052700527005270
010f00001e2401e2201e2151524015220152151924019220192151524015220152151224012215152401521519240192201921514240142201421519240192201921514240142201421510240102151424014215
010f00001744017420174151244012420124151744017420174151244012420124150e4400e41512440124151a4401a4201a4151544015420154151c4401c4201c4151744017420174151d4401d4151944019415
010f00002134021340213402134021341213402334123340233402334023340233401e3401e3401e3401e34026341263402634026340263402634028340283402834028340283402834026340263402834029340
0115000010252102551c2521c2551c2521c2551c2521c255102521025513252132550020000200132521225210252102551c2521c2551c2521c2551c2521c2551025210255132521325500200002001525215255
0115000013252132551f2521f2551f2521f2551f2521f255132521325517252172550020000200102521325212252122551e2521e2551e2521e2551e2521e255122521225515252152551f2521f2521e2511e252
0115000004240042400424004240042400424004240042400424004240042400424007241072400b2410b2400c2410c2400c2400c2400c2400c24009241092400924009240092400924009240092400924009240
011500000c2400c2400c240072410724007240042410424004240042400424004240042400424004240042400e2410e2400e2400e2400e2400e24006241062400624006240062400624006240062400624006240
011500001c2561f246232461c2361f236232361c2261f226232261c2261f216232161c2161f216232161c2161c25621246182461c23621236182361c22621226182261c22621216182161c21621216182161c216
011500001c2561f246182461c2361f236182361c2261f226182261c2261f216182161c2161f216182161c2161a2561e246212461a2361e236212361a2261e226212261a2261e216212161a2161e216212161a216
010700003117036170361752410025120311312a1002b70021470214751e2501e2551e3731e37329700297002970029700287000b700057000070003700007000070100701007010070100701007010070100701
190100001d1211c1211c1511c1511c1511e151221512c151331513f1513f100001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
__music__
01 00020604
00 01030705
00 0802042f
00 09030705
00 00020604
00 01030705
00 0802042f
00 09030705
00 0a0c0e10
00 0b0d0f11
00 0a0c0e10
00 120d0f11
00 0a0c0e10
00 0b0d0f11
00 0a0c0e10
00 120d0f11
00 00420446
00 01440547
00 0802042f
00 09030507
00 13151719
00 1416181a
00 1b151730
00 1c16181a
00 1d1e1f44
00 20212244
00 1d1e1f44
00 23242544
00 1d1e1f44
00 23242544
00 26282a44
00 27292b44
00 26282a44
00 2c2d2e44
00 26282a44
00 27292b44
00 26282a44
00 2c2d2e44
00 31333544
00 32343644
00 31333544
00 32343644
00 31333544
00 32343644
00 31333544
02 37343644
01 383a3c47
02 393b3d47
00 4842446f
00 49434547
00 40424446
00 41434547
00 4842446f
00 49434547
00 71737544
00 72747644
00 71737544
00 72747644
00 71737544
00 72747644
00 71737544
02 77747644

