extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.beatReact = self
	pass # Replace with function body.

func react():
	
	$AnimationPlayer.play("react")
	
	pass
