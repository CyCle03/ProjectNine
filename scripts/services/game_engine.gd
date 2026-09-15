class_name GameEngine
extends RefCounted

const BALANCE_PATH := "res://data/game_balance.json"

var rng := RandomNumberGenerator.new()
var balance: Dictionary
var batting_indices := {}

func _init(seed_value: int = 0) -> void:
	balance = _load_balance()
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value

func simulate_game(away: Team, home: Team) -> Dictionary:
	batting_indices = {away: 0, home: 0}
	var state := GameState.new()
	for inning in range(1, 13):
		state.add_half_inning(true, _play_half_inning(away, home))
		state.add_half_inning(false, _play_half_inning(home, away))
		if inning >= 9 and state.away_score != state.home_score:
			break
	var result := state.to_dict()
	result["away_name"] = away.team_name
	result["home_name"] = home.team_name
	result["winner"] = away.team_name if state.away_score > state.home_score else home.team_name if state.home_score > state.away_score else "무승부"
	return result

func _play_half_inning(batting: Team, defending: Team) -> int:
	var order := batting.batting_order if batting.batting_order.size() == Team.LINEUP_SIZE else batting.default_batting_order()
	if order.is_empty():
		return 0
	var pitcher := _starting_pitcher(defending)
	var bases: Array[bool] = [false, false, false]
	var outs := 0
	var runs := 0
	var index := int(batting_indices.get(batting, 0))
	while outs < 3:
		var batter := batting.get_player(order[index % order.size()])
		index += 1
		if batter == null:
			outs += 1
			continue
		match _at_bat(batter, pitcher):
			"K", "OUT": outs += 1
			"BB": runs += _advance_walk(bases)
			"1B": runs += _advance_hit(bases, 1)
			"2B": runs += _advance_hit(bases, 2)
			"3B": runs += _advance_hit(bases, 3)
			"HR":
				runs += 1
				for occupied in bases:
					if occupied: runs += 1
				bases = [false, false, false]
	batting_indices[batting] = index % order.size()
	return runs

func _at_bat(batter: Player, pitcher: Player) -> String:
	var pitcher_stuff := pitcher.stuff if pitcher != null else 50
	var pitcher_control := pitcher.control if pitcher != null else 50
	var strikeout := _clamp_probability(float(balance.get("strikeout_base", 0.16)) + (pitcher_stuff - batter.contact) * 0.002)
	var walk := _clamp_probability(float(balance.get("walk_base", 0.08)) + (batter.eye - pitcher_control) * 0.002)
	var homerun := _clamp_probability(float(balance.get("home_run_base", 0.025)) + (batter.power - pitcher_stuff) * 0.0012)
	var hit := _clamp_probability(float(balance.get("hit_base", 0.20)) + (batter.contact - pitcher_control) * 0.002)
	var roll := rng.randf()
	if roll < strikeout: return "K"
	if roll < strikeout + walk: return "BB"
	if roll < strikeout + walk + homerun: return "HR"
	if roll < strikeout + walk + homerun + hit:
		var extra_roll := rng.randf()
		return "3B" if extra_roll < 0.03 else "2B" if extra_roll < 0.20 else "1B"
	return "OUT"

func _advance_walk(bases: Array[bool]) -> int:
	var runs := 0
	if bases[0] and bases[1] and bases[2]: runs += 1
	if bases[0] and bases[1]: bases[2] = true
	if bases[0]: bases[1] = true
	bases[0] = true
	return runs

func _advance_hit(bases: Array[bool], bases_taken: int) -> int:
	var runs := 0
	for index in range(2, -1, -1):
		if not bases[index]: continue
		var destination := index + bases_taken
		if destination >= 3: runs += 1
		else: bases[destination] = true
		bases[index] = false
	bases[bases_taken - 1] = true
	return runs

func _starting_pitcher(team: Team) -> Player:
	var pitchers := team.get_players_by_position("P")
	pitchers.sort_custom(func(a: Player, b: Player): return a.overall() > b.overall())
	return pitchers[0] if not pitchers.is_empty() else null

func _clamp_probability(value: float) -> float:
	return clampf(value, float(balance.get("min_probability", 0.01)), float(balance.get("max_probability", 0.45)))

func _load_balance() -> Dictionary:
	var file := FileAccess.open(BALANCE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text()) if file != null else {}
	return parsed if parsed is Dictionary else {}
