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

function log(msg)
	printh(msg,'dat/log')
end

