extends Node2D

@onready var song = $Song
@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor

## delay of hitting buttons on time
var delay = 0.2
var time_passed
var animal_queue = []
var input_queue = []

func _process(delta: float) -> void:
	
	time_passed = timer.wait_time - timer.time_left
	
	## ----------------- INPUTS -----------------
	if input_queue.size() > 0: 
		var ii = 0
		for inp in input_queue:
			## If next input has passed current time, pop and indicate fail
			if inp.front() < (time_passed - delay):
				inp.pop_front()
				print("KEY PASSED " + ii)
			
			## If Input pressed and input is close enough to current time, pop & indicate sucsess
			if Input.is_action_just_pressed("tap"):
				## !!FIX!! add animal collisions here
				if inp.front() < (time_passed + delay):
					inp.pop_front()
					print("KEY HIT")
				else:
					print("BAD INPUT")
			ii += 1
	
	## ----------------- ANIMALS ----------------
	if animal_queue.size() > 0:
		var ia = 0
		for anim in animal_queue:
			if anim.front() < time_passed:
				print("BARK " + ia)
				anim.pop_front()
				ia += 1


## When song finishes
func _on_song_length_timeout() -> void:
	levelEditor.finish()
	print("SONG DONE")


func organise_inputs(all_arr):
	var i = 0
	for arr in all_arr:
		animal_queue[i] = (arr[0])
		input_queue[i] = (arr[1])
		i += 1
