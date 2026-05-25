extends Control

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

@onready var _subtitle:     Label  = $Background/Panel/Margin/Card/Subtitle
@onready var _btn_continue: Button = $Background/Panel/Margin/Card/BtnContinue
@onready var _btn_new_game: Button = $Background/Panel/Margin/Card/BtnNewGame

func _ready() -> void:
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
	SaveSystem.launch_level(lvl["key"])

func _on_new_game() -> void:
	SaveSystem.reset()
	SaveSystem.launch_level(SaveSystem.LEVELS[0]["key"])
