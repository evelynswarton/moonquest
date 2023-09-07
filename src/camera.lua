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
    cam.target_x = player.x - 64
    if player.flp then
        cam.target_x -= cam.look_ahead_distance
    else
        cam.target_x += cam.look_ahead_distance
    end
    cam.target_y = player.y - 64

    cam.x = (cam_speed * cam.x) + ((1 - cam_speed) * cam.target_x)
    cam.y = (cam_speed * cam.y) + ((1 - cam_speed) * cam.target_y)
    --do not go off of the map
    --left bound
    if cam.x < map_start then
        cam.x = map_start
    end
    --right bound
    if cam.x > map_end - 128 then
        cam.x = map_end-128	
    end
    --top bound
    if cam.y < map_top then
        cam.y = map_top
    end
    --bottom bound
    if cam.y > map_bottom - 128 then
        cam.y = map_bottom - 128
    end

    camera(cam.x, cam.y)
end