extends Node2D

@onready var input_handler = get_node("/root/Test1/")
@onready var songTimer = get_node("/root/Test1/SongLength/")

## Level Making, manually change to write Levels
@export var editMode = false
## left bracket is for the animal, right is for the player
## all animals[ animal 1[ bark[],tap[]], animal 2[bark[], tap[]]...]
## NOTE: tap[] now accepts either:
##  - Float (instant tap at time)
##  - Array [start, end] (hold note captured by press→release)
var EDIT_tap_times = [[[],[]]]
var EDIT_swap_times = [[]]
var array = [[]]

## !!FIX!! assign current_level_name by outside scene
var current_level_name: String

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
	"McDInThePentagon_short" = {
		"tap_times": [[[1.07442858152952, 1.48032212121205], [2.53077778787866, 2.88911112121201]], [[1.83873233333324, 2.19706566666655], [3.22245099999991, 3.58084799999992]], [[3.96418133333328], [[5.3141813333333, 5.95584799999996]]]],
		"swap_times": [[[3.54744278787872, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]]],
		"bpm": 176
	},
	"song_01" = {
		"tap_times": [[[3.79392700000278, 17.0513430000041, 23.1049740000038], [5.50696066667081, 18.6885953333374, 24.6841406666703]], [[4.72309366667019, 16.6430096666708, 30.3508073333367, 35.932597000003], [6.27362733333808, 18.3092156666707, 31.8992636666699, 37.5075970000031]], [[10.3143080000045, 29.5133073333367, 37.1117636666697], [[11.9185496666711, 12.7227163333377], 31.1202170000033, 38.7242636666698]]],
		"swap_times": [],
		"bpm": 75
	}
	## Place more levels here...
}

var EDIT_tap_keys = [
	["EDIT_Bark1","EDIT_Tap1"],
	["EDIT_Bark2","EDIT_Tap2"],
	["EDIT_Bark3","EDIT_Tap3"],
	## If want more inputs, place here...
]

var EDIT_Swap_keys = [
	"EDIT_Swap1",
	"EDIT_Swap2",
	"EDIT_Swap3",
]

func _ready() -> void:
	current_level_name = globalVariables.SelectedSong
	## If not in edit mode, send relevent level data to main node
	var bpm: float
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var swap_times = levelInfo.get(current_level_name).get("swap_times")
		## NOTE: tap_times_arr now may include floats and [start,end] arrays inside each tap[] bucket.
		## Your input_handler.organise_inputs must accept both types.
		bpm = levelInfo.get(current_level_name).get("bpm")
		input_handler.organise_inputs(tap_times,swap_times)
	songTimer.start_song(current_level_name, bpm)


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
		
		for i in range(EDIT_Swap_keys.size()):
			## if Input == any Bark key or Tap key:
			if Input.is_action_just_pressed(EDIT_Swap_keys[i]):
				while EDIT_swap_times.size() < (i+1):
					EDIT_swap_times.append([])
				
				## add current time as new swap
				EDIT_swap_times[i].append([float(input_handler.time_passed),0])
				print("swap " + str(i) + " at " + str(input_handler.time_passed))



func finish():
	if editMode:
		var paste : String = ''
		
		if (!EDIT_tap_times[0][0].is_empty()):
			print("------- Tap times added -------")
			paste += '"tap_times": ' + str(EDIT_tap_times) + ',\n'
		if (!EDIT_swap_times[0].is_empty()): 
			print("------- Swap times added -------")
			paste += '"swap_times": ' + str(EDIT_swap_times) + ',\n'
		
		## NOTE: The printed/copied shape allows taps (Float) and holds ([start,end]) in the same tap[] arrays.
		if (!paste.is_empty()): 
			DisplayServer.clipboard_set(paste)
			print("Already copied everything to Clipboard. Paste in:\nnotepad to prepare all data, then paste final result in\nlevel_editor.gd -> levelInfo{ NAME_OF_SONG: {__HERE__}}\nif having trouble ask Chris for help")
	else: 
		input_handler.score()
	songTimer.stopSong()
