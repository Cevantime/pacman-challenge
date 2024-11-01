extends CanvasLayer

@onready var score_label_value: Label = %ScoreLabelValue
@onready var high_score_label_value: Label = %HighScoreLabelValue
@onready var lives_h_box_container: HBoxContainer = %LivesHBoxContainer

@export var pacman_texture_packed: PackedScene

func _ready() -> void:
	score_label_value.text = str(GlobalState.score)
	GlobalState.score_updated.connect(_on_score_updated)
	high_score_label_value.text = str(GlobalState.highest_score)
	setup_lives()
	GlobalState.lives_updated.connect(_on_lives_updated)
	
func _on_score_updated(score, _old):
	score_label_value.text = str(score)
	high_score_label_value.text = str(GlobalState.highest_score)

func setup_lives():
	for c in lives_h_box_container.get_children():
		c.queue_free()
	for i in GlobalState.lives:
		lives_h_box_container.add_child(pacman_texture_packed.instantiate())
		
func _on_lives_updated(_lives, _old):
	setup_lives()
