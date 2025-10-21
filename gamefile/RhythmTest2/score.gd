extends Node2D
signal score_changed(new_score: float)

var score: float = 0.0
var noteTotal: int = 0

func _ready() -> void:
	emit_signal("score_changed", score) # let listeners init

func update(value: String) -> void:
	match value:
		"bad":
			score -= 1.0
			noteTotal += 1
		"held":
			score += 2.0
			noteTotal += 2
		"pet":
			score += 4.0
			noteTotal += 1
		"miss":
			score -= 1.0
			noteTotal += 1
		_:
			return
	emit_signal("score_changed", score)

func totalScore() -> void:
	var denom: float = max(1.0, float(noteTotal))
	var hitRate: float = clamp((score / denom) * 100.0, 0.0, 100.0)
	print("-----\nFINAL SCORE:\n" + str(hitRate) + "%\n-----")
