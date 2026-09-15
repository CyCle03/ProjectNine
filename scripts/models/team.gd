class_name Team
extends RefCounted

var team_name: String
var players: Array[Player] = []

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

func to_dict() -> Dictionary:
	var data: Array[Dictionary] = []
	for player in players:
		data.append(player.to_dict())
	return {"team_name": team_name, "players": data}

static func from_dict(data: Dictionary) -> Team:
	var team := Team.new(str(data.get("team_name", "새 학교")))
	for player_data in data.get("players", []):
		if player_data is Dictionary:
			team.add_player(Player.new(player_data))
	return team
