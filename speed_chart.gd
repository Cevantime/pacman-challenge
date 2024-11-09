extends Node

var data = []

func _ready() -> void:
	var f = FileAccess.open("res://asset/speeds.txt",FileAccess.READ)
	while f.get_position() < f.get_length():
		# Read data

		var strs: PackedStringArray = f.get_csv_line(",")
		
		var dict = {
			"bonus": strs[1].to_lower(),
			"bonus_point": strs[2].to_int(),
			"pacman_speed": strs[3].to_float(),
			"pacman_dots_speed": strs[4].to_float(),
			"ghost_speed": strs[5].to_float(),
			"ghost_tunnel_speed": strs[6].to_float(),
			"elroy_1_dots_left": strs[7].to_int(),
			"elroy_1_speed" : strs[8].to_float(),
			"elroy_2_dots_left": strs[9].to_int(),
			"elroy_2_speed" : strs[10].to_float(),
			"fright_pacman_speed" : strs[11].to_float(),
			"fright_pacman_dots_speed" : strs[12].to_float(),
			"fright_ghost_speed": strs[13].to_float(),
			"fright_time": strs[14].to_int(),
			"flash": strs[15].to_int(),
			"bashful_dots_left": strs[16].to_int(),
			"pokey_dots_left": strs[17].to_int(),
			"phases_timing": str_to_var(strs[18])
		}
		
		data.push_back(dict)

func get_value(key, default = null, l = null):
	var level = min(GlobalState.level if l == null else l, 20)
	return data[level][key] if data[level].has(key) else default
