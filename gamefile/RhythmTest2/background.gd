extends Sprite2D

@export var score_node_path: NodePath
@export var min_brightness: float = 0.2      # darkest
@export var base_brightness: float = 0.8     # starting at 80 %
@export var smoothing_speed: float = 2.0     # higher = faster

var score_node: Node = null
var current_brightness: float = 0.8

func _ready() -> void:
	if score_node_path != NodePath(""):
		score_node = get_node_or_null(score_node_path)

	if score_node == null:
		var p: Node = get_parent()
		if p != null and p.has_node("Score"):
			score_node = p.get_node("Score")

	current_brightness = base_brightness
	modulate = Color(current_brightness, current_brightness, current_brightness, 1.0)

func _process(delta: float) -> void:
	_update_brightness(delta)

func _update_brightness(delta: float) -> void:
	if score_node == null:
		return

	var recent_percent: float = 0.0
	if score_node.has_method("get_recent_percent"):
		var val: Variant = score_node.call("get_recent_percent")
		if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
			recent_percent = float(val)

	recent_percent = clamp(recent_percent, 0.0, 100.0)

	var t: float = recent_percent / 100.0
	var target_brightness: float = lerp(min_brightness, 1.0, t)

	var alpha: float = clamp(smoothing_speed * delta, 0.0, 1.0)
	current_brightness = lerp(current_brightness, target_brightness, alpha)

	modulate = Color(current_brightness, current_brightness, current_brightness, 1.0)
