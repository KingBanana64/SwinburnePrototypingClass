extends Node2D

@onready var song = $Song
@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor

## delay of hitting buttons on time
var delay = 0.1
var time_passed
var animal_queue = []
var input_queue = []


func _process(delta: float) -> void:
	
	time_passed = timer.wait_time - timer.time_left
	
	## ----------------- INPUTS -----------------
	if input_queue.size() > 0: 
		## If next input has passed current time, pop and indicate fail
		if input_queue.front() < (time_passed - delay):
			#print("time passed: " + str(time_passed) + ". | input queue front: " + str(input_queue.front()))
			input_queue.pop_front()
			print("KEY PASSED")
		
		## If Input pressed and input is close enough to current time, pop & indicate sucsess
		if Input.is_action_just_pressed("tap"):
			if input_queue.front() < (time_passed + delay):
				input_queue.pop_front()
				print("KEY HIT")
			else:
				print("BAD INPUT")
	
	## ----------------- ANIMALS ----------------
	if animal_queue.size() > 0:
		if animal_queue.front() < time_passed:
			print("BARK")
			animal_queue.pop_front()
		pass

## When song finishes
func _on_song_length_timeout() -> void:
	levelEditor.finish()
	print("SONG DONE")


func organise_inputs(double_arr):
	animal_queue = (double_arr[0])
	input_queue = (double_arr[1])
