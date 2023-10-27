function collision(obj)

    -- if falling collide with ground
    if obj.dy > 0 then
        obj.dy = clamp(obj.dy, obj.max_dy)
        if collides_with_map(obj, 'down', 0) and not collides_with_map(obj, 'right', 6) then
            obj.dy = 0
            obj.y -= ((obj.y + obj.h + 1) % 8) - 1
        end

    -- if rising collide with roofs
    elseif obj.dy < 0 then
        if collides_with_map(obj, 'up', 1) and not collides_with_map(obj, 'up', 6) then
            obj.dy = 0
        end
    end

    -- left collide
    if obj.dx < 0 then
        if collides_with_map(obj, 'left', 1) and not collides_with_map(obj, 'left', 6) then
            obj.dx = 0
            while flr(obj.x) % 8 != 0 do
                obj.x += 1
            end
        end
    -- right collide
    elseif obj.dx > 0 then
        if collides_with_map(obj, 'right', 1) and not collides_with_map(obj, 'right', 6) then
            obj.dx = 0
            while flr(obj.x) % 8 != 0 do
                obj.x -= 1
            end
        end
    end
end

function move(obj)
    if obj.dy == 0 then
        obj.dx *= (1 - floor_friction)
    end

    obj.dy += gravity


    -- max speeds
    obj.dx = clamp(obj.dx, obj.max_dx)
    obj.dy = clamp(obj.dy, obj.max_dy)

    -- position is deriv velocity
    obj.x += obj.dx
    obj.y += obj.dy

    -- map bounds
    if obj.x < map_start then
        obj.x = map_start
    elseif obj.x > map_end - obj.w then
        obj.x = map_end - obj.w
    end
    
end
