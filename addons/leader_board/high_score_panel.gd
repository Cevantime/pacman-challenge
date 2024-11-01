extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	LeaderBoard.scores_updated.connect(_on_scores_updated)
	update_scores(LeaderBoard.get_scores())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_scores_updated(scores):
	update_scores(scores)


func update_scores(scores):
	for c in get_children():
		c.queue_free()
	for s in scores: 
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = str(s)
		add_child(label)
