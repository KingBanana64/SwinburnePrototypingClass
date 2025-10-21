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
		"tap_times": [[[1.076268, 1.53333366666666, 1.966667, 2.35000033333333, 2.73333366666666, 3.11666699999999, 3.45000033333332, 3.81666699999999, 4.16666699999999], [1.15000033333333, 1.55000033333333, 1.98333366666666, 2.38333366666666, 2.76666699999999, 3.13333366666666, 3.50000033333332, 3.83333366666666, 4.18333366666666]]],
		"swap_times": [[[3.54744278787872, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]]],
		"bpm": 176
	},
	"song_01" = {
		"tap_times": [[[3.64970144444435, 4.4511464444443, 22.8846134444444, 35.6210814444444], [5.25088344444424, 6.05811833333308, 24.4508344444444, 37.2209203333333]], [[10.087232333333, 10.4842444444442, 10.8839264444442, 23.6512244444444, 30.0844314444444, 36.0185174444444], [11.7176244444442, 12.0861193333331, 12.4838874444442, 25.253149, 31.6849384444444, 37.6520204444444]], [[16.4515184444443, 29.220769, 36.4181964444444], [[18.0580613333332, 18.8516654444443], [30.8856454444444, 31.3524854444444], 38.0852724444444]]],
		"swap_times": [[[6.55582533333301, 2], [25.6885503333328, 3], [38.438040333333, 0]], [[12.988891666666, 2], [25.6718843333328, 2], [32.0382963333331, 3], [38.438040333333, 2]], [[19.0721483333325, 1], [32.0216303333331, 3], [38.438040333333, 1]]],
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
