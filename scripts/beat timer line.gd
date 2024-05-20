extends Control

class_name beatTimerLine

@export var lengthInSeconds = 60 * 3 + 45

var safeTimeSeconds

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
		
		updateLabel()
		pass
	
	
	pass

var milisecondsPerBeat
func setControlBeats(bpm,bpmDelaySeconds):
	
	milisecondsPerBeat = 60000/bpm
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
	
	Globals.justPressed = false
	
	for child in %beatLines.get_children():
		child.queue_free()
	for child in %labelLines.get_children():
		child.queue_free()
	
	boxes.clear()
	beats.clear()
	
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
	
	for child in %controlBeatLines.get_children():
		child.queue_free()
	for child in %labelLines.get_children():
		child.queue_free()
	for beat in controlBeats:
		
		Globals.justPressed = false
		var newMarker = ColorRect.new()
		%controlBeatLines.add_child(newMarker)
		newMarker.position.x = (beat/1000.0)/float(lengthInSeconds) * 1800 - 1.0
		newMarker.position.y = -10
		newMarker.size = Vector2(4,20)
		newMarker.color = Color.BLUE
		
	
	
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
		absoluteAverageDifference += abs(difference)
		
		if difference >= 0:
			positiveDifferenceCount += 1
			averagePositiveDifference += difference
		else:
			negativeDistanceCount += 1
			averageNegativeDifference += difference
		
		var maxErrorMiliseconds = control.milisecondsPerBeat/2.0
		var wrongNess = float(difference)/float(maxErrorMiliseconds)
		boxes[beat].color = Color.GREEN.lerp(Color.RED,wrongNess)
		
	
	averageDifference /= float(beats.size())
	averageNegativeDifference /= negativeDistanceCount if negativeDistanceCount != 0 else 1
	averagePositiveDifference /= positiveDifferenceCount if negativeDistanceCount != 0 else 1
	absoluteAverageDifference /= float(beats.size())
	
	labelText += " Average difference (MS) " + str(int(averageDifference)) 
	labelText += " ABS: " + str(int(absoluteAverageDifference))
	labelText += " POS: " + str(int(averagePositiveDifference)) +  " * " + str(int(positiveDifferenceCount))
	labelText += " NEG: " + str(int(averageNegativeDifference)) +  " * " + str(int(negativeDistanceCount))
	
	labelText += " | Total difference (MS) " + str(int(totalDifference))
	
	%RawLabel.text = labelText
	
	#after this we redo the math for the adjusted numbers
	var adjustedBeats = []
	for beat in beats:
		adjustedBeats.append( beat - int(averageDifference))
	
	
	for beat in controlBeats:
		
		Globals.justPressed = false
		var newMarker = ColorRect.new()
		%controlBeatLines.add_child(newMarker)
		newMarker.position.x = ((beat + int(averageDifference)) /1000.0)/float(lengthInSeconds) * 1800 - 1.0
		newMarker.position.y = -10
		newMarker.size = Vector2(4,20)
		newMarker.color = Color.AQUA if beat > safeTimeSeconds * 1000 else Color.SLATE_GRAY
		
	
	labelText = ""
	
	absoluteAverageDifference = 0
	
	averagePositiveDifference = 0
	positiveDifferenceCount = 0
	
	averageNegativeDifference = 0
	negativeDistanceCount = 0
	
	totalDifference = 0
	
	for beat in adjustedBeats:
		var difference = getClosestDistance(beat,controlBeats)
		
		totalDifference += abs(difference)
		absoluteAverageDifference += abs(difference)
		
		if difference >= 0:
			positiveDifferenceCount += 1
			averagePositiveDifference += difference
		else:
			negativeDistanceCount += 1
			averageNegativeDifference += difference
		
		var maxErrorMiliseconds = control.milisecondsPerBeat/2.0
		var wrongNess = float(difference)/float(maxErrorMiliseconds)
		boxes[beat + int(averageDifference)].color = Color.GREEN.lerp(Color.RED,wrongNess)
		
	
	
	averageNegativeDifference /= negativeDistanceCount if negativeDistanceCount != 0 else 1
	averagePositiveDifference /= positiveDifferenceCount if negativeDistanceCount != 0 else 1
	absoluteAverageDifference /= float(beats.size())
	
	labelText += " Absolute Average " + str(int(absoluteAverageDifference)) 
	labelText += " POS: " + str(int(averagePositiveDifference)) +  " * " + str(int(positiveDifferenceCount))
	labelText += " NEG: " + str(int(averageNegativeDifference)) +  " * " + str(int(negativeDistanceCount))
	
	labelText += " | Total difference (MS) " + str(int(totalDifference))
	
	%Label.text = labelText
	
	var cutControlBeats = []
	for beat in controlBeats:
		if beat > safeTimeSeconds * 1000:
			cutControlBeats.append(beat)
	cutControlBeats.pop_back()
	cutControlBeats.pop_back()
	
	var numberOfBeats = countBeats(adjustedBeats,cutControlBeats)
	var beatsPercent = float(numberOfBeats)/float(cutControlBeats.size()) * 100
	beatsPercent = snapped(beatsPercent,0.1)
	
	var accuracyPercent = 100.0 - snapped(
				float(absoluteAverageDifference)/
				((float(milisecondsPerBeat)/2.0)) * 100
				,0.1)
	
	
	%Accuracy.text = ("Accuracy\n" + 
	str(accuracyPercent)+ "%\n"
	+ str(snapped(absoluteAverageDifference,0.1)) + " ms"
	)
	
	%Beats.text = (
	"Beats\n" + 
	str(beatsPercent) + "%\n"
	+ str(numberOfBeats) + "/" + str(cutControlBeats.size())
	)
	
	var score = 100.0
	var letterGrade = "A"
	score -= (100.0 - accuracyPercent)/1.5
	score -= abs(beatsPercent - 100.0) 
	
	score = snapped(score,0.1)
	
	if score > 90:
		letterGrade = "A"
	elif score > 80:
		letterGrade = "B"
	elif score > 70:
		letterGrade = "C"
	elif score > 60:
		letterGrade = "D"
	elif score > 50:
		letterGrade = "F"
	else:
		letterGrade = "BAD"
	
	%Grade.text = (
	"Grade\n" + 
	str(score) + "%\n"
	+ str(letterGrade)
	)
	

#assumes sorted list is from least to greatest, and not empty
#negative means it's late and positive means it's early.
func getClosestDistance(num,sortedList):
	
	var smallestDifference = num - sortedList.front()
	for newNum in sortedList:
		
		var difference = num - newNum
		
		if abs(difference) > abs(smallestDifference):
			
			break
		
		smallestDifference = difference
		
	
	
	return smallestDifference

func countBeats(beats,controlBeats):
	
	var hitBeats = 0
	for beat in controlBeats:
		var difference = getClosestDistance(beat,controlBeats)
		if difference < milisecondsPerBeat/2.0:
			hitBeats += 1
	
	return hitBeats
