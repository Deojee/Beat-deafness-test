extends ColorRect

func _ready():
	Globals.bearings = self
	

var displayTime = 0
func _process(delta):
	
	$"GetYourBearings/CenterContainer/Label".text = "Get your bearings! " + str(snapped(displayTime,0.1))
	if displayTime > 0:
		displayTime -= delta

var tween : Tween
func display(delay):
	kill()
	alive = true
	$GetYourBearings.visible = true
	displayTime = delay
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween() as Tween
	
	tween.tween_callback(
		func (): 
		$GetYourBearings.visible = false; 
		$"Go!".visible = true;
		).set_delay(delay)
	
	
	tween.tween_callback(
		func (): 
		kill()
		).set_delay(1.5)
	
	
	
	


var alive = true
func kill():
	alive = false
	$"Go!".visible = false
	$GetYourBearings.visible = false
	displayTime = 0
	
	if tween:
		tween.kill()
	tween = null
	pass
