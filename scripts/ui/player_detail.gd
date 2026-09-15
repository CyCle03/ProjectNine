class_name PlayerDetail
extends PanelContainer

signal closed

const POSITION_NAMES := {"P": "투수", "C": "포수", "1B": "1루수", "2B": "2루수", "3B": "3루수", "SS": "유격수", "LF": "좌익수", "CF": "중견수", "RF": "우익수"}

var title_label: Label
var info_label: Label
var stats_grid: GridContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	layout.add_child(title_label)
	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 19)
	layout.add_child(info_label)
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
	close_button.text = "선수단으로 돌아가기"
	close_button.custom_minimum_size.y = 56
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(func(): closed.emit())
	layout.add_child(close_button)


func show_player(player: Player) -> void:
	title_label.text = player.player_name
	info_label.text = "%d학년 · %s · %s투%s타 · 종합 %d" % [player.grade, POSITION_NAMES.get(player.primary_position, player.primary_position), _hand_name(player.throws), _hand_name(player.bats), player.overall()]
	for child in stats_grid.get_children():
		child.queue_free()
	_add_stat("컨디션", player.condition)
	_add_stat("피로도", player.fatigue)
	_add_stat("잠재력", player.potential)
	_add_stat("성장률", "%.2f" % player.growth_rate)
	if player.is_pitcher():
		for stat in [["구속", player.velocity], ["구위", player.stuff], ["제구", player.control], ["변화구", player.breaking], ["체력", player.stamina]]:
			_add_stat(stat[0], stat[1])
	else:
		for stat in [["컨택", player.contact], ["파워", player.power], ["선구안", player.eye], ["주력", player.speed], ["수비", player.fielding], ["송구", player.arm]]:
			_add_stat(stat[0], stat[1])


func _add_stat(label_text: String, value: Variant) -> void:
	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 20)
	stats_grid.add_child(name_label)
	var value_label := Label.new()
	value_label.text = str(value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 20)
	stats_grid.add_child(value_label)


func _hand_name(hand: String) -> String:
	return "좌" if hand == "L" else "우"

