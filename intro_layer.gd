extends CanvasLayer

@onready var high_score_value_label: Label = %HighScoreValueLabel
@onready var eat_audio_stream_player: AudioStreamPlayer = %EatAudioStreamPlayer
@onready var grid_container: GridContainer = %GridContainer

func _ready():
	start_sound()
	for c in grid_container.get_children().filter(func(c): return not c.visible):
		c.show()
		await get_tree().create_timer(0.2).timeout
	high_score_value_label.text = str(GlobalState.highest_score)

func start_sound():
	await get_tree().create_timer(0.5).timeout
	eat_audio_stream_player.play()
	
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		get_tree().change_scene_to_file("res://gameplay.tscn")
