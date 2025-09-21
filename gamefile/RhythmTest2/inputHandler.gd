extends Node2D

@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor

## delay window for judging hits (±delay)
var delay: float = 0.15
var time_passed: float
var animal_queue = [[]]
var input_queue = [[]]

func _process(_delta: float) -> void:
	time_passed = timer.wait_time - timer.time_left

	## ----------------- INPUTS - PASS -----------------
	for ii in range(input_queue.size()):
		if input_queue[ii].size() == 0:
			continue
		var evt = input_queue[ii].front()
		var evt_time: float = _event_time(evt)   ## taps: t, holds: start
		## If next input has passed the late boundary, pop and miss
		if evt_time < (time_passed - delay):
			input_queue[ii].pop_front()
			print("KEY PASSED " + str(ii))

	## ----------------- ANIMALS - CALL ----------------
	for ia in range(animal_queue.size()):
		if animal_queue[ia].size() == 0:
			continue
		if animal_queue[ia].front() < time_passed:
			print("BARK " + str(ia))
			animal_queue[ia].pop_front()

## called by hitbox_detection.gd
func animalPetCheck(child:int, ClickDown: bool) -> void:
	## ----------------- INPUTS - HITS -----------------
	if input_queue.size() == 0:
		return
	if child < 0 or child >= input_queue.size():
		return
	if input_queue[child].size() == 0:
		return

	var evt = input_queue[child].front()
	var evt_time: float = _event_time(evt)

	## inside window → HIT
	if abs(evt_time - time_passed) <= delay:
		input_queue[child].pop_front()
		## optional: show tap vs hold
		if evt is Array and evt.size() == 2:
			print("KEY HIT (HOLD) " + str(child))
		else:
			print("KEY HIT " + str(child))
	else:
		print("BAD INPUT " + str(child))

## helper: get the 'hit time' of an event (tap=float, hold=[start,end])
func _event_time(evt) -> float:
	if evt is Array:
		if evt.size() >= 1:
			return float(evt[0])   ## use hold start time for judging
		return 0.0
	return float(evt)

## called by level_editor.gd in _ready()
func organise_inputs(all_arr: Array) -> void:
	## ensure queues can hold all lanes
	while all_arr.size() > animal_queue.size():
		animal_queue.append([])
		input_queue.append([])

	## assign arrays per lane: [barks[], taps/holds[]]
	for i in range(all_arr.size()):
		var arr = all_arr[i]
		animal_queue[i] = arr[0]
		input_queue[i]  = arr[1]

## When song finishes
func _on_song_length_timeout() -> void:
	levelEditor.finish()
	print("SONG DONE")
