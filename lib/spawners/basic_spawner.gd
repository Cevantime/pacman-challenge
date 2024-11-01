extends Marker2D

signal spawned(node: Node)

@export var packed_scene: PackedScene
@export var future_parent_path: NodePath
@export var do_add_child = true

var future_parent

func _ready() -> void:
	if not future_parent_path.is_empty():
		future_parent = get_node(future_parent_path)

func spawn(g_position = null):
	var scene = packed_scene.instantiate()
	
	scene.global_position = global_position if g_position == null else g_position
	
	if 'spawner' in scene:
		scene.spawner = self
		
	var parent = future_parent if future_parent != null else get_tree().current_scene
	
	if do_add_child:
		parent.call_deferred("add_child", scene)
	
	spawned.emit(scene)
	
	return scene
