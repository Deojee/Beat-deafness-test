@tool

extends VBoxContainer

@export var songName = ""
@export var artist = ""

@export var songPath : String = ""
@export var secondsOfSong : float = 10
@export var delaySeconds : float = 0.1

@export var bpm : float = 200
@export var bpmDelaySeconds : float = 0.0

var beatLinePath : String  = "res://scenes/beat_timer_line.tscn"


func _ready():
	
	if Engine.is_editor_hint():
		return
	
	%songName.text = songName
	%artist.text = artist
	
	if Engine.is_editor_hint():
		return
	
	addControl()
	addNewLine()
	%AudioStreamPlayer.stream = load(songPath)
	

func _process(delta):
	%songName.text = songName
	%artist.text = artist
	if Engine.is_editor_hint():
		return

var playing = false

var currentBeatLine : beatTimerLine = null
var controlBeatLine : beatTimerLine = null
func _on_play_button_pressed():
	
	if playing:
		stop()
		return
	
	start()
	

func addControl():
	
	var newLine = load(beatLinePath).instantiate() 
	%beatLines.add_child(newLine)
	newLine.control = null
	controlBeatLine = newLine
	controlBeatLine.holder = self
	controlBeatLine.lengthInSeconds = secondsOfSong
	
	
	
	controlBeatLine.setControlBeats(bpm,bpmDelaySeconds)
	
	currentBeatLine = controlBeatLine
	

func addNewLine():
	stop()
	
	var newLine = load(beatLinePath).instantiate() 
	%beatLines.add_child(newLine)
	newLine.control = controlBeatLine
	currentBeatLine = newLine
	currentBeatLine.holder = self
	currentBeatLine.lengthInSeconds = secondsOfSong
	

func stop():
	if currentBeatLine:
		currentBeatLine.cancel()
	%AudioStreamPlayer.stop()
	playing = false
	%playButton.text = "Play"
	
	Globals.beatButtonVisible = false
	

func start():
	currentBeatLine.start(%AudioStreamPlayer,delaySeconds)
	playing = true
	%playButton.text = "Cancel"
	
	Globals.beatButtonVisible = true
	
