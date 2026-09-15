class_name PlayerGenerator
extends RefCounted

const CONFIG_PATH := "res://data/player_generation.json"

var rng := RandomNumberGenerator.new()
var config: Dictionary


func _init(seed_value: int = 0) -> void:
	config = _load_config()
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value


func create_test_team() -> Team:
	var team := Team.new(str(config.get("school_name", "테스트 고등학교")))
	var count := rng.randi_range(int(config.get("roster_min", 18)), int(config.get("roster_max", 25)))
	for index in count:
		team.add_player(create_player(index))
	return team


func create_player(index: int = 0) -> Player:
	var position := _weighted_position()
	var minimum := int(config.get("attribute_min", 35))
	var maximum := int(config.get("attribute_max", 78))
	var data := {"id": "%d-%03d" % [Time.get_unix_time_from_system(), index], "player_name": _random_name(), "grade": rng.randi_range(1, 3), "primary_position": position, "bats": "L" if rng.randf() < 0.28 else "R", "throws": "L" if rng.randf() < 0.18 else "R", "condition": rng.randi_range(65, 100), "fatigue": rng.randi_range(0, 20), "potential": rng.randi_range(int(config.get("potential_min", 55)), int(config.get("potential_max", 95))), "growth_rate": rng.randf_range(float(config.get("growth_rate_min", 0.8)), float(config.get("growth_rate_max", 1.3)))}
	for key in ["contact", "power", "eye", "speed", "fielding", "arm", "velocity", "stuff", "control", "breaking", "stamina"]:
		data[key] = rng.randi_range(minimum, maximum)
	return Player.new(data)


func _random_name() -> String:
	var last_names: Array = config.get("last_names", ["김"])
	var first_names: Array = config.get("first_names", ["민준"])
	return str(last_names[rng.randi_range(0, last_names.size() - 1)]) + str(first_names[rng.randi_range(0, first_names.size() - 1)])


func _weighted_position() -> String:
	var positions: Array = config.get("positions", ["P"])
	var weights: Array = config.get("position_weights", [1.0])
	var roll := rng.randf()
	var cumulative := 0.0
	for index in positions.size():
		cumulative += float(weights[index])
		if roll <= cumulative:
			return str(positions[index])
	return str(positions.back())


func _load_config() -> Dictionary:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("Player generation config not found")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

