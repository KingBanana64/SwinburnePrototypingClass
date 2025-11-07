extends Node2D
signal score_changed(new_score: float)

var score: float = 0.0
var scoreTotal: int = 0
var recent_ratings: Array = []   # last 5 hits, each 0.0–1.0

func _ready() -> void:
	emit_signal("score_changed", score)

func update(value: String) -> void:
	var delta: float = 0.0
	var rating: float = 0.0

	match value:
		"bad":
			delta = -1.0
			rating = 0.2
		"held":
			delta = 2.0
			rating = 0.7
		"pet":
			delta = 4.0
			rating = 1.0
		"miss":
			delta = -1.0
			rating = 0.0
		_:
			return

	score += delta

	recent_ratings.append(rating)
	if recent_ratings.size() > 5:
		recent_ratings.pop_front()

	emit_signal("score_changed", score)

func calculateTotalScore(arrayHits: Array) -> void:
	scoreTotal = 0
	for animalArray in arrayHits:
		for hit in animalArray:
			if typeof(hit) == TYPE_ARRAY:
				scoreTotal += 6
			else:
				scoreTotal += 4

func totalScore() -> void:
	var hitRate: float = 0.0
	if scoreTotal > 0:
		hitRate = clamp((score / float(scoreTotal)) * 100.0, 0.0, 100.0)
	print("-----\nFINAL SCORE:\n" + str("%0.2f" % hitRate)  + "%\n-----")

func giveScore() -> int:
	var hitRate: float = 0.0
	if scoreTotal > 0:
		hitRate = clamp((score / float(scoreTotal)) * 100, 0, 100)
		return hitRate
	else :
		return 0

func get_recent_percent() -> float:
	if recent_ratings.is_empty():
		return 0.0
	var sum: float = 0.0
	for r in recent_ratings:
		sum += float(r)
	return (sum / float(recent_ratings.size())) * 100.0
