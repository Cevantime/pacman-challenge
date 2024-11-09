extends Node2D

const Gameplay = preload("res://gameplay.gd")

const SPEED = 75.75757525 * 2.11

var screen_width = ProjectSettings.get("display/window/size/viewport_width") / ProjectSettings.get("display/window/stretch/scale")
var screen_height = ProjectSettings.get("display/window/size/viewport_height") / ProjectSettings.get("display/window/stretch/scale")

var map_position:
	get:
		if context == null:
			return null
		return context.walls_layer.local_to_map(position)

var context: Gameplay
var move_tween: Tween

@onready var original_position = position
	
func map_to_local(p: Vector2i) -> Vector2:
	return context.walls_layer.map_to_local(p)
	
	
func local_to_map(p: Vector2) -> Vector2i:
	return context.walls_layer.local_to_map(p)
	
	
func move(m:MoveData):
	if move_tween != null and move_tween.is_running():
		return
	_before_move(m)
	move_tween = make_move(m.target_local)
	move_tween.finished.connect(finish_move)
	
func abort_move():
	if move_tween != null:
		move_tween.kill()

func finish_move():
	position.x = wrapf(position.x, 0.0, screen_width)
	position.y = wrapf(position.y, 0.0, screen_height)
	#position = map_to_local(local_to_map(position))
	_on_move_finished()
	
func make_move(target):
	var tween = create_tween()
	tween.tween_property(self, "position", target, 16.0 / get_speed())
	return tween
	
func check_move():
	var direction = _get_direction()
	var target_pos = map_position + direction
	var move_data = MoveData.new(map_position, target_pos, position + Vector2(direction) * Vector2(16, 16))
	
	if direction != Vector2i.ZERO and not _is_blocking(target_pos):
		move(move_data)
	else:
		_move_refused()

func get_speed():
	return SPEED * _get_speed_coef()
	
func _get_speed_coef():
	return 1.0

func _is_blocking(map_pos: Vector2i) -> bool:
	return false
	
	
func _on_move_finished() -> void:
	pass
	
	
func _move_refused() -> void:
	pass
	

func _get_direction() -> Vector2i:
	return Vector2i.ZERO
	
	
func _before_move(_move_data:MoveData) -> void:
	pass
