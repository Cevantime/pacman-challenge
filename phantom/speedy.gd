extends "res://phantom/phantom.gd"




func _get_chase_target():
	var pacman = context.get_pacman()
	return pacman.map_position + pacman.direction * 4 


func _get_scatter_target():
	return context.zones_layer.get_used_cells_by_id(0, Vector2i(2, 0))[0]

func _on_global_counter_incremented(count, counter):
	if count == 7 and state == STATES.WAIT:
		state = STATES.GO_OUT
