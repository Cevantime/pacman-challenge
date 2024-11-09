extends "res://moving_character.gd"

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D

var direction := Vector2i(-1, 0)
var move_input := Vector2i.ZERO
var stopped = false
var dead = false
var is_in_dots = false

const Phantom = preload("res://phantom/phantom.gd")

signal dot_eaten(big: bool)
signal bonus_eaten(bonus)

func _ready() -> void:
	sprite_2d.rotation = PI
	animation_player.play("eat")
	
	var t = create_tween().tween_property(self, "position", position + Vector2(-8,0), 8.0/get_speed())
	await t.finished
	stopped = true
	check_eat_dot(map_position)

func _process(_delta):
	var m = Vector2i.ZERO
	m.x = round(Input.get_axis("move_left", "move_right"))
	m.y = round(Input.get_axis("move_up", "move_down"))
	if m.x != 0:
		move_input = Vector2(m.x, 0)
	elif m.y != 0:
		move_input = Vector2(0, m.y)
	
	for ph in get_tree().get_nodes_in_group("phantom"):
		if position.distance_to(ph.position) < 10.0:
			if ph.frightened:
				ph.eaten()
				get_tree().paused = true
				await get_tree().create_timer(0.4).timeout
				get_tree().paused = false
				
			elif ph.state != Phantom.STATES.GO_HOUSE and not dead:
				context.pacman_eaten()
				
	var bonus = get_tree().get_first_node_in_group("bonus")
	
	if is_instance_valid(bonus) and position.distance_to(bonus.position) < 10.0:
		bonus_eaten.emit(bonus)
		bonus.queue_free()
		
	
	if stopped:
		check_move()
	
	
func die():
	if dead:
		return
	dead = true
	animation_player.play("die")
	var anim_name = await animation_player.animation_finished
	
	queue_free()
	
func _get_speed_coef():
	if is_in_dots:
		if context.frighten_timer.is_stopped():
			return SpeedChart.get_value("pacman_dots_speed")
		else:
			return SpeedChart.get_value("fright_pacman_dots_speed")
	else:
		if context.frighten_timer.is_stopped():
			return SpeedChart.get_value("pacman_speed")
		else:
			return SpeedChart.get_value("fright_pacman_speed")
	
	
func _is_blocking(map_pos: Vector2i) -> bool:
	return context.walls_layer.get_cell_source_id(map_pos) >= 0
		
		
func _on_move_finished():
	check_move()
	
	
func _move_refused():
	if dead:
		return
	animation_player.play("RESET")
	stopped = true
	
	
func _get_direction():
	if dead:
		return Vector2i.ZERO
	if move_input != Vector2i.ZERO and not _is_blocking(map_position + move_input):
		direction = move_input
	return direction
	
	
func _before_move(move_data:MoveData):
	stopped = false
	var m = move_data.target_map - move_data.from_map
	var dir = Vector2(0, sign(m.y)) if m.y != 0 else Vector2(m)
	sprite_2d.rotation = dir.angle()
	animation_player.play("eat")
	
	check_eat_dot(move_data.target_map)


func check_eat_dot(position):
	if context.objects_layer.get_cell_source_id(position) == 1:
		is_in_dots = true
		var big_dot = false
		if context.objects_layer.get_cell_atlas_coords(position) == Vector2i(1,0):
			context.trigger_frighten()
			big_dot = true
		context.objects_layer.set_cell(position, -1)
		dot_eaten.emit(big_dot)
	else:
		is_in_dots = false

func wait():
	animation_player.play("wait")
