extends Node2D

const Phantom = preload("res://phantom/phantom.gd")

@onready var walls_layer: TileMapLayer = %WallsLayer
@onready var objects_layer: TileMapLayer = %ObjectsLayer
@onready var zones_layer: TileMapLayer = %ZonesLayer
@onready var phase_timer: Timer = %PhaseTimer
@onready var frighten_timer: Timer = %FrightenTimer
@onready var default_wait_pos: Marker2D = %DefaultWaitPos
@onready var menu: CanvasLayer = %Menu
@onready var pacman_spawner: Marker2D = %PacmanSpawner
@onready var gameover_layer: CanvasLayer = %GameoverLayer
@onready var bonus_spawner: Marker2D = %BonusSpawner
@onready var ready_label: Label = %ReadyLabel
@onready var intro_audio_stream_player: AudioStreamPlayer = %IntroAudioStreamPlayer
@onready var dot_audio_stream_player: AudioStreamPlayer = %DotAudioStreamPlayer
@onready var big_dot_audio_stream_player: AudioStreamPlayer = %BigDotAudioStreamPlayer
@onready var bonus_audio_stream_player: AudioStreamPlayer = %BonusAudioStreamPlayer
@onready var eat_phantom_audio_stream_player: AudioStreamPlayer = %EatPhantomAudioStreamPlayer
@onready var alarm_audio_stream_player: AudioStreamPlayer = %AlarmAudioStreamPlayer
@onready var pacman_death_audio_stream_player: AudioStreamPlayer = %PacmanDeathAudioStreamPlayer
@onready var invincible_audio_stream_player: AudioStreamPlayer = %InvincibleAudioStreamPlayer

@export var pacman_invicible := false

const pop_label_scene = preload("res://popping_label.tscn")
const point_phantom = 200

var phase_timer_time_left
var aStarGridGoOut = AStarGrid2D.new()
var phases_timing = [7, 20, 7, 20, 5, 20, 5, 100]
var phase_index = 0

var current_state_phase = Phantom.STATES.CHASE

var original_dot_count
var global_dot_counter := Counter.new()
var bonus_dot_counter := Counter.new()
var time_last_eat_counter := Counter.new()
var all_four = 0
var point_phantom_acc = 0

func _ready() -> void:
	bonus_dot_counter.limit = 10000
	global_dot_counter.limit = 10000
	bonus_dot_counter.activate()
	time_last_eat_counter.activate()
	time_last_eat_counter.limit = 4 if GlobalState.level <= 4 else 3
	time_last_eat_counter.limit_reached.connect(_on_time_last_eat_counter_limit_reached)
	bonus_dot_counter.incremented.connect(_on_bonus_dot_counter_incremented)
	get_tree().paused = false
	frighten_timer.wait_time = SpeedChart.get_value("fright_time")
	original_dot_count = objects_layer.get_used_cells_by_id(1).size()
	
	set_up_phase()
	
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.context = self
	
	aStarGridGoOut.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	aStarGridGoOut.region = walls_layer.get_used_rect()
	aStarGridGoOut.offset = Vector2(0, 8)
	aStarGridGoOut.cell_size = Vector2(16.0, 16.0)
	aStarGridGoOut.update()
	aStarGridGoOut.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	for c in zones_layer.get_used_cells_by_id(0, Vector2i(6,0)):
		aStarGridGoOut.set_point_weight_scale(c, 0.5)
		
	for sp in get_tree().get_nodes_in_group("character_spawner"):
		sp.spawned.connect(_on_character_spawned.bind(sp))
		
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.state_changed.connect(_on_phantom_state_changed.bind(ph))
		ph.was_eaten.connect(_on_moving_eaten)
		
	pacman_spawner.spawn()
	
	activate_next_personal_counter.call_deferred()
	
	#global_dot_counter.deactivate()
	global_dot_counter.incremented.connect(_on_global_dot_counter_incremented)
	#menu.display()
	introduction()


func introduction():
	
	ready_label.show()
	get_tree().paused = true
	get_pacman().wait()
	if GlobalState.first_intro:
		GlobalState.first_intro = false
		intro_audio_stream_player.play()
		await intro_audio_stream_player.finished
	else:
		await get_tree().create_timer(2.0).timeout
	
	get_tree().paused = false
	ready_label.hide()
	
func activate_next_personal_counter():
	if global_dot_counter.active:
		return 
		
	var next_ghost = get_next_preferred_ghost()
	if next_ghost == null:
		return
	next_ghost.dot_counter.activate()
	
func get_next_preferred_ghost():
	var priorities = ["speedy", "bashful", "pokey"]
	var phantoms = get_tree().get_nodes_in_group("phantom").filter(func(ph): return ph.state == Phantom.STATES.WAIT)
	for p in priorities:
		for ph in phantoms:
			if p == ph.nickname:
				return ph
	return null
	
func _on_phantom_state_changed(new, old, phantom):
	if old == Phantom.STATES.WAIT:
		phantom.dot_counter.deactivate()
		activate_next_personal_counter()
	
func _on_character_spawned(spawned: Node, spawner):
	spawned.context= self
	get_tree().current_scene.add_child(spawned)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		menu.display()
	
	
