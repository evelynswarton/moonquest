function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(num,maximum)
    return mid(-maximum,num,maximum)
end