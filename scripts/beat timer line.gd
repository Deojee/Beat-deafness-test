extends Control

class_name beatTimerLine

@export var lengthInSeconds = 60 * 3 + 45

#beats is an array of the number of miliseconds in that the beat is.
var beats : Array = []

var previous : beatTimerLine = null
var holder

var running = false
var startTime : float = 0.0
func _physics_process(delta):
	
	
	if !running:
		return
	
	var furthestPosition = 1800.0
	var currentPosition : float = Time.get_ticks_msec() - startTime
	var percentageOfSong = (currentPosition/1000.0)/float(lengthInSeconds)
	%marker.position.x = percentageOfSong * furthestPosition
	
	if percentageOfSong > 1:
		end()
		return
	
	if Input.is_action_just_pressed("space") or Globals.justPressed:
		Globals.justPressed = false
		var newMarker = ColorRect.new()
		%beatLines.add_child(newMarker)
		newMarker.position.x = percentageOfSong * furthestPosition - 1.0
		newMarker.size = Vector2(4,40)
		newMarker.color = Color.BLUE
		
		beats.append(currentPosition)
		
		pass
	
	
	pass

func start(player : AudioStreamPlayer,delaySeconds : float):
	
	
	for child in %beatLines.get_children():
		child.queue_free()
	
	for line in get_tree().get_nodes_in_group("beatLines"):
		line.visible = false
	visible = true
	holder.visible = true
	
	await get_tree().create_timer(delaySeconds).timeout
	
	running = true
	startTime = Time.get_ticks_msec()
	player.play()

func cancel():
	
	running = false
	for line in get_tree().get_nodes_in_group("beatLines"):
		line.visible = true
	
	

func end():
	running = false
	for line in get_tree().get_nodes_in_group("beatLines"):
		line.visible = true
	
	updateLabel()
	
	holder.addNewLine()
	

func updateLabel():
	
	if previous == null or previous.beats.size() == 0:
		%Label.text = "No previous attempt"
		return
	
	var previousBeats = previous.beats
	
	var labelText = ""
	
	var numberOfBeatsDifference : int = previous.beats.size() - beats.size()
	
	if numberOfBeatsDifference == 0:
		labelText += "Same number of beats.  | "
	elif  numberOfBeatsDifference < 0:
		labelText += str(abs(numberOfBeatsDifference)) + " more beats.  | "
	else:
		labelText += str(abs(numberOfBeatsDifference)) + " less beats.  | "
	
	var averageDifference : float = 0
	var totalDifference : float = 0
	
	for beat in beats:
		var difference = getClosestDistance(beat,previousBeats)
		averageDifference += difference
		totalDifference += abs(difference)
	averageDifference /= float(beats.size())
	
	labelText += " Average difference (MS) " + str(int(averageDifference))
	labelText += " Total difference (MS) " + str(totalDifference)
	
	%Label.text = labelText
	

#assumes sorted list is from least to greatest, and not empty
#negative means it's late and positive means it's early.
func getClosestDistance(num,sortedList):
	
	var smallestDifference = num - sortedList.front()
	for newNum in sortedList:
		
		var difference = num - newNum
		
		if abs(difference) > smallestDifference:
			return smallestDifference
		
		smallestDifference = abs(difference)
		
		
	
	return smallestDifference
