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
