extends Node2D

## Level Making, manually change to write Levels
var editMode = false
var current_level_name = "McDInThePentagon_short"
## left bracket is for the animal, right is for the player
var EDIT_tap_times = [[],[]]

## !!!FIX!!BUG!!! Name of node wont always be Test1
@onready var input_handler = get_node("/root/Test1")

var levelInfo = {
	"McDInThePentagon" = {
		## left bracket is for the animal, right is for the player
		"tap_times": "[[1,2,3,4],[5,6,7,8]]"
	},
		"McDInThePentagon_short" = {
		## left bracket is for the animal, right is for the player
		"tap_times": "[[1.04620944444446, 1.49085230158733, 1.87279674603178, 2.21307452380957, 3.93529674603184, 4.26168755555566, 4.61605263492075, 4.94244152380963], [2.52557452380958, 2.91446341269848, 3.24085230158738, 3.58113007936517, 5.28296711111122, 5.64407822222233, 5.98435600000011, 6.32463377777788]]"
	},
}


func _ready() -> void:
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
		input_handler.organise_inputs(tap_times_arr)


func _process(delta: float) -> void:
	if editMode:
		if Input.is_action_just_pressed("tap"):
			EDIT_tap_times[1].append(input_handler.time_passed)
			pass
		elif Input.is_action_just_pressed("EDIT_Add"):
			EDIT_tap_times[0].append(input_handler.time_passed)
			pass
	else:
		pass

func finish():
	if editMode:
		print(EDIT_tap_times)
