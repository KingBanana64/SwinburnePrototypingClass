extends Timer

@onready var song = $"../Song"

func _ready() -> void:
	start_song()

func start_song():
	if song.stream == null:
		print("BUG: No stream in Music player found")
		return
	wait_time = song.stream.get_length()
	song.play()
	start()
