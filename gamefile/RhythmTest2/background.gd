# res://RhythmTest2/background.gd
extends Sprite2D

@export var score_node_path: NodePath
@export var tween_secs: float = 0.25

@export var min_brightness: float = 0.25

@onready var score_node: Node = get_node_or_null(score_node_path)
var tw: Tween = null

func _ready() -> void:
	modulate = Color(1,1,1,1)
	if score_node and score_node.has_signal("score_changed"):
		score_node.connect("score_changed", Callable(self, "_on_score_changed"))
	_apply_from_state()

func _on_score_changed(_s: float) -> void:
	_apply_from_state()

func _apply_from_state() -> void:
	if score_node == null:
		_set_tint(Color(1,1,1,1))
		return

	var nt_v = score_node.get("noteTotal")
	var sc_v = score_node.get("score")

	var nt: int = 0
	var sc: float = 0.0
	if typeof(nt_v) == TYPE_INT: nt = nt_v
	elif typeof(nt_v) == TYPE_FLOAT: nt = int(nt_v)

	if typeof(sc_v) == TYPE_FLOAT: sc = sc_v
	elif typeof(sc_v) == TYPE_INT: sc = float(sc_v)

	if nt <= 0:
		_set_tint(Color(1,1,1,1))
		return

	var hit: float = clamp((sc / float(nt)) * 100.0, 0.0, 100.0)
	_set_tint(_color_for_hit(hit))

func _color_for_hit(hit: float) -> Color:
	var t: float = clamp(hit / 100.0, 0.0, 1.0)

	t = pow(t, 0.8)
	var v: float = lerp(min_brightness, 1.0, t)

	return Color(v, v, v, 1.0)

func _set_tint(c: Color) -> void:
	if tw != null and tw.is_running():
		tw.kill()
	tw = create_tween()
	tw.tween_property(self, "modulate", c, tween_secs)
