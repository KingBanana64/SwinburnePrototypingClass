extends Node2D
# Mouse holds: remembers the lane pressed, catches release globally.
# Prints PRESS/RELEASE prompts and timing deltas. Taps still work.

@onready var timer = $SongLength
@onready var levelEditor = $LevelEditor
@onready var animationHandler = $AnimalSprites
@onready var scoreHandler = $Score
@onready var particleHandler = $ParticleHandler
@onready var animalAreas = $AnimalAreas

var leavingCatScene = preload("res://RhythmTest2/leaving_cat.tscn")

var spritesheets = [
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_orange.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_white.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_black.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_naked.png")
]

# Same leniency for hold start & end
var delay: float = 0.6
const AUTO_FAIL_GRACE := 0.05  # helps avoid "no release" race by 50 ms

var last_time_passed: float = 0.0
var time_passed: float
var bpm: float

# per-lane queues
var animal_queue = [[]]
var input_queue  = [[]]
var swap_queue = [[]]

# hold state (per lane) — player input
var need_release := []     # true while a hold is active (waiting for release)
var hold_end     := []     # end time of the active hold; -1.0 if none

# NEW: hold state for ANIMAL (pets) — left bracket
var animal_hold_active := []   # per-lane: animal hold currently active
var animal_hold_end := []      # per-lane: end time for animal hold; -1.0 if none

# which lane started the mouse press (so we release the SAME lane even off hitbox)
var active_mouse_lane: int = -1

func _process(_delta: float) -> void:
	var prev := last_time_passed
	time_passed = timer.wait_time - timer.time_left

	# ----------------- INPUTS - PASS (late misses) -----------------
	for ii in range(input_queue.size()):
		if input_queue[ii].size() == 0: continue
		var evt = input_queue[ii].front()

		# If waiting for a hold release and the front is the END float, judge on key-up
		if need_release.size() > ii and need_release[ii] and typeof(evt) == TYPE_FLOAT:
			continue

		# Prompt: PRESS NOW for holds
		if evt is Array and evt.size() == 2:
			var start_t: float = float(evt[0])
			if prev < (start_t - delay) and time_passed >= (start_t - delay):
				print("PRESS NOW (hold @ %.3f)" % start_t)

		var evt_time := _event_time(evt)
		if evt_time < (time_passed - delay):
			input_queue[ii].pop_front()
			if evt is Array and evt.size() == 2:
				var miss_ms := int(round((time_passed - (evt_time + delay)) * 1000.0))
				print("hold missed (start) — missed by %d ms" % miss_ms)
			else:
				var miss_ms2 := int(round((time_passed - (evt_time + delay)) * 1000.0))
				print("tap passed — missed by %d ms" % miss_ms2)
			animationHandler.AnimalAnimation(ii, "fail")
			scoreHandler.update("miss")

	# -------- Auto-fail holds never released (with small grace) --------
	for lane in range(need_release.size()):
		if need_release[lane] and hold_end[lane] > 0.0 and time_passed > hold_end[lane] + delay + AUTO_FAIL_GRACE:
			var late_ms := int(round((time_passed - (hold_end[lane] + delay)) * 1000.0))
			print("hold missed (no release) — late by %d ms" % late_ms)
			need_release[lane] = false
			if input_queue[lane].size() > 0 and typeof(input_queue[lane].front()) == TYPE_FLOAT:
				input_queue[lane].pop_front()
			hold_end[lane] = -1.0
			animationHandler.AnimalAnimation(lane, "fail")
			scoreHandler.update("miss")

	# -------- Prompt: RELEASE NOW near end --------
	for lane in range(need_release.size()):
		if need_release[lane] and hold_end[lane] > 0.0:
			if prev < (hold_end[lane] - delay) and time_passed >= (hold_end[lane] - delay):
				print("RELEASE NOW (hold @ %.3f)" % hold_end[lane])

	# ----------------- ANIMALS - CALL (now supports holds) ----------------
	for ia in animal_queue.size():
		if animal_queue[ia].size() == 0: continue
		var av = animal_queue[ia].front()

		# If the animal event is a HOLD [start,end]
		if av is Array and av.size() == 2:
			var start_t: float = float(av[0])
			var end_t: float = float(av[1])
			# Start when we reach the start window (same early window style)
			if start_t <= time_passed + (delay/6):
				animal_queue[ia][0] = end_t  # replace with END float
				# mark active animal hold
				_ensure_animal_hold_arrays(ia)
				animal_hold_active[ia] = true
				animal_hold_end[ia] = end_t
				var dt_ms := int(round((time_passed - start_t) * 1000.0))
				print("ANIMAL HOLD START — target %.3f, actual %.3f, Δ %d ms" % [start_t, time_passed, dt_ms])
				animationHandler.AnimalAnimation(ia, "call_start")
			continue

		# If the animal event is a FLOAT
		if typeof(av) == TYPE_FLOAT:
			# End of an animal hold?
			if animal_hold_active.size() > ia and animal_hold_active[ia]:
				if av < time_passed + (delay/6):
					animal_queue[ia].pop_front()
					var dt_end_ms := int(round((time_passed - float(av)) * 1000.0))
					print("ANIMAL HOLD END — target %.3f, actual %.3f, Δ %d ms" % [float(av), time_passed, dt_end_ms])
					animal_hold_active[ia] = false
					animal_hold_end[ia] = -1.0
					animationHandler.AnimalAnimation(ia, "call_end")
				continue
			# Normal single animal call
			if av < time_passed + (delay/6):
				animal_queue[ia].pop_front()
				print("ANIMAL CALL @ %.3f" % float(av))
				animationHandler.AnimalAnimation(ia, "call")
	
	## ----------------- ANIMALS - SWAP ----------------
	for isw in swap_queue.size():
		if swap_queue[isw].is_empty(): continue
		## If swap time begins, begin swap
		if swap_queue[isw][0].front() < time_passed:
			print('SWAP CAT ' + str(isw))
			swap(swap_queue[isw][0].back(),isw)
			swap_queue[isw].pop_front()
	
	last_time_passed = time_passed

