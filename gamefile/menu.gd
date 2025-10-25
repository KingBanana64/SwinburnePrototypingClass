extends Node2D

@onready var SongList: ItemList = $Control/PanelContainer/SongList

var SelectedSong: String

func _on_song_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	## Checks if clicking with left click button
	if (not mouse_button_index == 1):
		return
	
	SelectedSong = SongList.get_item_text(index)


func _on_start_pressed() -> void:
	if SelectedSong == "":
		## Get user to select a song
		print("Select a song")
		return
	
	globalVariables.SelectedSong = SelectedSong
	
	get_tree().change_scene_to_file("res://RhythmTest2/Test1.tscn")
