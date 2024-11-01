extends "res://lib/spawners/basic_spawner.gd"

@onready var timer: Timer = %Timer

@export var initial_spawn = true

@export var wait_time := 1.0: 
	set(v):
		if not is_node_ready():
			await ready
		timer.wait_time = v
		wait_time = v

func start():
	if initial_spawn : spawn()
	timer.start()
	
func stop():
	timer.stop()

func _on_timer_timeout() -> void:
	spawn()

func is_stopped():
	return timer.is_stopped()
