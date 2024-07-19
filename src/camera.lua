function cam_init(spawn_x, spawn_y)
 cam={
  x=spawn_x,
  y=spawn_y,
  target_x=0,
  target_y=0,
  look_ahead_distance=20,
  look_up_distance=35
 }
end

function cam_update()
 cam.target_x=player.x-64
 cam.target_y=player.y-64
 if player.flp then
  cam.target_x-=cam.look_ahead_distance
 else
  cam.target_x+=cam.look_ahead_distance
 end
 if btn(2) then
  cam.target_y-=cam.look_up_distance
 elseif btn(3) then
  cam.target_y+=cam.look_up_distance
 end
 cam.x=lerp(cam.x,cam.target_x,0.06)
 cam.y=lerp(cam.y,cam.target_y,0.06)
 if cam.x < map_start then
  cam.x=map_start
 end
 if cam.x > map_end - 128 then
  cam.x=map_end-128	
 end
 if cam.y < map_top then
  cam.y=map_top
 end
 if cam.y > map_bottom - 128 then
  cam.y=map_bottom - 128
 end
 camera(cam.x,cam.y)
end
