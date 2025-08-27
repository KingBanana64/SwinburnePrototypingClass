extends Node2D

## Level Making, manually change to write Levels
var editMode = true
## left bracket is for the animal, right is for the player
var EDIT_tap_times = [[],[]]
var current_level_name = "McDInThePentagon_short"

## !!!FIX!!BUG!!! Name of node wont always be Test1
@onready var input_handler = get_node("/root/level01")

## FOR "tap_times" - left bracket is for the animal, right is for the player
var levelInfo = {
	"McDInThePentagon" = {
		"tap_times": "[[1,2,3,4],[5,6,7,8]]",
		"animal_amount": 1
	},
	#"McDInThePentagon_short" = {
		#"tap_times": "[[1.05102644444447, 1.44021611111115, 1.80132722222227, 2.15549388888894, 3.88470622222233, 4.27359511111123, 4.60692844444456, 4.94720622222234], [2.50271611111118, 2.82910500000007, 3.17637288888897, 3.53748400000009, 5.26666666666678, 5.61388888888901, 5.93333333333345, 6.28750000000012]]",
		#"animal_amount": 1
	#},
		"McDInThePentagon_short" = {
		"tap_times": "[[1,2,3,4],[5,6,7,8]]",
		"animal_amount": 2
	},
}


func _ready() -> void:
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
		var animal_amount = levelInfo.get(current_level_name).get("animal_amount")
		input_handler.organise_inputs(tap_times_arr, animal_amount)


func _process(delta: float) -> void:
	if editMode:
		if Input.is_action_just_pressed("EDIT_Bark1"):
			EDIT_tap_times[0].append(input_handler.time_passed)
		elif Input.is_action_just_pressed("EDIT_Tap1"):
			EDIT_tap_times[1].append(input_handler.time_passed)
		
		elif Input.is_action_just_pressed("EDIT_Bark2"):
			## Check if array size exists, then add it
			if EDIT_tap_times.size() <= 2:
				EDIT_tap_times.append_array([[],[]])
			
			EDIT_tap_times[2].append(input_handler.time_passed)
		elif Input.is_action_just_pressed("EDIT_Tap2"):
			EDIT_tap_times[3].append(input_handler.time_passed)
		
		elif Input.is_action_just_pressed("EDIT_Bark2"):
			## Check if array size exists, then add it
			if EDIT_tap_times.size() <= 4:
				EDIT_tap_times.append_array([[],[]])
			
			EDIT_tap_times[4].append(input_handler.time_passed)
		elif Input.is_action_just_pressed("EDIT_Tap2"):
			EDIT_tap_times[5].append(input_handler.time_passed)


func finish():
	if editMode:
		print(EDIT_tap_times)
