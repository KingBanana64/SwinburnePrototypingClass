extends Node2D

## Level Making, manually change to write Levels
var editMode = false
## left bracket is for the animal, right is for the player
var EDIT_tap_times = [[],[]]
var current_level_name = "McDInThePentagon_short"

## !!!FIX!!BUG!!! Name of node wont always be Test1
@onready var input_handler = get_node("/root/Test1")

## FOR "tap_times" - left bracket is for the animal, right is for the player
var levelInfo = {
	"McDInThePentagon" = {
		"tap_times": "[[1,2,3,4],[5,6,7,8]]"
	},
	"McDInThePentagon_short" = {
		"tap_times": "[[1.03194444444447, 1.43144434920638, 1.81813055555559, 2.17229722222227, 3.88115222222231, 4.25615222222232, 4.61726400000011, 4.95079574603185], [2.53372563492069, 2.88800088888895, 3.24216755555563, 3.56161200000008, 5.28412907936518, 5.62440685714296, 5.95774019047629, 6.29801796825407]]"
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


func finish():
	if editMode:
		print(EDIT_tap_times)
