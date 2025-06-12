function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(num, maximum)
    return mid(-maximum, num, maximum)
end

function center(x1, y1, x2, y2)
    return (x2 - x1) / 2, (y2 - y1) / 2
end

hex_chars = split('0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f',',')
function hex(n,digits)
	digits=digits or 2
	s=''
	while (n>0) do
		s=s..hex_chars[(n%16)+1]
		n=flr(n/16)
	end
	while (#s<digits) do
		s='0'..s
	end
	return s
end
