class_name Counter extends Node

var count := 0
var active := false
var limit := 10

signal limit_reached
signal incremented

func increment():
	if active:
		count += 1
		incremented.emit(count)
		check_limit()

func activate():
	active = true
	check_limit()
	
func check_limit():
	if count >= limit:
		deactivate()
		limit_reached.emit() 
	
func deactivate():
	active = false

func reset():
	count = 0
