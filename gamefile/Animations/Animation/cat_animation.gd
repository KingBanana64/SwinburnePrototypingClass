extends Node2D

var animals = []
var sfx

func _ready() -> void:
	for child in get_children():
		animals.append(child)
	
	sfx = {
	"call": load("res://songs/sfx/catMeow.wav"),
	"call_start" : load("res://songs/sfx/longMeowStartTest.wav"), ## long notes start | PLACEHOLDER
	"call_end" : load("res://songs/sfx/longMeowEndTest.wav"), ## long notes End       | PLACEHOLDER
	"pet" : load("res://songs/sfx/dogBark.wav"),
	"pet_start" : load("res://songs/sfx/longMeowStartTest.wav"), ## long notes start
	"pet_end" : load("res://songs/sfx/longMeowEndTest.wav"), ## long notes End
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
