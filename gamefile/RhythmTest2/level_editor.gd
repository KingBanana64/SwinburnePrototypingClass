extends Node2D

## Level Making, manually change to write Levels
@export var editMode = false
## left bracket is for the animal, right is for the player
## all animals[ animal 1[ bark[],tap[]], animal 2[bark[], tap[]]...]
var EDIT_tap_times = [[[],[]]]
var array = [[]]
var EDIT_tap_keys = [
	["EDIT_Bark1","EDIT_Tap1"],
	["EDIT_Bark2","EDIT_Tap2"],
	["EDIT_Bark3","EDIT_Tap3"],
	## If want more inputs, place here...
]
var current_level_name = "McDInThePentagon_short"

## !!!FIX!!BUG!!! Name of node wont always be Test1
@onready var input_handler = get_node("/root/Test1")

## FOR "tap_times" - left bracket is for the animal, right is for the player
var levelInfo = {
	"McDInThePentagon" = {
		"tap_times": "[[1,2,3,4],[5,6,7,8]]"
	},
	"McDInThePentagon_short" = {
		"tap_times": "[[[1.17954066666667, 1.480377, 1.84704366666666, 2.18077933333333], [2.53128333333333, 2.84794999999999, 3.19794999999999, 3.54794999999999]], [[3.91461666666666, 4.26461666666665], [5.29794999999998, 5.66461666666665]], [[4.59794999999999, 4.96461666666665], [5.98128333333332, 6.31461666666665]]]"
	},
}


func _ready() -> void:
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
		input_handler.organise_inputs(tap_times_arr)


func _process(delta: float) -> void:
	if editMode:
		for i in range(0,3):
			## if Input == any Bark key or Tap key:
			if Input.is_action_just_pressed(EDIT_tap_keys[i][0]):
				## if array not large enough yet, add another array
				if EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append_array([[[],[]]])
					print("extended")
					
				EDIT_tap_times[i][0].append(input_handler.time_passed)
				print("barked")
				
			elif Input.is_action_just_pressed(EDIT_tap_keys[i][1]):
				## if array not large enough yet, add another array
				if EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append_array([[[],[]]])
					print("extended")
				
				EDIT_tap_times[i][1].append(input_handler.time_passed)
				print("tapped")
		
		#if Input.is_action_just_pressed("tap"):
			#EDIT_tap_times[1].append(input_handler.time_passed)
			#pass
		#elif Input.is_action_just_pressed("EDIT_Add"):
			#EDIT_tap_times[0].append(input_handler.time_passed)
			#pass


func finish():
	if editMode:
		print(EDIT_tap_times)
