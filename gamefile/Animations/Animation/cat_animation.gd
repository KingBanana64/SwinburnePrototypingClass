extends Node2D

var animals = []
var sfx

func _ready() -> void:
	for child in get_children():
		animals.append(child)
	
	sfx = {
	"call": load("res://songs/sfx/catMeow.wav"),
	"pet" : load("res://songs/sfx/dogBark.wav"),
	"fail": load("res://songs/sfx/birdChirp.wav")
	}

func AnimalAnimation(no, type):
	var animationPlayer: AnimationPlayer = animals[no].get_node("animalPlayer")
	animationPlayer.stop()
	animationPlayer.play(type)
	
	animals[no].get_node("SFXPlayer").stream = sfx[type]
	animals[no].get_node("SFXPlayer").play()

## bop
func _on_bpm_timeout() -> void:
	for animal in animals:
		if not animal.get_node("animalPlayer").is_playing():
			animal.get_node("animalPlayer").play("bop")
