pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
#include graphics/ui.lua

function _init()
    text = 'boiaj oi jeopj iawpe ofij wpa eoifj oijew wo ei jfa oiej'
    lines = split_text(text, 50)
end

function _draw()
    cls(0)
    print(tostr(#lines)..lines[1], 0, 0)
    for i, line in ipairs(lines) do 
        print(line, 2, 2 + (i - 1) * 10)
    end
end

function _update()
end
