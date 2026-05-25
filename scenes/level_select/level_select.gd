extends Control

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

@onready var _grid: GridContainer = $Background/Panel/Margin/VBox/Grid
@onready var _header: Label       = $Background/Panel/Margin/VBox/Header

func _ready() -> void:
	_header.add_theme_font_size_override("font_size", 12)

	for lvl in SaveSystem.LEVELS:
		_build_card(lvl)

func _build_card(lvl: Dictionary) -> void:
	var unlocked  := SaveSystem.is_unlocked(lvl["key"])
	var completed := SaveSystem.is_completed(lvl["key"])

	# Outer panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 60)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.18, 0.18) if unlocked else Color(0.10, 0.10, 0.10)
	sb.corner_radius_top_left    = 4
	sb.corner_radius_top_right   = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_top    = 8
	sb.content_margin_bottom = 8
	sb.content_margin_left   = 8
	sb.content_margin_right  = 8
	panel.add_theme_stylebox_override("panel", sb)

	# Inner VBox
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Status icon
	var status := Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_override("font", PIXEL_FONT)
	status.add_theme_font_size_override("font_size", 14)
	if completed:
		status.text = "✓"
		status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	elif unlocked:
		status.text = "▶"
		status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		status.text = "🔒"
		status.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	# Title
	var title := Label.new()
	title.text = lvl["title"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_override("font", PIXEL_FONT)
	title.add_theme_font_size_override("font_size", 8)
	if not unlocked:
		title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	vbox.add_child(status)
	vbox.add_child(title)
	panel.add_child(vbox)
	_grid.add_child(panel)

	# Click only if unlocked
	if unlocked:
		var btn := Button.new()
		btn.flat = true
		btn.anchor_right  = 1.0
		btn.anchor_bottom = 1.0
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		panel.add_child(btn)
		btn.pressed.connect(func(): _launch(lvl["key"]))

func _launch(key: String) -> void:
	SaveSystem.launch_level(key)
