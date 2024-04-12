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
    print('flt = '..tostr(player.float_meter), cam.x, cam.y + 9 * 6, debug_color)
end

