extends Node2D

@onready var input_handler = get_node("/root/").get_child(0)
@onready var songTimer = get_node("/root/Test1/SongLength/")

## Level Making, manually change to write Levels
@export var editMode = false
## left bracket is for the animal, right is for the player
## all animals[ animal 1[ bark[],tap[]], animal 2[bark[], tap[]]...]
## NOTE: tap[] now accepts either:
##  - Float (instant tap at time)
##  - Array [start, end] (hold note captured by press→release)
var EDIT_tap_times = [[[],[]]]
var array = [[]]

## !!FIX!! assign current_level_name by outside scene
var current_level_name =  "McDInThePentagon_short" #"McDInThePentagon" #"DontMineAtNight"

## ----------------------------------------------------------
## Hold config (for editor): holds share the tap array
## A hold is stored as [start_time, end_time]
## Variable-length holds: key press starts, key release ends
## TAP_HOLD_THRESHOLD: presses shorter than this are saved as taps
## ----------------------------------------------------------
#@export var HOLD_NOTE_LEN: float = 0.8             ## kept for compatibility (unused in variable-length mode)
@export var TAP_HOLD_THRESHOLD: float = 0.15       ## seconds; < threshold ⇒ tap, else ⇒ hold
#@export var record_hold_mode: bool = false         ## deprecated in variable-length mode (kept to avoid breaking scenes)

## editor runtime: track press start times per lane for tap/hold capture
var _press_starts := {}   ## lane_index -> start_time (float)

var levelInfo = {
	"McDInThePentagon" = {
		"tap_times": "[[[], [[1.39044866666666, 2.70462033333333], 3.93795366666665, 4.27156999999999, 4.60490333333332, 4.93820466666665, 5.28820466666665, 5.63820466666665, 5.97153799999998, 6.32153799999998]], [[], [3.93795366666665]]]"
	},
	"McDInThePentagon_short" = {
		"tap_times": "[[[1.18469333333329, 1.60135999999993, 4.03052666666662, 4.74719333333331], [2.62635999999989, 2.9513599999999, [5.44302666666664, 5.82219333333331], 6.16385999999997]], [[1.96385999999991, 2.29302666666656], [3.28885999999992, 3.64719333333327]]]"
	},
	"DontMineAtNight" = {
		"tap_times": "[[[2.2333333333349, 2.7042583333352, 3.20032033333559, 9.87986578788315, 10.3798657878831, 10.8840324545498, 15.1358956666707, 17.5067290000039, 17.9817290000039, 22.260304333337, 25.1019710000035, 25.5978043333368, 28.9179883333366, 29.8596550000032, 33.697155000003], [4.16319912121514, 4.68819912121556, 5.14236578788259, 11.8109436666709, 12.2608956666709, 12.7608956666709, 17.0108956666706, 19.4150623333372, 19.9067290000038, 24.1394710000035, 27.0346550000034, 27.5096550000033, 30.8804883333365, 31.7929883333364, 35.6013216666697]], [[6.04653245454998, 7.06736578788331, 11.3256991212164, 14.6400623333374, 18.4483956666705, 21.3227186666704, 26.0763216666701, 33.222155000003, 36.5388216666697, 37.4799090000031], [7.97986578788326, 8.91319912121654, 13.2275623333375, 16.544229000004, 20.3483956666704, 23.1978043333369, 28.0096550000033, 35.1304883333364]], [[6.57153245455001, 13.7233956666708, 14.1942290000041, 18.9192290000038, 21.7644710000037, 32.7304883333364], [8.4465324545499, 15.6275623333374, 16.0733956666707, 20.8185520000037, 23.6686376666702, 34.6638216666697]]]"
	}
	## Place more levels here...
}

var EDIT_tap_keys = [
	["EDIT_Bark1","EDIT_Tap1"],
	["EDIT_Bark2","EDIT_Tap2"],
	["EDIT_Bark3","EDIT_Tap3"],
	## If want more inputs, place here...
]

func _ready() -> void:
	## If not in edit mode, send relevent level data to main node
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var tap_times_arr = str_to_var(tap_times)
		## NOTE: tap_times_arr now may include floats and [start,end] arrays inside each tap[] bucket.
		## Your input_handler.organise_inputs must accept both types.
		input_handler.organise_inputs(tap_times_arr)
	songTimer.start_song(current_level_name)


func _process(_delta: float) -> void:
	## LISTEN MODE
	if editMode:
		for i in range(EDIT_tap_keys.size()):
			## if Input == any Bark key or Tap key:
			if Input.is_action_just_pressed(EDIT_tap_keys[i][0]):
				## if array not large enough yet, make large enough
				while EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append([[],[]])
				
				## add current time as new bark
				EDIT_tap_times[i][0].append(float(input_handler.time_passed))
				print("barked " + str(i))
			
			## --- Tap/Hold capture: SAME KEY for both, decided by press→release length ---
			## on press: remember start time for this lane
			if Input.is_action_just_pressed(EDIT_tap_keys[i][1]):
				## if array not large enough yet, make large enough
				while EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append([[],[]])
				_press_starts[i] = float(input_handler.time_passed)
				## print("press start " + str(i))  ## optional debug
			
			## on release: decide tap vs hold using TAP_HOLD_THRESHOLD
			if Input.is_action_just_released(EDIT_tap_keys[i][1]) and _press_starts.has(i):
				var start_time: float = float(_press_starts[i])
				var end_time: float = float(input_handler.time_passed)
				_press_starts.erase(i)
				
				var length: float = max(0.0, end_time - start_time)
				
				## if length shorter than threshold, save a TAP at the press moment
				if length < TAP_HOLD_THRESHOLD:
					EDIT_tap_times[i][1].append(start_time)
					print("tapped " + str(i) + " @ " + str(start_time))
				else:
					## else save a HOLD as [start, end]
					EDIT_tap_times[i][1].append([start_time, end_time])
					print("hold (" + str(i) + ") " + str(start_time) + " -> " + str(end_time))


func finish():
	if editMode:
		print("-------\n" + str(EDIT_tap_times) + "\n-------")
		print("Already copied Array to Clipboard. Paste in:\nlevel_editor.gd -> levelInfo{ NAME_OF_SONG: {tap_times: __HERE__}}\nif having trouble ask Chris for help")
		## NOTE: The printed/copied shape allows taps (Float) and holds ([start,end]) in the same tap[] arrays.
		DisplayServer.clipboard_set(str(EDIT_tap_times))
