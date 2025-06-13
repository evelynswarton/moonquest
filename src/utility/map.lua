TILE_MASK_X=(1<<7)-1
TILE_MASK_Y=((1<<6)-1)<<7

-- encode map tile to len 4 str
function mtile_enc(x,y)
	--log('x'..x..'y'..y..'spr'..mget(x,y))
	spr_enc=enc95(mget(x,y),2)
	return xy_pair_enc(x,y)..spr_enc
end

-- decode a len 4 str and place map tile
function mtile_dec(s)
	--[[
	pos=dec95(sub(s,1,2))
	x=pos&TILE_MASK_X
	y=(pos&TILE_MASK_Y)>>7
	]]
	x,y=xy_pair_dec(sub(s,1,2))
	spr=dec95(sub(s,3,4))
	--log('x'..x..'y'..y..'spr'..spr)
	mset(x,y,spr)	
end

-- encode_map() : -> str
-- returns base95 encoding
-- of all map tiles
function serialize_map()
	s=''
	for tx=0,127 do
		for ty=0,63 do
			if mget(tx,ty) ~= 0 then 
				s=s..mtile_enc(tx,ty)
			end
		end
	end
	return 'map_dat = [=['..s..']=]'
end

-- fn : init_map(dat)
-- decodes string to initialize map
function init_map(str)
	log('initializing map..')
	offst=0
	tlstr=sub(str,1,4)
	while (#tlstr==4) do
		tlstr=sub(str,1+offst,4+offst)
		mtile_dec(tlstr)
		offst+=4
	end
end

