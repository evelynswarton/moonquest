function collides_with_block(obj, dir)
    for block in all(interactive_blocks) do
    end
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
        player.db.x1r=x1
        player.db.y1r=y1
        player.db.x2r=x2
        player.db.y2r=y2
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
    local x2 = (obj.x + obj.w + 5) / 8
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
