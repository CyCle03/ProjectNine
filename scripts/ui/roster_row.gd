class_name RosterRow
extends PanelContainer

signal selected(player: Player)
signal scroll_requested(delta_y: float)

const DRAG_THRESHOLD := 14.0

var player: Player
var press_position := Vector2.ZERO
var last_position := Vector2.ZERO
var dragging := false

func _ready() -> void:
	custom_minimum_size.y = 68
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_stylebox_override("panel", _make_row_style())
	gui_input.connect(_on_gui_input)

func setup(value: Player, position_name: String) -> void:
	player = value
	if not is_node_ready():
		await ready
	for child in get_children():
		child.queue_free()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)
	var label := Label.new()
	label.text = "%s   %d학년   %s   종합 %d" % [player.player_name, player.grade, position_name, player.overall()]
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 19)
	margin.add_child(label)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventScreenDrag:
		_handle_motion(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position, event.pressed)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_handle_motion(event.position)

func _handle_touch(position: Vector2, pressed: bool) -> void:
	if pressed:
		press_position = position
		last_position = position
		dragging = false
	else:
		if not dragging and player != null:
			selected.emit(player)
		press_position = Vector2.ZERO
		last_position = Vector2.ZERO
	accept_event()

func _handle_motion(position: Vector2) -> void:
	if press_position == Vector2.ZERO:
		return
	if not dragging and position.distance_to(press_position) >= DRAG_THRESHOLD:
		dragging = true
	if dragging:
		scroll_requested.emit(position.y - last_position.y)
	last_position = position
	accept_event()

func _make_row_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("171b22")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style
