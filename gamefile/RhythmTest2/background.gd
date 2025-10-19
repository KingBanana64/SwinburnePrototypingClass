extends Sprite2D

@export var score_node_path: NodePath = "../Score"
@export var max_score: float = 100.0
@export_range(0.0, 1.0) var tint_strength: float = 0.6   # 0=no tint, 1=strong
@export_range(0.0, 1.0) var alpha: float = 0.85          # overall transparency
@export var tween_secs: float = 0.25                      # smoothness

@onready var score_node: Node = get_node(score_node_path)

func _ready() -> void:
	score_node.connect("score_changed", Callable(self, "_on_score_changed"))

func _on_score_changed(s: float) -> void:
	var t: float = clamp(s / max_score, 0.0, 1.0)
	var target: Color = _lovely_gradient(t)                      # gray→rose→pink
	var mixed: Color = target.lerp(Color(1, 1, 1, 1), 1.0 - tint_strength)
	mixed.a = alpha
	create_tween().tween_property(self, "modulate", mixed, tween_secs)

# Smooth gray -> rose -> pink using OKHSL for nicer tints
func _lovely_gradient(t: float) -> Color:
	var e: float = pow(t, 1.2)  # slight ease-in for slower early change

	# Key colors (OKHSL): gray, rose, vivid pink
	var gray:  Color = Color.from_ok_hsl(0.0, 0.0, 0.55)    # neutral gray
	var rose:  Color = Color.from_ok_hsl(0.97, 0.30, 0.65)  # gentle rose
	var pink:  Color = Color.from_ok_hsl(0.97, 0.75, 0.80)  # bright lovely pink

	if e < 0.5:
		var u: float = e / 0.5
		return gray.lerp(rose, u)
	else:
		var u2: float = (e - 0.5) / 0.5
		return rose.lerp(pink, u2)
