extends Control

class_name beatTimerLine

@export var lengthInSeconds = 60 * 3 + 45



#beats is an array of the number of miliseconds in that the beat is.
var beats : Array = []

#associates times with the boxes there.
var boxes : Dictionary = {}

var control : beatTimerLine = null
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
		Globals.beatReact.react()
		Globals.justPressed = false
		var newMarker = ColorRect.new()
		%beatLines.add_child(newMarker)
		newMarker.position.x = percentageOfSong * furthestPosition - 1.0
		newMarker.size = Vector2(4,40)
		newMarker.color = Color.BLUE
		
		beats.append(currentPosition)
		boxes[currentPosition] = newMarker
		
		pass
	
	
	pass

func setControlBeats(bpm,bpmDelaySeconds):
	
	var milisecondsPerBeat = 60000/bpm
	var newBeats = [bpmDelaySeconds * 1000]
	while newBeats.back() < lengthInSeconds * 1000.0:
		newBeats.append(newBeats.back() + milisecondsPerBeat)
	
	for beat in newBeats:
		
		Globals.justPressed = false
		var newMarker = ColorRect.new()
		%beatLines.add_child(newMarker)
		newMarker.position.x = (beat/1000.0)/float(lengthInSeconds) * 1800 - 1.0
		newMarker.size = Vector2(4,40)
		newMarker.color = Color.BLUE
		
		beats.append(beat)
		
		
	
	%Label.text = "Control"
	

func start(player : AudioStreamPlayer,delaySeconds : float):
	
	
	for child in %beatLines.get_children():
		child.queue_free()
	
	for line in get_tree().get_nodes_in_group("beatLines"):
		line.visible = false
	
	
	holder.visible = true
	if Globals.showAttempt and control:
		control.visible = true
		visible = true
	
	
	await get_tree().create_timer(delaySeconds).timeout
	
	running = true
	startTime = Time.get_ticks_msec()
	player.play(max(-delaySeconds,0))

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
	
	if control == null or control.beats.size() == 0:
		%Label.text = "Control"
		return
	
	var controlBeats = control.beats
	
	var labelText = ""
	
	var numberOfBeatsDifference : int = controlBeats.size() - beats.size()
	
	if numberOfBeatsDifference == 0:
		labelText += "Same number of beats.  | "
	elif  numberOfBeatsDifference < 0:
		labelText += str(abs(numberOfBeatsDifference)) + " more beats. (" + str(beats.size()) + ")  | "
	else:
		labelText += str(abs(numberOfBeatsDifference)) + " less beats. (" + str(beats.size()) + ")  | "
	
	var averageDifference : float = 0
	var absoluteAverageDifference : float = 0
	
	var averagePositiveDifference : float = 0
	var positiveDifferenceCount : float = 0
	
	var averageNegativeDifference : float = 0
	var negativeDistanceCount : float = 0
	
	var totalDifference : float = 0
	
	for beat in beats:
		var difference = getClosestDistance(beat,controlBeats)
		averageDifference += difference
		totalDifference += abs(difference)
		
		if difference >= 0:
			positiveDifferenceCount += 1
			averagePositiveDifference += difference
		else:
			negativeDistanceCount += 1
			averageNegativeDifference += difference
		
	
	averageDifference /= float(beats.size())
	averageNegativeDifference /= negativeDistanceCount
	averagePositiveDifference /= positiveDifferenceCount
	
	labelText += " Average difference (MS) " + str(int(averageDifference)) 
	labelText += " POS: " + str(int(averagePositiveDifference)) +  " * " + str(int(positiveDifferenceCount))
	labelText += " NEG: " + str(int(averageNegativeDifference)) +  " * " + str(int(negativeDistanceCount))
	
	labelText += " | Total difference (MS) " + str(totalDifference)
	
	%Label.text = labelText
	

#assumes sorted list is from least to greatest, and not empty
#negative means it's late and positive means it's early.
func getClosestDistance(num,sortedList):
	
	var smallestDifference = num - sortedList.front()
	for newNum in sortedList:
		
		var difference = num - newNum
		
		if abs(difference) > abs(smallestDifference):
			
			#var newMarker = Label.new()
			#%labelLines.add_child(newMarker)
			#newMarker.position.x = (num/1000.0)/float(lengthInSeconds) * 1800 - 1.0
			#newMarker.text = str(int(smallestDifference))# + "\n" + str(num," ",newNum)
			
			return smallestDifference
		
		smallestDifference = difference
		
	
	#var newMarker = Label.new()
	#%labelLines.add_child(newMarker)
	#newMarker.position.x = (num/1000.0)/float(lengthInSeconds) * 1800 - 1.0
	#newMarker.text = str(int(smallestDifference))# + "\n" + str(num," ",newNum)
	
	return smallestDifference
