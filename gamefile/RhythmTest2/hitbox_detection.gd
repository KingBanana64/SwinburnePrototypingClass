extends Area2D

@onready var InputHandler = get_node("/root/").get_child(0)

@export var key_name: String = "EDIT_Tap1"
@export var lane_label: String = ""          ## auto "BARK <index>" if blank
@export var DEBUG_ON_PRESS: bool = true      ## one-line reason when a press fails

var _notes: Array = []
var _unhit := {}
var _lane_index: int

func _ready() -> void:
	_lane_index = get_index()
	if lane_label == "":
		lane_label = "BARK " + str(_lane_index)

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed(key_name):
		### BUG : activates during edit mode
		#if _notes.size() == 0:
			#if DEBUG_ON_PRESS: print("NO NOTE IN BOX ", lane_label)
			#return
		### overlap-only: any note inside = HIT
		#var n = _notes[0]
		#print("KEY HIT ", lane_label)
		#_unhit.erase(n)
		#_notes.erase(n)
		#if is_instance_valid(n):
			#n.queue_free()

func _on_input_event(_vp: Node, event: InputEvent, _shape_idx: int) -> void:
	## If Mouse & Left button & CLick
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		returnPosition(true)

func returnPosition(ClickDown: bool):
	var i := 0
	for child in get_parent().get_children():
		if child.name == name:
			InputHandler.animalPetCheck(i, ClickDown)
		else:
			i += 1

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("note"):
		_notes.append(area)
		_unhit[area] = true

func _on_area_exited(area: Area2D) -> void:
	if _unhit.has(area):
		print("KEY MISSED ", lane_label)  ## leaves box without hit
		_unhit.erase(area)
	_notes.erase(area)
