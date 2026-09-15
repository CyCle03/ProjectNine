class_name MatchResultScreen
extends Control

signal closed

var score_label: Label
var inning_label: Label
var winner_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 10
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.08, 0.72)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_top = 130
	panel.offset_right = -18
	panel.offset_bottom = -130
	panel.add_theme_stylebox_override("panel", _style())
	add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var heading := Label.new()
	heading.text = "연습 경기 결과"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 20)
	layout.add_child(heading)
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 32)
	layout.add_child(score_label)
	winner_label = Label.new()
	winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_label.add_theme_font_size_override("font_size", 18)
	winner_label.add_theme_color_override("font_color", Color("8fb7e8"))
	layout.add_child(winner_label)
	inning_label = Label.new()
	inning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inning_label.add_theme_font_size_override("font_size", 16)
	layout.add_child(inning_label)
	var close_button := Button.new()
	close_button.text = "선수단으로 돌아가기"
	close_button.custom_minimum_size.y = 54
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.pressed.connect(func(): closed.emit())
	layout.add_child(close_button)

func show_result(result: Dictionary) -> void:
	score_label.text = "%s %d : %d %s" % [result.get("away_name", "원정"), result.get("away_score", 0), result.get("home_score", 0), result.get("home_name", "홈")]
	winner_label.text = "%s %s" % [result.get("winner", ""), "승리" if result.get("winner", "") != "무승부" else ""]
	inning_label.text = "이닝별 득점\n%s  %s\n%s  %s" % [result.get("away_name", "원정"), _scores(result.get("away_innings", [])), result.get("home_name", "홈"), _scores(result.get("home_innings", []))]

func _scores(values: Array) -> String:
	var text := ""
	for value in values:
		text += str(value) + " "
	return text.strip_edges()

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("182432")
	style.border_color = Color("365778")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	return style
