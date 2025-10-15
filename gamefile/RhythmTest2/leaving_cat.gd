extends Node2D

@onready var sprite = $Animal
@onready var animationPlayer = $AnimationPlayer

## Load spritesheet from given argument into sprite

func catExit(animalColour: Texture, catPosition: Vector2):
	sprite.texture = animalColour
	global_position = catPosition
	animationPlayer.play("leave")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "leave":
		queue_free()
