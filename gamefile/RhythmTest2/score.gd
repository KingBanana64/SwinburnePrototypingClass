extends Node2D
signal score_changed(new_score: float)

var score: float = 0.0
var scoreTotal: int = 0




func _ready() -> void:
    emit_signal("score_changed", score) 


func update(value: String) -> void:
    match value:
        "bad":
            score -= 1.0
        "held":
            score += 2.0
        "pet":
            score += 4.0
        "miss":
            score -= 1.0
        _:
            return
    emit_signal("score_changed", score)


func calculateTotalScore(arrayHits: Array):
    for animalArray in arrayHits:
        for hit in animalArray:
            if typeof(hit) == TYPE_ARRAY:
                scoreTotal += 6
            else:
                scoreTotal += 4


func totalScore() -> void:
    var hitRate: float = clamp((score / scoreTotal) * 100,0.0,100.0)
    print("-----\nFINAL SCORE:\n" + str("%0.2f" % hitRate)  + "%\n-----")
