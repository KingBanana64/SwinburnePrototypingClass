# res://RhythmTest2/background.gd
extends Sprite2D

@export var score_node_path: NodePath
@export var tween_secs: float = 0.25

# hit-rate thresholds (%)
@export var sparkle_min_pct: float = 50.0
@export var hearts_min_pct: float  = 70.0

# band colors
@export var col_plain: Color  = Color(1,1,1,1)
@export var col_lt20: Color   = Color(0.55,0.55,0.55,1)
@export var col_20_50: Color  = Color8(255,196,0,255)
@export var col_50_70: Color  = Color8(255,128,171,255)
@export var col_70_100: Color = Color8(255,102,178,255)

# particle nodes (set via Inspector!)
@export var hearts_path: NodePath
@export var sparkles_path: NodePath

@onready var score_node: Node = get_node_or_null(score_node_path)
@onready var hearts_node: Node = get_node_or_null(hearts_path)
@onready var sparkles_node: Node = get_node_or_null(sparkles_path)

var tw: Tween = null

func _ready() -> void:
	modulate = col_plain

	if score_node == null:
		push_error("background.gd: score_node_path not set or node not found.")
	else:
		if score_node.has_signal("score_changed"):
			score_node.connect("score_changed", Callable(self, "_on_score_changed"))

	# layer order (adjust to taste)
	_set_canvas_item_z(sparkles_node, 4)
	_set_canvas_item_z(hearts_node, 2)

	# start hidden; script will toggle by thresholds
	_set_visible_ci(sparkles_node, false)
	_set_visible_ci(hearts_node, false)

	_apply_from_state()

func _on_score_changed(_s: float) -> void:
	_apply_from_state()

func _apply_from_state() -> void:
	# if score node missing, keep plain + FX off (prevents int(null) crash)
	if score_node == null:
		_set_tint(col_plain)
		_set_fx(false, false, 0.0, 0.0)
		return

	# SAFE reads (no int()/float() on null)
	var nt_v = score_node.get("noteTotal")
	var sc_v = score_node.get("score")

	var nt: int = 0
	var sc: float = 0.0
	if typeof(nt_v) == TYPE_INT: nt = nt_v
	elif typeof(nt_v) == TYPE_FLOAT: nt = int(nt_v)

	if typeof(sc_v) == TYPE_FLOAT: sc = sc_v
	elif typeof(sc_v) == TYPE_INT: sc = float(sc_v)

	# before notes: plain + off
	if nt <= 0:
		_set_tint(col_plain)
		_set_fx(false, false, 0.0, 0.0)
		return

	var hit: float = clamp((sc / float(nt)) * 100.0, 0.0, 100.0)
	_set_tint(_color_for_hit(hit))

	# thresholds → sparkles first, then hearts
	if hit < sparkle_min_pct:
		_set_fx(false, false, 0.0, 0.0)
	elif hit < hearts_min_pct:
		var denom: float = max(1.0, float(hearts_min_pct - sparkle_min_pct))
		var s_int: float = clamp((hit - sparkle_min_pct) / denom, 0.0, 1.0)
		_set_fx(true, false, s_int, 0.0)   # sparkles only
	else:
		var denom2: float = max(1.0, float(100.0 - hearts_min_pct))
		var both: float = clamp((hit - hearts_min_pct) / denom2, 0.0, 1.0)
		_set_fx(true, true, both, both)    # sparkles + hearts

func _color_for_hit(hit: float) -> Color:
	if hit < 20.0: return col_lt20
	elif hit < 50.0: return col_20_50
	elif hit < 70.0: return col_50_70
	else: return col_70_100

func _set_tint(c: Color) -> void:
	if tw != null and tw.is_running(): tw.kill()
	tw = create_tween()
	tw.tween_property(self, "modulate", c, tween_secs)

# spark_on, hearts_on, sparkles_intensity, hearts_intensity (0..1)
func _set_fx(spark_on: bool, hearts_on: bool, s_k: float, h_k: float) -> void:
	# sparkles
	if sparkles_node != null:
		_set_visible_ci(sparkles_node, spark_on)
		if sparkles_node is GPUParticles2D:
			var sp: GPUParticles2D = sparkles_node as GPUParticles2D
			sp.emitting = spark_on
			sp.amount = int(round(lerp(50.0, 180.0, s_k)))
			sp.speed_scale = lerp(1.0, 1.6, s_k)
			sp.restart()
		elif sparkles_node is CPUParticles2D:
			var spc: CPUParticles2D = sparkles_node as CPUParticles2D
			spc.emitting = spark_on
			spc.amount = int(round(lerp(50.0, 180.0, s_k)))
			spc.speed_scale = lerp(1.0, 1.6, s_k)
			spc.restart()

	# hearts
	if hearts_node != null:
		_set_visible_ci(hearts_node, hearts_on)
		if hearts_node is GPUParticles2D:
			var hp: GPUParticles2D = hearts_node as GPUParticles2D
			hp.emitting = hearts_on
			hp.amount = int(round(lerp(40.0, 140.0, h_k)))
			hp.speed_scale = lerp(0.9, 1.4, h_k)
			hp.restart()
		elif hearts_node is CPUParticles2D:
			var hpc: CPUParticles2D = hearts_node as CPUParticles2D
			hpc.emitting = hearts_on
			hpc.amount = int(round(lerp(40.0, 140.0, h_k)))
			hpc.speed_scale = lerp(0.9, 1.4, h_k)
			hpc.restart()

# helpers
func _set_canvas_item_z(n: Node, z: int) -> void:
	if n != null and n is CanvasItem:
		var ci: CanvasItem = n as CanvasItem
		ci.z_as_relative = false
		ci.z_index = z

func _set_visible_ci(n: Node, v: bool) -> void:
	if n != null and n is CanvasItem:
		(n as CanvasItem).visible = v
