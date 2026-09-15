class_name PlayerDetail
extends Control

signal closed

const POSITION_NAMES := {"P": "투수", "C": "포수", "1B": "1루수", "2B": "2루수", "3B": "3루수", "SS": "유격수", "LF": "좌익수", "CF": "중견수", "RF": "우익수"}

var title_label: Label
var info_label: Label
var stats_grid: GridContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 10
	mouse_filter = Control.MOUSE_FILTER_STOP

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.08, 0.72)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_top = 72
	panel.offset_right = -18
	panel.offset_bottom = -42
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var heading := Label.new()
	heading.text = "선수 상세"
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("8fb7e8"))
	layout.add_child(heading)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	layout.add_child(title_label)

	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 18)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(info_label)

	var guide := Label.new()
	guide.text = "능력치는 1~100 기준이며, 높을수록 좋습니다."
	guide.add_theme_font_size_override("font_size", 15)
	guide.add_theme_color_override("font_color", Color("aebdce"))
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(guide)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_grid.add_theme_constant_override("h_separation", 24)
	stats_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(stats_grid)

	var close_button := Button.new()
	close_button.text = "확인 · 선수단으로 돌아가기"
	close_button.custom_minimum_size.y = 56
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.pressed.connect(func(): closed.emit())
	layout.add_child(close_button)

func show_player(player: Player) -> void:
	title_label.text = player.player_name
	info_label.text = "%d학년 · %s · %s투%s타 · 종합 %d" % [player.grade, POSITION_NAMES.get(player.primary_position, player.primary_position), _hand_name(player.throws), _hand_name(player.bats), player.overall()]
	for child in stats_grid.get_children():
		child.queue_free()
	_add_section("기본 상태")
	_add_stat("컨디션", player.condition)
	_add_stat("피로도", player.fatigue)
	_add_stat("잠재력", player.potential)
	_add_stat("성장률", "%.2f" % player.growth_rate)
	_add_section("투수 능력치" if player.is_pitcher() else "야수 능력치")
	if player.is_pitcher():
		for stat in [["구속", player.velocity], ["구위", player.stuff], ["제구", player.control], ["변화구", player.breaking], ["체력", player.stamina]]:
			_add_stat(stat[0], stat[1])
	else:
		for stat in [["컨택", player.contact], ["파워", player.power], ["선구안", player.eye], ["주력", player.speed], ["수비", player.fielding], ["송구", player.arm]]:
			_add_stat(stat[0], stat[1])

func _add_section(section_text: String) -> void:
	var label := Label.new()
	label.text = section_text
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("8fb7e8"))
	stats_grid.add_child(label)
	var spacer := Control.new()
	stats_grid.add_child(spacer)

func _add_stat(label_text: String, value: Variant) -> void:
	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 19)
	stats_grid.add_child(name_label)
	var value_label := Label.new()
	value_label.text = str(value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 19)
	stats_grid.add_child(value_label)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("182432")
	style.border_color = Color("365778")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	return style

func _hand_name(hand: String) -> String:
	return "좌" if hand == "L" else "우"
