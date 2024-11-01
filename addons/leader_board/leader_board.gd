extends Node

var config_file = "user://config.cfg"
var score_section = "scores"
var highscores_key = "highest"
var max_count = 10

var __config

signal scores_updated(scores)

# Called when the node enters the scene tree for the first time.
func _ready():
	__config = __get_config()
		

func get_scores():
	return __config.get_value(score_section, highscores_key, [])
	
func get_highest_score():
	var scores = get_scores()
	if scores.size() > 0:
		return scores[0]
	return null
	
func submit_score(score):
	var scores = get_scores()
	var dirty_score = false
	if scores.size() == max_count:
		for i in range(scores.size()):
			if scores[i] < score:
				scores.insert(i, score)
				dirty_score = true
				break
	else:
		dirty_score = true
		scores.push_back(score)
		scores.sort_custom(func(a, b): return a > b)
	
	if dirty_score:
		scores = scores.slice(0, max_count)
		scores_updated.emit(scores)
		__config.set_value(score_section, highscores_key, scores)
		__save()
	
	
func __get_config():
	var config = ConfigFile.new()
	config.load(config_file)
	return config
	
	
func __save():
	__config.save(config_file)
	
	
