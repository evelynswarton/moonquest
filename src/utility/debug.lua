debug_info = {}

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
        player.db.x1r,
        player.db.y1r,
        player.db.x2r,
        player.db.y2r,
        debug_color
    )
end