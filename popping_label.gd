extends Node2D

@onready var label: Label = %Label

var text:
	set(v):
		text = v
		if not is_node_ready():
			await ready
		label.text = v
