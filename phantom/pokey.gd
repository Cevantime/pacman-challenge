extends "res://phantom/phantom.gd"



func _get_chase_target():
	if Vector2iUtil.manhattan_distance(map_position, context.get_pacman().map_position) <= 8:
		return _get_scatter_target()
	return context.get_pacman().map_position


func _get_scatter_target():
	return context.zones_layer.get_used_cells_by_id(0, Vector2i(5, 0))[0]

func _on_global_counter_incremented(count, counter):
	if count == 32 and state == STATES.WAIT:
		counter.deactivate()
		context.activate_next_personal_counter()
