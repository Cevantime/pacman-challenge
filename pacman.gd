extends Node2D

var moving = false

@onready var pivot: Node2D = %Pivot
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var move_input := Vector2i.ZERO
var direction := Vector2i(-1, 0)

signal move_done(destination)

func _process(delta):
	var m = Vector2i.ZERO
	m.x = round(Input.get_axis("move_left", "move_right"))
	m.y = round(Input.get_axis("move_up", "move_down"))
	if m != Vector2i.ZERO:
		move_input = m
		

func stop():
	animation_player.play("RESET")
	
	
func do_move(m:Vector2):
	moving = true
	var initial_pos = position
	var dir = Vector2(0, sign(m.y)) if m.y != 0 else m
	pivot.rotation = dir.angle()
	animation_player.play("eat")
	var tween = create_tween()
	tween.tween_property(self, "position", position + m, 0.12)
	await tween.finished
	moving = false
	move_done.emit(position)
	#move_input = Vector2i.ZERO
