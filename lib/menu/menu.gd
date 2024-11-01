extends CanvasLayer

@onready var high_score_panel_container: PanelContainer = %HighScorePanelContainer
@onready var close_high_score_button: Button = %CloseHighScoreButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
@onready var cancel_button: Button = %CancelButton

@export var reload_on_restart := false

signal restart_requested


func _ready():
	if OS.has_feature("web"):
		quit_button.hide()
		
func prevent_cancel():
	cancel_button.hide()
	
func allow_cancel():
	cancel_button.show()
	
	
func display() -> void:
	if not visible:
		show()
		restart_button.grab_focus()


func _on_leader_board_button_pressed() -> void:
	high_score_panel_container.show()
	close_high_score_button.grab_focus()


func _on_close_high_score_button_pressed() -> void:
	high_score_panel_container.hide()
	restart_button.grab_focus()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	restart_requested.emit()
	if reload_on_restart:
		get_tree().reload_current_scene()


func _on_cancel_button_pressed() -> void:
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
