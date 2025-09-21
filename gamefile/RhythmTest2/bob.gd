# IdleBob.gd — horizontal breathing only (bottom anchored, no vertical)
extends Node2D

@export var squish_amp: float = 0.1      # how much it squishes in/out
@export var bob_dur: float = 1.0
@export var random_delay: float = 0.0

var base_scale: Vector2
var tw: Tween

func _ready() -> void:
	base_scale = scale
	start_idle()

func start_idle() -> void:
	if tw: tw.kill()
	tw = create_tween().set_loops()
	if random_delay > 0.0:
		tw.tween_interval(randf() * random_delay)
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var sx_in: float = base_scale.x * (1.0 - squish_amp)
	var sx_out: float = base_scale.x * (1.0 + squish_amp)

	# squish in, then stretch out, repeat — no Y change
	tw.tween_property(self, "scale:x", sx_in, bob_dur)
	tw.tween_property(self, "scale:x", sx_out, bob_dur)
	tw.tween_property(self, "scale:x", base_scale.x, bob_dur)

func stop_idle() -> void:
	if tw: tw.kill()
	scale = base_scale
