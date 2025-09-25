extends Node2D

var animals = []

func _ready() -> void:
	for child in get_children():
		animals.append(child)

func AnimalAnimation(no, type):
	var animationPlayer: AnimationPlayer = animals[no].get_node("animalPlayer")
	animationPlayer.stop()
	animationPlayer.play(type)
	if type == "call":
		animals[no].get_node("SFXPlayer").play()

## bop
func _on_bpm_timeout() -> void:
	for animal in animals:
		if not animal.get_node("animalPlayer").is_playing():
			animal.get_node("animalPlayer").play("bop")
