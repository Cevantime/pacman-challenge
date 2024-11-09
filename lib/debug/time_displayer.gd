extends Control

@onready var label_time: Label = %LabelTime

func _ready():
	if OS.has_feature("release"):
		hide()

func _process(delta: float) -> void:
	var msecs = Time.get_ticks_msec()
	var msecs_mod = msecs % 1000
	var time = str(msecs_mod)
	if msecs >= 1000:
		var secs = (msecs - msecs_mod) / 1000
		var secs_mod = secs % 60
		time = str(secs_mod) + ":" + time
		if secs >= 60:
			var mins = (secs - secs_mod) / 60
			var mins_mod = mins % 60
			time = str(mins_mod) + ":" + time
			if mins >= 60:
				var hours = (mins - mins_mod) / 60
				time = str(hours) + ":" + time
	
	label_time.text = time
