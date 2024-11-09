extends Node

signal score_updated(score, old)
signal lives_updated(lives, old)
signal level_updated(level, old)

var score = 0:
	set(v):
		var old = score
		score = v
		score_updated.emit(score, old)


var lives = 3:
	set(v):
		var old = lives
		lives = v
		lives_updated.emit(lives, old)
		
var level = 0:
	set(v):
		var old = level
		level = v
		level_updated.emit(level, old)
		
var highest_score:
	get:
		if highest_score == null:
			return score
		return max(score, highest_score)
		
var first_intro = true

func _ready():
	highest_score = LeaderBoard.get_highest_score()
