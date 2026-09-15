extends Control
const API_BASE := "https://nine.elcherlab.com"

const POSITION_NAMES := {"P": "투수", "C": "포수", "1B": "1루", "2B": "2루", "3B": "3루", "SS": "유격", "LF": "좌익", "CF": "중견", "RF": "우익"}
var team: Team
var roster_container: VBoxContainer
var detail: PlayerDetail
var sync_label: Label
var api_request: HTTPRequest
var request_mode := ""

func _ready() -> void:
	team = PlayerGenerator.new().create_test_team()
	_build_ui()
	_populate_roster()
	_sync_remote_team()

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
	subtitle.text = "고교야구 감독/육성 시뮬레이션 · v0.1"
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("aebdce"))
	page.add_child(subtitle)
	var team_label := Label.new()
	team_label.text = "%s · 선수 %d명" % [team.team_name, team.roster_size()]
	team_label.add_theme_font_size_override("font_size", 21)
	page.add_child(team_label)
	var guide := Label.new()
	guide.text = "지금 할 수 있는 것: 선수 이름을 터치해 능력치와 성장 가능성을 확인하세요."
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 16)
	guide.add_theme_color_override("font_color", Color("aebdce"))
	page.add_child(guide)
	sync_label = Label.new()
	sync_label.text = "데이터 상태: 로컬 선수단"
	sync_label.add_theme_color_override("font_color", Color("8fb7e8"))
	page.add_child(sync_label)
	var roster_heading := Label.new()
	roster_heading.text = "선수단 명단"
	roster_heading.add_theme_font_size_override("font_size", 20)
	page.add_child(roster_heading)
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
	api_request = HTTPRequest.new()
	api_request.request_completed.connect(_on_api_completed)
	add_child(api_request)

func _populate_roster() -> void:
	for child in roster_container.get_children(): child.queue_free()
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

func _sync_remote_team() -> void:
	request_mode = "load"
	api_request.request(API_BASE + "/api/save")

func _on_api_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200: return
	var payload: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (payload is Dictionary): return
	if request_mode == "load":
		var data: Variant = payload.get("data", null)
		if data is Dictionary and data.has("team"):
			team = Team.from_dict(data["team"])
			_populate_roster()
			sync_label.text = "데이터 상태: 계정 선수단을 불러왔습니다"
		else:
			request_mode = "save"
			api_request.request(API_BASE + "/api/save", ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify({"team": team.to_dict()}))
	elif request_mode == "save":
		sync_label.text = "데이터 상태: 계정에 선수단을 저장했습니다"
