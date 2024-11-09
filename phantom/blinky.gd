extends "res://phantom/phantom.gd"

var elroy_mode = ELROY_MODES.NORMAL

var pokey_is_out = false

enum ELROY_MODES {
	NORMAL, ACCELERATED, SUPER_ACCELERATED
}

func _ready() -> void:
	super._ready()
	(func():
		var pokey = get_tree().get_first_node_in_group("pokey")
		pokey.state_changed.connect(_on_pokey_changed_state)).call_deferred()


func _get_chase_target():
	return context.get_pacman().map_position

func _get_book_coef():
	if context.zones_layer.get_cell_atlas_coords(map_position) == Vector2i.ZERO:
		return SpeedChart.get_value("ghost_tunnel_speed")
	else:
		if frightened:
			return SpeedChart.get_value("fright_ghost_speed")
		else:
			match elroy_mode:
				ELROY_MODES.NORMAL: return SpeedChart.get_value("ghost_speed")
				ELROY_MODES.ACCELERATED: return SpeedChart.get_value("elroy_1_speed")
				ELROY_MODES.SUPER_ACCELERATED: return SpeedChart.get_value("elroy_2_speed")
			
	
		
func _get_scatter_target():
	if elroy_mode != ELROY_MODES.NORMAL:
		return _get_chase_target()
	return context.zones_layer.get_used_cells_by_id(0, Vector2i(3, 0))[0]


func _on_pokey_changed_state(new, old):
	if old == STATES.GO_OUT:
		pokey_is_out = true
		check_elroy()
		
func check_elroy():
	var remaining = context.get_remaining_dots_count()
	if remaining <= SpeedChart.get_value("elroy_1_dots_left"):
		elroy_mode = ELROY_MODES.SUPER_ACCELERATED if remaining <= SpeedChart.get_value("elroy_2_dots_left") else ELROY_MODES.ACCELERATED

func _dot_eaten(total):
	if not pokey_is_out:
		return
	check_elroy()
