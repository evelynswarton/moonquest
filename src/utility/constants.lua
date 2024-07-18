-- constants for player spawn location
default_spawn_x = 3 * 8
default_spawn_y = 35 * 8

pause_controls_duration = 0.75

-- physics constants
gravity = 0.18 or 0.19
floor_friction = 0.11
max_wall_slide_speed = 0.8

-- map limit constants
map_start = 0
map_end = 1024
map_top = 0
map_bottom = 64 * 8

-- player constants
float_depletion_rate = 0.1
acceleration = 0.15

-- camera constants
cam_speed = .925

-- debugging constant
debug_on = false
debug_color = 12

-- flag constants
save_flag = 3
moon_flag = 4
block_flag = 5
umb_spawn_x = 45 * 8
umb_spawn_y = 35 * 8

if true then
	default_spawn_x = 76 * 8 or 2 * 8
	default_spawn_y = 13 * 8 or 35 * 8
	umb_spawn_x = default_spawn_x
	umb_spawn_y = default_spawn_y
end
