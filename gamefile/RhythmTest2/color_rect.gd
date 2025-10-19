extends ColorRect

@export var score_node_path: NodePath = "../../Score"  # ColorRect -> Background -> (up) -> Score
@export var max_score: float = 100.0
@export var use_hit_rate: bool = false

@onready var score_node: Score = get_node(score_node_path) as Score

func _ready() -> void:
	score_node.connect("score_changed", _on_score_changed)

func _on_score_changed(s: float) -> void:
	var t: float
	if use_hit_rate:
		var denom: float = max(1.0, float(score_node.noteTotal))
		t = clamp(s / denom, 0.0, 1.0)
	else:
		t = clamp(s / max_score, 0.0, 1.0)

	var col: Color = Color.from_ok_hsl(lerp(0.0, 0.33, t), 0.8, 0.6) # red→green
	create_tween().tween_property(self, "color", col, 0.25)