# Global mouse capture so release is never missed (even off the hitbox / UI)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			return
		if active_mouse_lane != -1 and active_mouse_lane < input_queue.size():
			if need_release.size() > active_mouse_lane and need_release[active_mouse_lane]:
				animalPetCheck(active_mouse_lane, false, event)
		active_mouse_lane = -1

## called by hitbox_detection.gd (or mouse)
## ClickDown: true on press, false on release
func animalPetCheck(child:int, ClickDown: bool, event: InputEvent = null) -> void:
	if input_queue.size() == 0: return
	if child < 0 or child >= input_queue.size(): return
	
	if ClickDown:
		active_mouse_lane = child
	
	if input_queue[child].size() == 0:
		if not ClickDown and need_release.size() > child and need_release[child]:
			need_release[child] = false
			hold_end[child] = -1.0
		return
	
	var evt = input_queue[child].front()
	var evt_time := _event_time(evt)
	
	# ---------- HOLD START (Array [start,end]) on PRESS ----------
	if evt is Array and evt.size() == 2 and ClickDown:
		var start_t: float = float(evt[0])
		var end_t: float   = float(evt[1])
		var dt := time_passed - start_t
		var dt_ms := int(round(dt * 1000.0))
		if abs(dt) <= delay:
			print("HOLD START — target %.3f, actual %.3f, Δ %d ms (HIT)" % [start_t, time_passed, dt_ms])
			input_queue[child][0] = end_t
			_ensure_hold_arrays(child)
			need_release[child] = true
			hold_end[child] = end_t
			scoreHandler.update("pet")
			animationHandler.AnimalAnimation(child, "pet_start")
		else:
			print("HOLD START — target %.3f, actual %.3f, Δ %d ms (MISS)" % [start_t, time_passed, dt_ms])
			animationHandler.AnimalAnimation(child, "fail")
			scoreHandler.update("bad")
		return
	
	# ---------- HOLD END (stored end float) on RELEASE ----------
	if not ClickDown and need_release.size() > child and need_release[child] and typeof(evt) == TYPE_FLOAT:
		var end_t: float = float(evt)
		var dt_end := time_passed - end_t
		var dt_end_ms := int(round(dt_end * 1000.0))
		if time_passed < end_t - delay:
			print("HOLD END — target %.3f, actual %.3f, Δ %d ms (LEFT EARLY)" % [end_t, time_passed, dt_end_ms])
			animationHandler.AnimalAnimation(child, "fail")
			scoreHandler.update("bad")
		elif abs(dt_end) <= delay:
			print("HOLD END — target %.3f, actual %.3f, Δ %d ms (COMPLETED)" % [end_t, time_passed, dt_end_ms])
			animationHandler.AnimalAnimation(child, "pet")
			scoreHandler.update("pet")
			particleHandler.createParticle("heart", child)
		else:
			print("HOLD END — target %.3f, actual %.3f, Δ %d ms (LATE)" % [end_t, time_passed, dt_end_ms])
			animationHandler.AnimalAnimation(child, "fail")
			scoreHandler.update("bad")
		input_queue[child].pop_front()
		need_release[child] = false
		hold_end[child] = -1.0
		return
	
	# ---------- TAP (single float) on PRESS (no active hold) ----------
	if ClickDown and typeof(evt) == TYPE_FLOAT and (need_release.size() <= child or not need_release[child]):
		var dt_tap := time_passed - evt_time
		if abs(dt_tap) <= delay:
			input_queue[child].pop_front()
			print("tap done")
			animationHandler.AnimalAnimation(child, "pet")
			scoreHandler.update("pet")
			particleHandler.createParticle("heart", event.global_position)
		else:
			animationHandler.AnimalAnimation(child, "fail")
			scoreHandler.update("bad")
		return

