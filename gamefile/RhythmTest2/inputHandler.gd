extends Node2D

@onready var song = $Song
@onready var timer = $SongLength

## delay of hitting buttons on time
var delay = 0.5

var animal_queue = []
var input_queue = []

func _process(delta: float) -> void:
	
	if input_queue.size() > 0: 
		var time_passed = timer.wait_time - timer.time_left
		
		## If next input has passed current time, pop and indicate fail
		#if input_queue.front() > (time_passed + delay):
		#	input_queue.pop_front()
		#	print("KEY PASSED")
		
		## If Input pressed and input is close enough to current time, pop & indicate sucsess
		if Input.is_action_just_pressed("tap"):
			if input_queue.front() < (time_passed - delay):
				input_queue.pop_front()
				print("KEY HIT")
			else:
				print("BAD INPUT")

## When song finishes
func _on_song_length_timeout() -> void:
	pass 


func organise_inputs(double_arr):
	animal_queue = (double_arr[0])
	input_queue = (double_arr[1])
