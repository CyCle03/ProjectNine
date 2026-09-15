extends Control

const POSITION_NAMES := {"P": "투수", "C": "포수", "1B": "1루", "2B": "2루", "3B": "3루", "SS": "유격", "LF": "좌익", "CF": "중견", "RF": "우익"}

var team: Team
var roster_container: VBoxContainer
var detail: PlayerDetail


func _ready() -> void:
	team = PlayerGenerator.new().create_test_team()
	_build_ui()
	_populate_roster()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("101824")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18 if side == "left" or side == "right" else 24)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)
	var title := Label.new()
	title.text = "PROJECT NINE"
	title.add_theme_font_size_override("font_size", 34)
	page.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "%s  ·  선수 %d명" % [team.team_name, team.roster_size()]
	subtitle.add_theme_font_size_override("font_size", 19)
	page.add_child(subtitle)
	var guide := Label.new()
	guide.text = "선수를 선택하면 상세 능력치를 확인할 수 있습니다."
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_color_override("font_color", Color("aebdce"))
	guide.add_theme_font_size_override("font_size", 16)
	page.add_child(guide)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(scroll)
	roster_container = VBoxContainer.new()
	roster_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_container.add_theme_constant_override("separation", 8)
	scroll.add_child(roster_container)
	detail = PlayerDetail.new()
	detail.visible = false
	detail.closed.connect(func(): detail.visible = false)
	add_child(detail)


func _populate_roster() -> void:
	var sorted_players := team.players.duplicate()
	sorted_players.sort_custom(func(a: Player, b: Player): return a.grade > b.grade if a.grade != b.grade else a.overall() > b.overall())
	for player: Player in sorted_players:
		var button := Button.new()
		button.custom_minimum_size.y = 68
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 19)
		button.text = "  %s   %d학년   %-2s   종합 %d" % [player.player_name, player.grade, POSITION_NAMES.get(player.primary_position, player.primary_position), player.overall()]
		button.pressed.connect(_open_detail.bind(player))
		roster_container.add_child(button)


func _open_detail(player: Player) -> void:
	detail.show_player(player)
	detail.visible = true

