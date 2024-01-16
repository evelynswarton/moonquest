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
