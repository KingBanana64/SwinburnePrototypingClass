extends Node2D

var animals = []

func _ready() -> void:
	for child in get_children():
		animals.append(child)

func AnimalAnimation(no, type):
	animals[no].get_child(0).play(type)
