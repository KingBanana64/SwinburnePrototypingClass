# IdleBob.gd  (attach to the Sprite2D or Node2D you want to breathe)
extends Node2D

@export var bob_amp := 4.0        
@export var bob_dur := 1.0        
@export var squish_amp := 0.05    
@export var random_delay := 0.0   

var base_pos: Vector2
var base_scale: Vector2
var tw: Tween

func _ready():
	base_pos = position
	base_scale = scale
	start_idle()

func start_idle():
	if tw: tw.kill()
	tw = create_tween().set_loops()
	var s_up   = base_scale * Vector2(1.0 + squish_amp, 1.0 - squish_amp)
	if random_delay > 0.0: tw.tween_interval(randf() * random_delay)

	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# bob up
	tw.tween_property(self, "position:y", base_pos.y - bob_amp, bob_dur)
	tw.parallel().tween_property(self, "scale", s_up, bob_dur)
	# back to base
	tw.tween_property(self, "position:y", base_pos.y, bob_dur)
	tw.tween_property(self, "scale", base_scale, bob_dur)

func stop_idle():
	if tw: tw.kill()
	position = base_pos
	scale = base_scale