## Chris' code, for swap function
func swap(animalColour: int, animalNo: int):
	var currAnimal = $AnimalSprites.get_children()[animalNo]
	var leavingCat = leavingCatScene.instantiate()
	get_node("AnimalLeavingSprites").add_child(leavingCat)
	leavingCat.catExit(currAnimal.get_node("Animal").texture, currAnimal.global_position)
	var currSpritesheet = spritesheets[animalColour]
	currAnimal.get_node("Animal").texture = currSpritesheet
	animationHandler.AnimalAnimation(animalNo, "arrive")

# helper: get the 'hit time' of an event (tap=float, hold=[start,end])
func _event_time(evt) -> float:
	if evt is Array:
		if evt.size() >= 1:
			return float(evt[0])
		return 0.0
	return float(evt)

# called by level_editor.gd in _ready()
func organise_inputs(all_arr: Array, swap_arr: Array) -> void:
	## grow arrays to number of lanes
	while all_arr.size() > animal_queue.size():
		animal_queue.append([])
		input_queue.append([])
		## player hold state
		need_release.append(false)
		hold_end.append(-1.0)
		## NEW: animal hold state
		animal_hold_active.append(false)
		animal_hold_end.append(-1.0)
	
	## same for swap array
	while swap_arr.size() > swap_queue.size():
		swap_queue.append([])
	
	## assign per lane
	for i in range(all_arr.size()):
		var arr = all_arr[i]
		animal_queue[i] = arr[0]   # may now include Float or [start,end]
		input_queue[i]  = arr[1]
		if i >= need_release.size():
			need_release.append(false)
			hold_end.append(-1.0)
		else:
			need_release[i] = false
			hold_end[i] = -1.0
		# reset animal hold state too
		if i >= animal_hold_active.size():
			animal_hold_active.append(false)
			animal_hold_end.append(-1.0)
		else:
			animal_hold_active[i] = false
			animal_hold_end[i] = -1.0
	
	for i in swap_arr.size():
		swap_queue[i] = swap_arr[i]
		pass

func _on_song_length_timeout() -> void:
	levelEditor.finish()

func score():
	scoreHandler.totalScore()

func _ensure_hold_arrays(lane:int) -> void:
	while lane >= need_release.size():
		need_release.append(false)
		hold_end.append(-1.0)

func _ensure_animal_hold_arrays(lane:int) -> void:
	while lane >= animal_hold_active.size():
		animal_hold_active.append(false)
		animal_hold_end.append(-1.0)
