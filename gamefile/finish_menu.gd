extends Control

@onready var textContainer : RichTextLabel = $TextBox



func updateScore(score: int):
	textContainer.text = "[center]LEVEL COMPLETE! \nScore: " + str(score)+"%"



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
