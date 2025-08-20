extends Timer

@onready var song = $"../Song"

func _ready() -> void:
	if song.stream == null:
		return
	wait_time = song.stream.get_length()
	song.play()
	start()
