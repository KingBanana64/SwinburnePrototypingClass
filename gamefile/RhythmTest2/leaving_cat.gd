extends Node2D

@onready var sprite = $Animal
@onready var animationPlayer = $AnimationPlayer

## Load spritesheet from given argument into sprite

func catExit(animalColour: Texture, catPosition: Vector2):
	sprite.texture = animalColour
	global_position = catPosition
	animationPlayer.play("leave")
