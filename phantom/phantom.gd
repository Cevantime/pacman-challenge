extends "res://moving_character.gd"

signal was_eaten

var state:
	set(v):
		var old = state
		state = v
		_enter_state(state, old)
		state_changed.emit(state, old)
		

enum STATES {
	WAIT,
	GO_OUT,
	REPLACE,
	SCATTER,
	CHASE,
	GO_HOUSE,
	GO_IN
}

var frightened = false:
	set(v):
		if state == STATES.GO_HOUSE:
			v = false
		frightened = v
		if not is_node_ready():
			await ready
		sprite_body.modulate = Color.DARK_BLUE if frightened else original_modulate
		sprite_eyes.visible = !frightened
		sprite_frightened.visible = frightened
		turn_back = frightened
		blinking = !frightened
		
var direction = Vector2i(-1,0)
var turn_back = false

@export var nickname : String:
	set(v):
		if v != "":
			nickname = v
			if not SpeedChart.is_node_ready():
				await SpeedChart.ready
			dot_counter = Counter.new()
			dot_counter.limit = SpeedChart.get_value(nickname + "_dots_left", 0)
			dot_counter.limit_reached.connect(_on_dot_counter_limit_reached)

signal state_changed(new_state, old_state)

const DIRS = [Vector2i(0, -1), Vector2i(-1,0), Vector2i(0, 1), Vector2i(1, 0)]

@onready var sprite_eyes: Sprite2D = %SpriteEyes
@onready var wait_animation_player: AnimationPlayer = %WaitAnimationPlayer
@onready var rendering: Node2D = %Rendering
@onready var sprite_body: Sprite2D = %SpriteBody
@onready var sprite_frightened: Sprite2D = %SpriteFrightened
@onready var original_modulate = sprite_body.modulate

var dot_counter: Counter
var wait_position
var just_eaten = false
var sprite_debug_target
var blinking = false


@export var debug_target := false:
	set(v):
		debug_target = v


func _ready() -> void:
	call_deferred("set_up_initial_state")
	if debug_target:
		sprite_debug_target = Sprite2D.new()
		sprite_debug_target.texture = preload("res://asset/phantom/target-debug.png")
		get_tree().current_scene.add_child.call_deferred(sprite_debug_target)
		sprite_debug_target.modulate = original_modulate
		
	
	
func _process(delta: float) -> void:
	if frightened and context.frighten_timer.time_left < 2.5 and not blinking:
		start_blinking()
	if debug_target:
		sprite_debug_target.global_position = map_to_local(get_target())
	
func start_blinking():
	blinking = true
	var fr = false
	while frightened and blinking:
		sprite_body.modulate = Color.DARK_BLUE if fr else original_modulate
		sprite_eyes.visible = !fr
		sprite_frightened.visible = fr
		if get_tree() == null:
			return
		await get_tree().create_timer(0.3).timeout
		fr = !fr
	blinking = false
	
func set_up_initial_state():
	if context.walls_layer.get_cell_source_id(map_position) >= 0:
		wait_position = map_position
		state = STATES.WAIT
	elif int(position.x) % 16 == 0 or int(position.y) % 16 == 0:
		state = STATES.REPLACE
	else:
		state = context.current_state_phase
		if not context.is_node_ready():
			await context.ready
		check_move()

	
func _get_speed_coef():
	return get_base_speed() * _get_book_coef()
		
func get_base_speed():
	match state:
		STATES.CHASE: return 1.0
		STATES.SCATTER: return 1.0
		STATES.GO_OUT: return 0.7
		STATES.REPLACE: return 1.0
		STATES.GO_HOUSE: return 2.3
		STATES.GO_IN: return 2.0
		
func _get_book_coef():
	if context.zones_layer.get_cell_atlas_coords(map_position) == Vector2i.ZERO:
		return SpeedChart.get_value("ghost_tunnel_speed")
	else:
		if frightened:
			return SpeedChart.get_value("fright_ghost_speed")
		else:
			return SpeedChart.get_value("ghost_speed")

func _is_blocking(map_pos: Vector2i) -> bool:
	return context.walls_layer.get_cell_source_id(map_pos) >= 0
	
	
func _on_move_finished() -> void:
	if state == STATES.WAIT:
		return
	if state == STATES.GO_HOUSE and map_position == context.zones_layer.get_used_cells_by_id(0, Vector2i(7,0))[0]:
		state = STATES.GO_IN
		return
	check_move()
	
	

func get_target() -> Vector2i:
	match state:
		STATES.CHASE: return _get_chase_target()
		STATES.SCATTER: return _get_scatter_target()
		STATES.GO_HOUSE: return context.zones_layer.get_used_cells_by_id(0, Vector2i(7,0))[0]
	return Vector2i.ZERO


func _get_chase_target():
	return context.get_pacman().map_position


func _get_scatter_target():
	return context.zones_layer.get_used_cells_by_id(0, Vector2i(3, 0))[0]


