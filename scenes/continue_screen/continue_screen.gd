extends Control

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

@onready var _subtitle:     Label  = $Background/Center/Card/Subtitle
@onready var _btn_continue: Button = $Background/Center/Card/BtnContinue
@onready var _btn_new_game: Button = $Background/Center/Card/BtnNewGame

func _ready() -> void:
	# Apply pixel font everywhere
	for node in [$Background/Center/Card/Title, _subtitle, _btn_continue, _btn_new_game]:
		node.add_theme_font_override("font", PIXEL_FONT)

	for btn in [_btn_continue, _btn_new_game]:
		btn.add_theme_font_size_override("font_size", 10)
		_style_button(btn)

	$Background/Center/Card/Title.add_theme_font_size_override("font_size", 16)
	_subtitle.add_theme_font_size_override("font_size", 9)

	# Show the level the player will continue from
	var lvl := SaveSystem.get_continue_level()
	_subtitle.text = "Continuar: " + lvl["title"]

	_btn_continue.pressed.connect(_on_continue)
	_btn_new_game.pressed.connect(_on_new_game)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu/main_menu.tscn")

func _on_continue() -> void:
	var lvl := SaveSystem.get_continue_level()
	get_tree().change_scene_to_file(lvl["scene"])

func _on_new_game() -> void:
	SaveSystem.reset()
	get_tree().change_scene_to_file(
		SaveSystem.LEVELS[0]["scene"]
	)

func _style_button(btn: Button) -> void:
	var states  := ["normal", "hover", "pressed", "focus", "disabled"]
	var colors  := [Color(0.18,0.18,0.18), Color(0.30,0.30,0.30),
					Color(0.10,0.28,0.10), Color(0.18,0.18,0.18), Color(0.12,0.12,0.12)]
	for i in states.size():
		var sb := StyleBoxFlat.new()
		sb.bg_color = colors[i]
		sb.corner_radius_top_left    = 2
		sb.corner_radius_top_right   = 2
		sb.corner_radius_bottom_left = 2
		sb.corner_radius_bottom_right = 2
		sb.content_margin_top    = 4
		sb.content_margin_bottom = 4
		sb.content_margin_left   = 8
		sb.content_margin_right  = 8
		btn.add_theme_stylebox_override(states[i], sb)
