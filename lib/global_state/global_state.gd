extends Node

signal score_updated(score, old)
signal lives_updated(lives, old)
signal wave_updated(wave, old)
signal warp_updated(warp, old)
signal bomb_updated(bomb, old)


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
		
		
var wave = 0:
	set(v):
		var old = wave
		wave = v
		wave_updated.emit(wave, old)
		
var warp = 3:
	set(v):
		var old = warp
		warp = v
		warp_updated.emit(warp, old)
		
		
var bomb = 1:
	set(v):
		var old = bomb
		bomb = v
		bomb_updated.emit(bomb, old)
		
var highest_score:
	get:
		if highest_score == null:
			return score
		return max(score, highest_score)

func _ready():
	highest_score = LeaderBoard.get_highest_score()
