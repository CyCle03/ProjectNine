class_name Team
extends RefCounted

const LINEUP_SIZE := 9

var team_name: String
var players: Array[Player] = []
var batting_order: Array[String] = []

func _init(name: String = "새 학교") -> void:
	team_name = name

func add_player(player: Player) -> void:
	if player != null:
		players.append(player)

func roster_size() -> int:
	return players.size()

func get_players_by_position(position: String) -> Array[Player]:
	var result: Array[Player] = []
	for player in players:
		if player.primary_position == position:
			result.append(player)
	return result

func get_player(player_id: String) -> Player:
	for player in players:
		if player.id == player_id:
			return player
	return null

func default_batting_order() -> Array[String]:
	var fielders: Array[Player] = []
	var pitchers: Array[Player] = []
	for player in players:
		if player.is_pitcher():
			pitchers.append(player)
		else:
			fielders.append(player)
	fielders.sort_custom(func(a: Player, b: Player): return _batting_score(a) > _batting_score(b))
	pitchers.sort_custom(func(a: Player, b: Player): return a.overall() > b.overall())
	var result: Array[String] = []
	for player in fielders:
		if result.size() >= LINEUP_SIZE - 1:
			break
		result.append(player.id)
	if not pitchers.is_empty():
		result.append(pitchers[0].id)
	for player in fielders + pitchers:
		if result.size() >= LINEUP_SIZE:
			break
		if not result.has(player.id):
			result.append(player.id)
	return result

func _batting_score(player: Player) -> float:
	var skill := player.contact * 0.42 + player.power * 0.25 + player.eye * 0.20 + player.speed * 0.13
	var readiness := clampf((player.condition - player.fatigue * 0.35) / 100.0, 0.5, 1.0)
	return skill * readiness

func set_batting_order(player_ids: Array[String]) -> bool:
	if player_ids.size() != LINEUP_SIZE:
		return false
	var unique_ids := {}
	for player_id in player_ids:
		if unique_ids.has(player_id) or get_player(player_id) == null:
			return false
		unique_ids[player_id] = true
	batting_order = player_ids.duplicate()
	return true

func to_dict() -> Dictionary:
	var data: Array[Dictionary] = []
	for player in players:
		data.append(player.to_dict())
	return {"team_name": team_name, "players": data, "batting_order": batting_order}

static func from_dict(data: Dictionary) -> Team:
	var team := Team.new(str(data.get("team_name", "새 학교")))
	for player_data in data.get("players", []):
		if player_data is Dictionary:
			team.add_player(Player.new(player_data))
	var saved_order: Array[String] = []
	for player_id in data.get("batting_order", []):
		saved_order.append(str(player_id))
	team.set_batting_order(saved_order)
	return team
