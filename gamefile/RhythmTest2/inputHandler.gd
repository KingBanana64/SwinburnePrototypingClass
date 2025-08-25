extends Node2D

@onready var song = $Song
@onready var timer = $SongLength

func _process(delta: float) -> void:
	print(timer.time_left)

## When song finishes
func _on_song_length_timeout() -> void:
	pass 
