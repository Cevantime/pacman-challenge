extends Node2D

@onready var walls_layer: TileMapLayer = %WallsLayer
@onready var objects_layer: TileMapLayer = %ObjectsLayer

@onready var pacman: Node2D = %Pacman

func _ready() -> void:
	check_pacman_move()

func _process(delta: float) -> void:
	if not pacman.moving:
		check_pacman_move()
		if not pacman.moving:
			pacman.stop()

func is_blocking(map_pos: Vector2i):
	return walls_layer.get_cell_source_id(map_pos) >= 0


func check_pacman_move():
	var pacman_pos = walls_layer.local_to_map(pacman.position)
	if pacman.move_input != Vector2i.ZERO and not is_blocking(pacman_pos + pacman.move_input):
		pacman.direction = pacman.move_input
	var target_pos = pacman_pos + pacman.direction
	if not is_blocking(pacman_pos + pacman.direction):
		if objects_layer.get_cell_source_id(target_pos) == 1:
			objects_layer.set_cell(target_pos, -1)
			GlobalState.score += 10
		pacman.do_move(Vector2(pacman.direction) * Vector2(16, 16))

	
func _on_pacman_move_done(destination: Variant) -> void:
	pacman.position.x = wrapf(pacman.position.x, 0.0, 448)
	pacman.position.y = wrapf(pacman.position.y, 0.0, 577)
	
	check_pacman_move()
