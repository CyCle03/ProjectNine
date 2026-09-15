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

