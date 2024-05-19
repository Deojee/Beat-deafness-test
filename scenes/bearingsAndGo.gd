extends ColorRect

func _ready():
	Globals.bearings = self
	

func display(delay):
	alive = true
	$GetYourBearings.visible = true
	
	await get_tree().create_timer(delay).timeout
	
	$GetYourBearings.visible = false
	$"Go!".visible = true
	
	if !alive:
		kill()
		return
	
	await get_tree().create_timer(1.5).timeout
	
	
	$"Go!".visible = false
	


var alive = true
func kill():
	alive = false
	$"Go!".visible = false
	$GetYourBearings.visible = false
	pass
