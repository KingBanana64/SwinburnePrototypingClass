extends Node2D

@onready var sprite = $Animal
@onready var animationPlayer = $AnimationPlayer

var spritesheets = [
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_orange.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_white.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_black.png"),
	load("res://Animations/Sprites/Cats/spritesheets/spritesheet_naked.png")
]

## Load spritesheet from given argument into sprite

func catExit(animalColour: int):
	sprite.texture = spritesheets[animalColour]
	animationPlayer.play("leave")
