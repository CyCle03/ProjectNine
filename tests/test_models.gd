extends SceneTree

var failures := 0


func _init() -> void:
	var clamped := Player.new({"contact": 200, "power": -3})
	_check(clamped.contact == 100, "contact is clamped")
	_check(clamped.power == 1, "power is clamped")
	var pitcher := Player.new({"primary_position": "P", "velocity": 80, "stuff": 70, "control": 60, "breaking": 50, "stamina": 40})
	_check(pitcher.overall() == 60, "pitcher overall uses pitching stats")
	var team := PlayerGenerator.new(12345).create_test_team()
	_check(team.roster_size() >= 18 and team.roster_size() <= 25, "roster size is valid")
	for player in team.players:
		_check(player.grade >= 1 and player.grade <= 3, "grade is valid")
		_check(player.overall() >= 1 and player.overall() <= 100, "overall is valid")
	print("PASS: all model tests" if failures == 0 else "FAIL: %d test(s)" % failures)
	quit(failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: %s" % message)