func filter_dirs():
	var dirs_to_check = DIRS.filter(filter_dir)
	if dirs_to_check.is_empty():
		dirs_to_check = [-direction]
	return dirs_to_check
	
func _get_direction() -> Vector2i:
	if turn_back and direction != Vector2i.ZERO:
		direction = -direction
		turn_back = false
		return direction
	elif frightened:
		turn_back = false
		
		direction = filter_dirs().pick_random()
		return direction
		
	if map_position in context.zones_layer.get_used_cells_by_id(0, Vector2i(1,0)) and state in [STATES.CHASE, STATES.SCATTER] and not _is_blocking(map_position + direction):
		return direction
		
	direction = get_dir_to(get_target())
	
	just_eaten = false
	
	return direction
	
func get_dir_to(target):
	var dirs_to_check = filter_dirs()
		
	var direction = dirs_to_check[0]
	
	if dirs_to_check.size() > 1:
		var distance = (map_position + direction).distance_squared_to(target)
		for i in range(1, dirs_to_check.size()):
			var dir = dirs_to_check[i]
			var dist = (map_position + dir).distance_squared_to(target)
			if dist < distance:
				distance = dist
				direction = dir
				
	return direction
	
	
func filter_dir(dir: Vector2i):
	var condition = not _is_blocking(map_position + dir)
	
	if just_eaten:
		return condition
		
	return condition and dir != -direction
	
	
func _before_move(move_data:MoveData) -> void:
	var dir = move_data.target_map - move_data.from_map
	adapt_eyes(dir)


func adapt_eyes(dir):
	for i in DIRS.size():
		if DIRS[i] == dir:
			sprite_eyes.frame = i


func go_out():
	wait_animation_player.stop()
	move_tween = create_tween()
	await move_tween.tween_property(rendering, "position",Vector2.ZERO, 16.0/get_speed()).finished
	var path = context.aStarGridGoOut.get_point_path(map_position, context.zones_layer.get_used_cells_by_id(0, Vector2i(7,0))[0])
	
	if state == STATES.WAIT:
		position = original_position
		return
	elif state > STATES.GO_OUT:
		check_move()
		return
		
	for i in range(1, path.size()):
		var p = path[i]
		adapt_eyes(Vector2i((p - position).normalized()))
		var t = make_move(p)
		await t.finished
		if state == STATES.WAIT:
			position = original_position
			return
		elif state > STATES.GO_OUT:
			check_move()
			return
	
	if state == STATES.WAIT:
		position = original_position
		return
	elif state > STATES.GO_OUT:
		check_move()
		return
	state = STATES.REPLACE
	
	
	
func replace():
	var dir = get_dir_to(get_target())
	await make_move(position + dir * 8.0).finished
	if state != STATES.REPLACE:
		return
	state = context.current_state_phase
	check_move()

func _reset():
	direction = Vector2i(-1,0)
	turn_back = false
	just_eaten = false
	blinking = false
	position = original_position
	set_up_initial_state()
	show()

func start_waiting():
	wait_animation_player.play("wait")


func _enter_state(new_state, previous_state):
	var turn_back_states = [STATES.SCATTER, STATES.CHASE]
	if new_state in turn_back_states and previous_state in turn_back_states:
		turn_back = true
	
	match new_state:
		STATES.WAIT: start_waiting()
		STATES.GO_OUT: go_out()
		STATES.REPLACE: replace()
		STATES.GO_IN: go_in()


func get_frightened():
	frightened = true
	
	
func leave_frighten():
	frightened = false

	
func change_phase(new_state):
	if state == STATES.CHASE or state == STATES.SCATTER:
		state = new_state

	
func eaten():
	if state in [STATES.REPLACE, STATES.GO_OUT]:
		check_move()
	frightened = false
	just_eaten = true
	state = STATES.GO_HOUSE
	sprite_body.modulate = original_modulate
	sprite_eyes.show()
	sprite_frightened.hide()
	sprite_body.hide()
	was_eaten.emit()

func go_in():
	var path = context.aStarGridGoOut.get_point_path(map_position, get_wait_position())
	
	for i in range(1, path.size()):
		var p = path[i]
		adapt_eyes(Vector2i((p - position).normalized()))
		await make_move(p).finished
		if state != STATES.GO_IN:
			if state == STATES.WAIT:
				position = original_position
				return
			elif state > STATES.GO_OUT:
				check_move()
				return
		
	await make_move(position - Vector2(0, 8)).finished
	
	sprite_body.show()
	
	state = STATES.GO_OUT


func get_wait_position():
	return wait_position if wait_position != null else local_to_map(context.default_wait_pos.position)


func _dot_eaten(total):
	if dot_counter.active:
		dot_counter.increment()
		
		
func _on_dot_counter_limit_reached():
	if state == STATES.WAIT:
		state = STATES.GO_OUT


func _on_global_counter_incremented(count, counter):
	pass
