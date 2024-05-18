extends Node

var justPressed = false

var beatButtonVisible = false

var showAttempt = false

var beatReact

var autoInput = true
var autoInputBPM = 127
var lastAutoInput = 0
func _process(delta):
	
	if autoInput and Time.get_ticks_msec() > lastAutoInput + 60000/autoInputBPM and Input.is_action_pressed("enter"):
		lastAutoInput = Time.get_ticks_msec()
		justPressed = true
	
