extends "res://phantom/phantom.gd"

func _get_chase_target():
	var pacman = context.get_pacman()
	var p1 = get_tree().get_first_node_in_group("blinky").map_position
	var p2 = pacman.map_position + 2 * pacman.direction
	var diff = p2 - p1
	return p1 + diff * 2


func _get_scatter_target():
	return context.zones_layer.get_used_cells_by_id(0, Vector2i(4, 0))[0]


func _on_global_counter_incremented(count, counter):
	if count == 17 and state == STATES.WAIT:
		state = STATES.GO_OUT
