extends Node2D

@export var spritesheet: CompressedTexture2D
@onready var sprite = $Animal

func _ready() -> void:
	sprite.texture = spritesheet
