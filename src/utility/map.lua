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
	return 'map_dat = \"'..sub(s,0,-2)..'\"'
end

-- fn : init_map(dat)
-- decodes string to initialize map
function init_map(str)
	log('initializing map..')
	tiles=split(str)
	for t in all(tiles) do
		log('tile:'..t)
		t=split(t,'%')
		celx,cely,snum=t[1],t[2],t[3]
		log('celx:'..celx..',cely:'..cely..',snum:'..snum)
		mset(celx,cely,snum)
	end
end

function log(msg)
	add(logs,msg)
	printh(msg,'logging')
end

