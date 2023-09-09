function draw_moon_counter(number)
    sspr(8, 16, 24, 8, cam.x + 128 - 17 - 8, cam.y + 1)
    print(tostr(number), cam.x + 128 - 7 - 8, cam.y + 2, 7)
end

function draw_death_counter(number)
    sspr(32, 16, 24, 8, cam.x + 128 - 17 - 8, cam.y + 10)
    print(tostr(number), cam.x + 128 - 6 - 8, cam.y + 11, 7)
end

function draw_rounded_rectangle(x, y, width, height, radius, color)
    rectfill(x + radius, y, x + width - radius - 1, y + height - 1, color)
    rectfill(x, y + radius, x + width - 1, y + height - radius, color)
    circfill(x + radius, y + radius, radius, color)
    circfill(x + width - radius - 1, y + radius, radius, color)
    circfill(x + radius, y + height - radius - 1, radius, color)
    circfill(x + width - radius - 1, y + height - radius - 1, radius, color)
end

function draw_rounded_textbox(x_tile, y_tile, text)
    local max_width = 100
    local radius = 2
    local padding = 2
    local text_color = 7 -- Change this to your desired text color
    local background_color = 13 -- Change this to your desired background color

    -- Calculate the width of the text box based on the text length and the maximum width
    local text_width = min(max_width, #text * 4 + 2 * padding)
    local width = text_width + 2 * radius

    -- Split the text into lines based on the width
    local lines = split_text(text, text_width)

    -- Calculate the height based on the number of lines
    local line_height = 8
    local height = (#lines * line_height) + (2 * padding)

    -- Calculate the position to center the textbox above the tile
    local x = x_tile * 8 + 4 - width / 2
    local y = y_tile * 8 - height - 8

    -- Keeping text box on screen
    x = max(x, cam.x + 2)
    y = max(y, cam.y + 2)
    while x + width > cam.x + 128 do
        x -= 1
    end
    while y + height > cam.y + 128 do 
        y -= 1
    end

    -- Draw box
    draw_rounded_rectangle(x, y, width, height, radius, background_color)
    -- Draw each line of text
    for i, line in ipairs(lines) do
        print(line, x + padding, y + padding + (i - 1) * line_height, text_color)
    end
end

function split_text(text, max_width_pixels)
    local result = {}
    local start = 1
    local length = #text
    local line_width = 0
    local char_width = 4
    while start <= length do
        local end_pos = start
        line_width = 0
        while end_pos <= length do
            local char = sub(text, end_pos, end_pos)
            if char == '\n' then
                local line = sub(text, start, end_pos - 1)
                add(result, line)
                start = end_pos + 1
                break
            else
                line_width = line_width + char_width

                if line_width <= max_width_pixels then
                    end_pos = end_pos + 1
                else
                    local line = sub(text, start, end_pos - 1)
                    add(result, line)
                    start = end_pos
                    break
                end
            end
        end
        if end_pos > length then
            local line = sub(text, start, length)
            add(result, line)
            break
        end
    end
    return result
end

function draw_float_meter()
    if player.floating then
        rectfill(player.x - 1, player.y - 9,
        player.x + player.float_meter - 2, player.y - 9,
        8)
        rect(player.x-2,player.y-10,
        player.x+8,player.y-8, 2)
    end
end