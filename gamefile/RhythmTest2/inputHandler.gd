extends Node2D

@onready var song = $Song
@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor

## delay of hitting buttons on time
var delay = 0.2
var time_passed
var animal_queue1 = []
var animal_queue2 = []
var animal_queue3 = []
var input_queue1 = []
var input_queue2 = []
var input_queue3 = []

func _process(delta: float) -> void:
	
	time_passed = timer.wait_time - timer.time_left
	
	## ----------------- INPUTS -----------------
	if input_queue1.size() > 0: 
		## If next input has passed current time, pop and indicate fail
		if input_queue1.front() < (time_passed - delay):
			input_queue1.pop_front()
			print("KEY PASSED")
		
		## If Input pressed and input is close enough to current time, pop & indicate sucsess
		if Input.is_action_just_pressed("tap"):
			## !!FIX!! add animal collisions here
			if input_queue1.front() < (time_passed + delay):
				input_queue1.pop_front()
				print("KEY HIT")
			else:
				print("BAD INPUT")
	
	## ----------------- ANIMALS ----------------
	if animal_queue1.size() > 0:
		if animal_queue1.front() < time_passed:
			print("BARK")
			animal_queue1.pop_front()
		pass

## When song finishes
func _on_song_length_timeout() -> void:
	levelEditor.finish()
	print("SONG DONE")


func organise_inputs(complex_arr, animal_number):
	animal_queue1 = (complex_arr[0])
	input_queue1 = (complex_arr[1])
	if animal_number == 2:
		animal_queue2 = (complex_arr[2])
		input_queue2 = (complex_arr[3])
	elif animal_number == 3:
		animal_queue3 = (complex_arr[4])
		input_queue3 = (complex_arr[5])
