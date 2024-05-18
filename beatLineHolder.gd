extends VBoxContainer

@export var songName = ""

var beatLinePath : String  = ""


func _ready():
	
	currentBeatLine = %beatLines/beatLine
	currentBeatLine.holder = self
	
	%songName.text = songName
	


var currentBeatLine : beatTimerLine
func _on_play_button_pressed():
	currentBeatLine.start()
	%AudioStreamPlayer.play()

func addNewLine():
	var newLine = load(beatLinePath).instantiate() 
	%beatLines.add_child(newLine)
	newLine.previous = currentBeatLine
	currentBeatLine = newLine
	currentBeatLine.holder = self
	

func _on_cancel_button_pressed():
	currentBeatLine.cancel()
	%AudioStreamPlayer.stop()
	
