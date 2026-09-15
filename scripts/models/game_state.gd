class_name GameState
extends RefCounted

var away_score := 0
var home_score := 0
var away_innings: Array[int] = []
var home_innings: Array[int] = []

func add_half_inning(is_away: bool, runs: int) -> void:
	if is_away:
		away_innings.append(runs)
		away_score += runs
	else:
		home_innings.append(runs)
		home_score += runs

func to_dict() -> Dictionary:
	return {"away_score": away_score, "home_score": home_score, "away_innings": away_innings, "home_innings": home_innings}
