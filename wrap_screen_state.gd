extends State

var screen_width
var screen_height

func _ready() -> void:
	screen_width = ProjectSettings.get("display/window/size/viewport_width")
	screen_height = ProjectSettings.get("display/window/size/viewport_height")


func _supports(node: Node):
	return 'position' in node


func _process(delta: float) -> void:
	var p = referer.position
	p.x = wrapf(p.x, 0.0, screen_width)
	p.y = wrapf(p.y, 0.0, screen_height)
	referer.position = p
