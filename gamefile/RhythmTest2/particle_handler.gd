extends Node2D

@onready var hitboxes = $"../AnimalAreas"

## Particle Node
var particle = load("res://RhythmTest2/ParticleSystem/particles.tscn")
var sprites = {
	"heart": load("res://RhythmTest2/ParticleSystem/paintHeart.png"),
	"sparkle": load("res://RhythmTest2/ParticleSystem/paintSpark.png")
}

func createParticle(type: String, location):
	
	var par = particle.instantiate()
	
	if type in sprites:
		par.texture = sprites[type]
	
	if typeof(location) == TYPE_VECTOR2:
		par.global_position = location
	elif typeof(location) == TYPE_INT:
		par.global_position = hitboxes.get_children()[location].global_position
	
	add_child(par)
	
	par.emitting = true


### Animals
#var animals = []
#func _ready():
	#var animalHitboxes = $"../AnimalAreas"
	#
	#for child in animalHitboxes.get_children():
		#animals.append(child)
