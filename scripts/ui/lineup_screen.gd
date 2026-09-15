class_name LineupScreen
extends Control

signal saved(player_ids: Array[String])
signal closed

var team: Team
var selector_container: VBoxContainer
var error_label: Label
var selectors: Array[OptionButton] = []

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
	panel.offset_top = 44
	panel.offset_right = -18
	panel.offset_bottom = -28
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

	var title := Label.new()
	title.text = "선발 타순 구성"
	title.add_theme_font_size_override("font_size", 28)
	layout.add_child(title)
	var guide := Label.new()
	guide.text = "1~9번 타자를 선택하세요. 같은 선수는 한 번만 넣을 수 있습니다. 수비 위치와 경기 시뮬레이션은 다음 단계에서 추가됩니다."
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 15)
	guide.add_theme_color_override("font_color", Color("aebdce"))
	layout.add_child(guide)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	selector_container = VBoxContainer.new()
	selector_container.add_theme_constant_override("separation", 8)
	scroll.add_child(selector_container)

	error_label = Label.new()
	error_label.add_theme_font_size_override("font_size", 15)
	error_label.add_theme_color_override("font_color", Color("ffb4ab"))
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(error_label)

	var save_button := Button.new()
	save_button.text = "타순 확정"
	save_button.custom_minimum_size.y = 54
	save_button.add_theme_font_size_override("font_size", 18)
	save_button.pressed.connect(_save)
	layout.add_child(save_button)
	var close_button := Button.new()
	close_button.text = "취소"
	close_button.custom_minimum_size.y = 48
	close_button.pressed.connect(func(): closed.emit())
	layout.add_child(close_button)

func show_team(value: Team) -> void:
	team = value
	if not is_node_ready():
		await ready
	for child in selector_container.get_children():
		child.queue_free()
	selectors.clear()
	error_label.text = ""
	var order := team.batting_order if team.batting_order.size() == Team.LINEUP_SIZE else team.default_batting_order()
	for slot in Team.LINEUP_SIZE:
		_add_selector(slot, order[slot] if slot < order.size() else "")

func _add_selector(slot: int, selected_id: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	selector_container.add_child(row)
	var number := Label.new()
	number.text = "%d번" % (slot + 1)
	number.custom_minimum_size.x = 48
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number.add_theme_font_size_override("font_size", 18)
	row.add_child(number)
	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.custom_minimum_size.y = 46
	selector.add_theme_font_size_override("font_size", 17)
	for player in team.players:
		selector.add_item("%s · %s · 종합 %d" % [player.player_name, player.primary_position, player.overall()])
		selector.set_item_metadata(selector.item_count - 1, player.id)
		if player.id == selected_id:
			selector.select(selector.item_count - 1)
	row.add_child(selector)
	selectors.append(selector)

func _save() -> void:
	var ids: Array[String] = []
	for selector in selectors:
		ids.append(str(selector.get_item_metadata(selector.selected)))
	var unique_ids := {}
	for player_id in ids:
		if unique_ids.has(player_id):
			error_label.text = "같은 선수가 중복되었습니다. 각 타순에 다른 선수를 선택하세요."
			return
		unique_ids[player_id] = true
	saved.emit(ids)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("182432")
	style.border_color = Color("365778")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	return style
