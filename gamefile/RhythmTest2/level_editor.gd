extends Node2D

@onready var input_handler = get_node("/root/Test1/")
@onready var songTimer = get_node("/root/Test1/SongLength/")

## Level Making, manually change to write Levels
@export var editMode = false
## left bracket is for the animal, right is for the player
## NOTE: both brackets now accept Float (instant) OR Array [start,end] (hold)
var EDIT_tap_times = [[[],[]]]
var EDIT_swap_times = [[]]
var array = [[]]

## !!FIX!! assign current_level_name by outside scene
var current_level_name: String

## ----------------------------------------------------------
## Holds: variable-length using press→release
## A hold is stored as [start_time, end_time]
## ----------------------------------------------------------
@export var TAP_HOLD_THRESHOLD: float = 0.15

## editor runtime: track press start times per lane
var _press_starts := {}        ## for player taps (right bracket)
var _bark_press_starts := {}   ## NEW: for animal calls (left bracket)

var levelInfo = {
	"McDInThePentagon_short" = {
		"tap_times": [[[[0.89074833333333, 1.70775166666666], [4.55763266666665, 5.40763266666665]], [[3.19096599999999, 3.47429933333332], [6.24096599999998, 6.49096599999998]]]],
		"swap_times": [[[3.54744278787872, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]], [[3.56410945454539, 1], [6.3057761212121, 2]]],
		"bpm": 176
	},
	"song_01" = {
		"tap_times": [[[3.64970144444435, 4.4511464444443, 22.8846134444444, 35.6210814444444], [5.25088344444424, 6.05811833333308, 24.4508344444444, 37.2209203333333]], [[10.087232333333, 10.4842444444442, 10.8839264444442, 23.6512244444444, 30.0844314444444, 36.0185174444444], [11.7176244444442, 12.0861193333331, 12.4838874444442, 25.253149, 31.6849384444444, 37.6520204444444]], [[16.4515184444443, 29.220769, 36.4181964444444], [[18.0580613333332, 18.8516654444443], [30.8856454444444, 31.3524854444444], 38.0852724444444]]],
		"swap_times": [[[6.55582533333301, 2], [25.6885503333328, 3], [38.438040333333, 0]], [[12.988891666666, 2], [25.6718843333328, 2], [32.0382963333331, 3], [38.438040333333, 2]], [[19.0721483333325, 1], [32.0216303333331, 3], [38.438040333333, 1]]],
		"bpm": 75
	}
}

var EDIT_tap_keys = [
	["EDIT_Bark1","EDIT_Tap1"],
	["EDIT_Bark2","EDIT_Tap2"],
	["EDIT_Bark3","EDIT_Tap3"],
]

var EDIT_Swap_keys = [
	"EDIT_Swap1",
	"EDIT_Swap2",
	"EDIT_Swap3",
]

func _ready() -> void:
	current_level_name = globalVariables.SelectedSong
	var bpm: float
	if !editMode:
		var tap_times = levelInfo.get(current_level_name).get("tap_times")
		var swap_times = levelInfo.get(current_level_name).get("swap_times")
		bpm = levelInfo.get(current_level_name).get("bpm")
		input_handler.organise_inputs(tap_times,swap_times)
	songTimer.start_song(current_level_name, bpm)

func _process(_delta: float) -> void:
	if editMode:
		for i in range(EDIT_tap_keys.size()):
			# ---------- ANIMAL (left bracket) now supports holds ----------
			if Input.is_action_just_pressed(EDIT_tap_keys[i][0]):
				while EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append([[],[]])
				_bark_press_starts[i] = float(input_handler.time_passed)

			if Input.is_action_just_released(EDIT_tap_keys[i][0]) and _bark_press_starts.has(i):
				var start_time: float = float(_bark_press_starts[i])
				var end_time: float = float(input_handler.time_passed)
				_bark_press_starts.erase(i)
				var length: float = max(0.0, end_time - start_time)
				if length < TAP_HOLD_THRESHOLD:
					EDIT_tap_times[i][0].append(start_time)
					print("barked %d @ %.3f" % [i, start_time])
				else:
					EDIT_tap_times[i][0].append([start_time, end_time])
					print("bark HOLD (%d) %.3f -> %.3f" % [i, start_time, end_time])

			# ---------- PLAYER (right bracket) unchanged logic ----------
			if Input.is_action_just_pressed(EDIT_tap_keys[i][1]):
				while EDIT_tap_times.size() < (i+1):
					EDIT_tap_times.append([[],[]])
				_press_starts[i] = float(input_handler.time_passed)
			if Input.is_action_just_released(EDIT_tap_keys[i][1]) and _press_starts.has(i):
				var start_time: float = float(_press_starts[i])
				var end_time: float = float(input_handler.time_passed)
				_press_starts.erase(i)
				var length: float = max(0.0, end_time - start_time)
				if length < TAP_HOLD_THRESHOLD:
					EDIT_tap_times[i][1].append(start_time)
					print("tapped %d @ %.3f" % [i, start_time])
				else:
					EDIT_tap_times[i][1].append([start_time, end_time])
					print("hold (%d) %.3f -> %.3f" % [i, start_time, end_time])
		
		for i in range(EDIT_Swap_keys.size()):
			if Input.is_action_just_pressed(EDIT_Swap_keys[i]):
				while EDIT_swap_times.size() < (i+1):
					EDIT_swap_times.append([])
				EDIT_swap_times[i].append([float(input_handler.time_passed),0])
				print("swap %d at %.3f" % [i, float(input_handler.time_passed)])

func finish():
	if editMode:
		var paste : String = ''
		if (!EDIT_tap_times[0][0].is_empty()):
			print("------- Tap times added -------")
			paste += '"tap_times": ' + str(EDIT_tap_times) + ',\n'
		if (!EDIT_swap_times[0].is_empty()): 
			print("------- Swap times added -------")
			paste += '"swap_times": ' + str(EDIT_swap_times) + ',\n'
		if (!paste.is_empty()): 
			DisplayServer.clipboard_set(paste)
			print("Already copied everything to Clipboard. Paste in:\nnotepad to prepare all data, then paste final result in\nlevel_editor.gd -> levelInfo{ NAME_OF_SONG: {__HERE__}}\nif having trouble ask Chris for help")
	else: 
		input_handler.score()
	songTimer.stopSong()
