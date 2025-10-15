extends Node2D

var animals = []
var sfx = {
	"call": load("res://songs/sfx/catMeow.wav"),
	"call_start" : load("res://songs/sfx/longMeowStartTest.wav"), ## long notes start	| PLACEHOLDER
	"call_end" : load("res://songs/sfx/longMeowEndTest.wav"), ## long notes End		| PLACEHOLDER
	"pet" : load("res://songs/sfx/dogBark.wav"),									##	| PLACEHOLDER
	"pet_start" : load("res://songs/sfx/longMeowStartTest.wav"), ## long notes start ##|PLACEHOLDER
	"pet_end" : load("res://songs/sfx/longMeowEndTest.wav"), ## long notes End		##	| PLACEHOLDER
	"fail": load("res://songs/sfx/birdChirp.wav"),								##	| PLACEHOLDER
	#"arrive": load("res://songs/sfx/birdChirp.wav"),								##	| PLACEHOLDER
	#"leave": load("res://songs/sfx/birdChirp.wav")								##	| PLACEHOLDER
	}

func _ready() -> void:
	## defines children
	for child in get_children():
		animals.append(child)

## Sets the child of the head animation node to animate specific sprite
func AnimalAnimation(no, type):
	## validity check for animation
	if animals[no] == null:
		print("ANIMAL ANIMATION FAILED: No Valid Child")
		return
	
	var animationPlayer: AnimationPlayer = animals[no].get_node("animalPlayer")
	animationPlayer.stop()
	animationPlayer.play(type)
	
	## validity check for sfx
	if !(type in sfx):
		return
	
	animals[no].get_node("SFXPlayer").stream = sfx[type]
	animals[no].get_node("SFXPlayer").play()

## bop
func _on_bpm_timeout() -> void:
	for animal in animals:
		if not animal.get_node("animalPlayer").is_playing():
			animal.get_node("animalPlayer").play("bop")
