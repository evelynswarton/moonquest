debug_info = {}

function debug_update()
    debug_info[1] = ' ram:'..stat(0)
    debug_info[2] = 'cput:'..stat(1)
    debug_info[3] = 'cpus:'..stat(2)
end

function debug_draw()
    for i, message in ipairs(debug_info) do
        print(message, cam.x, cam.y + (i - 1) * 6, debug_color)
    end
    --print('dx = '..tostr(player.dx), cam.x, cam.y + 4 * 6, debug_color)
    --print('dy = '..tostr(player.dy), cam.x, cam.y + 5 * 6, debug_color)
    --print('flt = '..tostr(player.float_meter), cam.x, cam.y + 9 * 6, debug_color)
end