func _on_dot_eaten(big):
	var dot_ratio = float(original_dot_count - get_remaining_dots_count()) / float(original_dot_count)
	alarm_audio_stream_player.pitch_scale = 1.0 + round(dot_ratio * 4.0) / 4.0
	if big:
		big_dot_audio_stream_player.play()
	else:
		dot_audio_stream_player.play()
	bonus_dot_counter.increment()
	time_last_eat_counter.reset()
	var remaining = get_remaining_dots_count()
	
	GlobalState.score += 50 if big else 10
	
	if global_dot_counter.active:
		global_dot_counter.increment()
	
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph._dot_eaten(original_dot_count - remaining)
	
	if remaining == 0:
		level_ended()

func set_up_phase():
	if phase_index >= phases_timing.size():
		return
	phase_timer.wait_time = phases_timing[phase_index]
	phase_timer.start()
	current_state_phase = Phantom.STATES.SCATTER if current_state_phase == Phantom.STATES.CHASE else Phantom.STATES.CHASE 
	phase_index += 1
		
		
		
func get_pacman():
	return get_tree().get_first_node_in_group("pacman")


func level_ended():
	GlobalState.level += 1
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
	
	
func restart():
	reset_everyone()
	phase_index = 0
	phase_timer.stop()
	current_state_phase = Phantom.STATES.CHASE
	set_up_phase.call_deferred()
	get_tree().paused = false
	introduction()


func pacman_eaten():
	if pacman_invicible:
		return
	var pacman = get_pacman()
	
	get_tree().paused = true
	
	await get_tree().create_timer(1.0).timeout
	
	if not is_instance_valid(pacman):
		return
		
	pacman.animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	global_dot_counter.reset()
	global_dot_counter.activate()
	
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.frightened = false
		ph.dot_counter.deactivate()
		ph.hide()
		ph.abort_move()
		
	pacman_death_audio_stream_player.play()
	
	await pacman.die()
	
	GlobalState.lives -= 1
	if GlobalState.lives >= 1:
		restart()
	else:
		game_over()
	
	
func game_over():
	LeaderBoard.submit_score(GlobalState.score)
	menu.cancel_button.hide()
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	gameover_layer.show()
	await get_tree().create_timer(1.5).timeout
	gameover_layer.hide()
	menu.display()
	
	
func reset_everyone():
	pacman_spawner.spawn()
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph._reset()
		
	
	
func trigger_frighten():
	point_phantom_acc = 0
	if not phase_timer.is_stopped():
		phase_timer_time_left = phase_timer.time_left
		phase_timer.stop()
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.get_frightened()
	frighten_timer.start()
	alarm_audio_stream_player.stop()
	invincible_audio_stream_player.play()

func _on_phase_timer_timeout() -> void:
	set_up_phase()
	
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.change_phase(current_state_phase)


func _on_frighten_timer_timeout() -> void:
	point_phantom_acc = 0
	phase_timer.wait_time = phase_timer_time_left
	phase_timer.start()
	invincible_audio_stream_player.stop()
	alarm_audio_stream_player.play()
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph.leave_frighten()


func _on_menu_visibility_changed() -> void:
	get_tree().paused = menu.visible


func _on_pacman_spawner_spawned(node: Node) -> void:
	node.dot_eaten.connect(_on_dot_eaten)
	node.bonus_eaten.connect(_on_bonus_eaten)


func _on_menu_restart_requested() -> void:
	GlobalState.score = 0
	GlobalState.lives = 3
	GlobalState.highest_score = LeaderBoard.get_highest_score()
	GlobalState.level = 0
	get_tree().reload_current_scene()

func _on_bonus_eaten(bonus):
	bonus_audio_stream_player.play()
	GlobalState.score += bonus.points
	pop_label(str(bonus.points))
	
func get_remaining_dots_count():
	return objects_layer.get_used_cells_by_id(1).size()

func _on_moving_eaten():
	var point_inc = point_phantom * pow(2, point_phantom_acc)
	GlobalState.score += point_inc
	pop_label(str(point_inc))
	eat_phantom_audio_stream_player.pitch_scale = 1.0 + point_phantom_acc * 0.2
	point_phantom_acc += 1
	eat_phantom_audio_stream_player.play()
	if point_phantom_acc == 4:
		all_four += 1
		if all_four == 4:
			GlobalState.score += 12000
			await get_tree().create_timer(0.4).timeout
			pop_label(str(12000))
	get_tree().paused = true
	await get_tree().create_timer(0.4).timeout
	get_tree().paused = false
	
func pop_label(text, node = null):
	var pop_label = pop_label_scene.instantiate()
	pop_label.text = text
	get_tree().current_scene.add_child(pop_label)
	var ref_node = get_pacman() if node == null else node
	pop_label.global_position = ref_node.global_position

func _on_global_dot_counter_incremented(count):
	for ph in get_tree().get_nodes_in_group("phantom"):
		ph._on_global_counter_incremented(count, global_dot_counter)


func _on_last_eat_timer_timeout() -> void:
	time_last_eat_counter.increment()


func _on_time_last_eat_counter_limit_reached():
	time_last_eat_counter.reset()
	time_last_eat_counter.activate()
	var next_ghost = get_next_preferred_ghost()
	if next_ghost != null:
		next_ghost.state = Phantom.STATES.GO_OUT


func _on_bonus_dot_counter_incremented(count):
	if count in [70, 170]:
		bonus_spawner.spawn()


func _on_bonus_spawner_spawned(node: Node) -> void:
	node.delete_time = randf_range(9.0, 10.0)
	node.texture = load("res://asset/bonus/%s.png" % SpeedChart.get_value("bonus"))
	node.points = SpeedChart.get_value("bonus_point")
	get_tree().current_scene.add_child(node)
	node.position = bonus_spawner.position
