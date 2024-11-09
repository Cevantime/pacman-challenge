extends CanvasLayer

@onready var high_score_value_label: Label = %HighScoreValueLabel

func _ready():
	high_score_value_label.text = str(GlobalState.highest_score)
	
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		get_tree().change_scene_to_file("res://gameplay.tscn")
