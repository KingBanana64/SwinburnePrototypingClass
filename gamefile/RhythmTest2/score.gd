extends Node2D

var score: float
var noteTotal: int

## called upon throughout inputHandler.gd
func update(value):
	match value:
		
		"bad":
			score -= 1
			return
		"held":
			score += 2
			noteTotal += 2

		
		"pet":
			score += 4
		"miss":
			score -= 1

	# adds up total notes for scoring later
	noteTotal += 4

func totalScore():
	var hitRate = (score / noteTotal) * 100
	print("-----\nFINAL SCORE:\n" + str(hitRate) + "%\n-----")
