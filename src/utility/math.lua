-- Helper function to calculate the distance between two points
function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Define a function for linear interpolation
function lerp(a, b, t)
    return a + (b - a) * t
end