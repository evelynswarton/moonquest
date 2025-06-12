-- note that we have a
-- safe character range: [32, 127]
-- for this reason we use base 95=127-32
-- and do int->char via chr(32+n)
-- and char->int via ord(c)-32

-- enc95 : (int,int)->str
--     n : numer to encode
--     k : numer to bits to use
function enc95(n,k)
	r=''
	for i=1,k do
		r=chr(32+(n%95))..r
		n=flr(n/95)
	end
	return r
end

-- dec95 : str->int
--     s : string to decode
function dec95(s)
	n=0
	for i=1,#s do
		c=sub(s,-i,-i)
		b=ord(c)-32
		n+=b*(95^(i-1))
	end
end

function mtile_enc(x,y)
	-- x in [0,127]    ~ 7 bits
	-- y in [0,63]     ~ 6 bits
	-- snum in [0,127] ~ 7 bits
	-- 20 bits in total
	-- [_______,______,_______]
	--     ^      ^       ^
	--  x-bits  y-bits  spr-bits
	--  2^20 < 95^4 so i can use 4 safe chars
	snum=mget(x,y)
	r=(x<<13)+(y<<7)+snum
	return enc95(r,4)
end
