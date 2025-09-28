extends Timer

#@onready var song = get_parent().get_node("Song")
@export var song: AudioStreamPlayer2D
@export var bpmTimer: Timer

## Called by level_editor.gd in _ready()
## to attempt to sync up the game nicely
func start_song(songTitle, bpm = 0):
	var music = load("res://songs/"+songTitle+".mp3")
	if song.stream == null:
		print("BUG: No stream in Music player found")
		return
	song.stream = music
	wait_time = song.stream.get_length()
	
	## translate bpm to bps
	if bpm > 0:
		var bps = (60.00/bpm) 
		bpmTimer.wait_time = bps
	
	bpmTimer.start()
	start()
	song.play()


func stopSong():
	bpmTimer.stop()
