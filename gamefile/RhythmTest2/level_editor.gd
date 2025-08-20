extends Node2D

## Level Making, manually change to write Levels
var editMode = false
var current_level_name = "McDInThePentagon"

var levelInfo = {
	"McDInThePentagon" = {
		"tap_times": "[[1],[2]]"
	}
}

func _ready() -> void:
	
	if editMode:
		pass
	else:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
