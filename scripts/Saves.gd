extends Node

var earliestBedTime : float = 22.5 

var latestBedTime : float = 23

var minimumBedtimeAward : float = 2

var maximumBedtimeAward : float = 3

var insultTax = 1

var fileName = "user://settings.save"

func _ready():

	_LoadSettings()


func save():
	var save_game = FileAccess.open(fileName, FileAccess.WRITE)
	
	var node_data =  {
		"earliestBedTime" : earliestBedTime,
		"latestBedTime" : latestBedTime,
		"minimumBedtimeAward" : minimumBedtimeAward,
		"maximumBedtimeAward" : maximumBedtimeAward,
		"insultTax" : insultTax,
	}
	
	#JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

#Note: This can be called from anywhere inside the tree. This function
#is path independent.
func _LoadSettings():
	
	
	if not FileAccess.file_exists(fileName):
		
		return;
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save = FileAccess.open(fileName, FileAccess.READ)
	while save.get_position() < save.get_length():
		var json_string = save.get_line()
		
		# Creates the helper class to interact with JSON
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		# Get the data from the JSON object
		var node_data = json.get_data()
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			set(i, node_data[i])
		
		
		
