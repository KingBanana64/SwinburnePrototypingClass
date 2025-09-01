extends Node2D

@onready var song = $Song
@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor

@onready var animationHitboxes = $AnimalAreas

## delay of hitting buttons on time
var delay = 0.2
var time_passed
var animal_queue = [[]]
var input_queue = [[]]

var EDIT_tap_keys = ["EDIT_Tap1","EDIT_Tap2","EDIT_Tap3",] ## If want more inputs, place here...


func _process(delta: float) -> void:
	
	time_passed = timer.wait_time - timer.time_left
	
	## ----------------- INPUTS -----------------
	if input_queue.size() > 0: 
		#for inp in input_queue:
		for ii in input_queue.size():
			## If next input has passed current time, pop and indicate fail
			if input_queue[ii].size() > 0:
				if input_queue[ii].front() < (time_passed - delay):
					input_queue[ii].pop_front()
					print("KEY PASSED " + str(ii))
				
				### If Input pressed and input is close enough to current time, pop & indicate sucsess
				### !!TEST!! Change this to tap and are clicked on for final
				#if Input.is_action_just_pressed(EDIT_tap_keys[ii]):
					### !!FIX!! add animal collisions here
					#if input_queue[ii].front() < (time_passed + delay):
						#input_queue[ii].pop_front()
						#print("KEY HIT " + str(ii))
					#else:
						#print("BAD INPUT " + str(ii))
	
	## ----------------- ANIMALS ----------------
	if animal_queue.size() > 0:
		for ia in animal_queue.size():
			if animal_queue[ia].size() > 0:
				if animal_queue[ia].front() < time_passed:
					print("BARK " + str(ia))
					animal_queue[ia].pop_front()


## When song finishes
func _on_song_length_timeout() -> void:
	levelEditor.finish()
	print("SONG DONE")

func animalPetCheck(child:int):
	
	## ----------------- INPUTS -----------------
	if input_queue.size() > 0: 
		if input_queue[child].size() > 0:
			if input_queue[child].front() < (time_passed + delay):
				input_queue[child].pop_front()
				print("KEY HIT " + str(child))
			else:
				print("BAD INPUT " + str(child))

func organise_inputs(all_arr):
	## makes sure the input and animal queues are large enough for the incomming animals
	## able to vary between 1 animal to theroetically infinite
	while all_arr.size() > animal_queue.size():
		animal_queue.append([])
		input_queue.append([])
	
	## assign each array to their respective queues.
	var i = 0
	for arr in all_arr:
		animal_queue[i] = (arr[0])
		input_queue[i] = (arr[1])
		i += 1
