function collides_with_block(obj, dir)
    for block in all(interactive_blocks) do
    end
end
--[[
function collides_with_map(_obj, _dir, _flag)
    local x1, x2, y1, y2, dx, dy = _obj.x + _obj.hb.x1, _obj.x + _obj.hb.x2, _obj.y + _obj.hb.y1, _obj.y + _obj.hb.y2, _obj.dx, _obj.dy
    if _dir == 'left' then
        return fget(mget((x1 + dx) / 8, (y1 + dy) / 8), _flag) or
        fget(mget((x1 + dx) / 8, (y2 + dy) / 8), _flag)
    elseif _dir == 'right' then
        return fget(mget((x2 + dx) / 8, (y1 + dy) / 8), _flag) or
        fget(mget((x2 + dx) / 8, (y2 + dy) / 8), _flag)
    elseif _dir == 'up' then
        return fget(mget((x1 + dx) / 8, (y1 + dy) / 8), _flag) or
        fget(mget((x2 + dx) / 8, (y1 + dy) / 8), _flag)
    else
        return fget(mget((x1 + dx) / 8, (y2 + dy) / 8), _flag) or
        fget(mget((x2 + dx) / 8, (y2 + dy) / 8), _flag)
    end
end]]

function collides_with_map2(obj, dir, flag)
    local x = obj.x
    local y = obj.y
    local dx = obj.dx
    local dy = obj.dy
    local w = obj.w
    local h = obj.h

    -- Collision box
    local x1, x2, y1, y2

    -- Placing collision box without offsets
    if dir == "left" then
        x1, x2, y1, y2 = x, x, y + dy, y + dy - h
    elseif dir == "right" then
        x1, x2, y1, y2 = x + w, x + w, y + dy, y + dy - h
    elseif dir == "up" then
        x1, x2, y1, y2 = x, x + w, y + dy, y + dy
    elseif dir == "down" then
        x1, x2, y1, y2 = x + dx, x + w + dx, y + h, y + h
    end

    -- Debug
    if debug_on then
        player.db.x1, player.db.y1, player.db.x2, player.db.y2 = x1, y1, x2, y2
    end

    -- Pixels to tiles
    x1, x2, y1, y2 = x1 / 8, x2 / 8, y1 / 8, y2 / 8

    -- Check collide and calculate distance (finally)
    local distance = 0
    if fget(mget(x1, y1), flag) or
       fget(mget(x1, y2), flag) or
       fget(mget(x2, y1), flag) or
       fget(mget(x2, y2), flag) then
        distance = (flr(x2) * 8) - (x + w)  -- Calculate distance to collision
        obj.dx = distance
    end
    return distance > 0  -- Return true if there was a collision
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
