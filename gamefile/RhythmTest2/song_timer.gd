extends Timer

@export var song = Node2D

## Called by level_editor.gd in _ready()
## to attempt to sync up the game nicely
func start_song(songTitle):
	var music = load("res://songs/"+songTitle+".mp3")
	song.stream = music
	if song.stream == null:
		print("BUG: No stream in Music player found")
		return
	wait_time = song.stream.get_length()
	song.play()
	start()
