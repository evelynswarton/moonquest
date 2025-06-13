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
	return n
end

-- x in [0,127]    ~ 7 bits
-- y in [0,63]     ~ 6 bits
-- spr in [0,127]  ~ 7 bits
-- i only have 16 bits

-- 11111110000000000000
TILE_MASK_X=(1<<7)-1
TILE_MASK_Y=((1<<6)-1)<<7
-- 00000001111110000000
--TILE_MASK_Y = ((1<<6)-1)<<7
-- 00000001111110000000
--TILE_MASK_SPR = ((1<<7)-1)

function mtile_enc(x,y)
	log('x'..x..'y'..y..'spr'..mget(x,y))
	pos_enc=enc95((y<<7)+x,2)
	spr_enc=enc95(mget(x,y),2)
	return pos_enc..spr_enc
end

function mtile_dec(s)
	pos=dec95(sub(s,1,2))
	x=pos&TILE_MASK_X
	y=(pos&TILE_MASK_Y)>>7
	spr=dec95(sub(s,3,4))
	log('x'..x..'y'..y..'spr'..spr)
	mset(x,y,spr)	
end
