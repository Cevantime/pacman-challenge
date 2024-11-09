extends Sprite2D

@onready var delete_timer: Timer = %DeleteTimer

var delete_time
var points

func _ready() -> void:
	delete_timer.wait_time = delete_time
	delete_timer.start()

func _on_delete_timer_timeout() -> void:
	queue_free()
