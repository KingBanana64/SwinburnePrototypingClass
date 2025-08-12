extends Sprite2D
## Length for arrow to reach critical spot: 1.81575900000001 s

@export var fall_speed: float = 1.5

var init_y_pos: float = -363.0
var target_y_pos: float = 280.0 ## "passed_threshold" in tutorial

# True if passed input frames
var has_passed: bool = false

func _init():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += Vector2(0, fall_speed)
	
	if global_position.y > target_y_pos and not $Timer.is_stopped():
		has_passed = true

func Setup(target_x: float, target_frame: int):
	global_position = Vector2(target_x, init_y_pos)
	frame = target_frame
	set_process(true)


func _on_destroy_timer_timeout() -> void:
	queue_free()
