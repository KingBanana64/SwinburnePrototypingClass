extends Node2D

## Level Making, manually change to write Levels
var editMode = false
var current_level_name = "McDInThePentagon"

## !!!FIX!!BUG!!! Name of node wont always be Test1
@onready var input_handler = get_node("/root/Test1")

var levelInfo = {
	"McDInThePentagon" = {
		## left bracket is for the animal, right is for the player
		"tap_times": "[[1,2,3,4],[5,6,7,8]]"
	}
}


func _ready() -> void:
	if editMode:
		pass
	else:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
		input_handler.organise_inputs(tap_times_arr)
