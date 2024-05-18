extends Button

var justPressed = false

func _process(delta):
	
	visible = Globals.beatButtonVisible
	

func _on_pressed():
	Globals.justPressed = true
	pass # Replace with function body.


