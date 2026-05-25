extends Control

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

@onready var _btn_jugar:    Button = $BG/Center/Panel/Card/BtnPlay
@onready var _btn_niveles:  Button = $BG/Center/Panel/Card/BtnLevels
@onready var _btn_settings: Button = $BG/Center/Panel/Card/BtnSettings
@onready var _btn_credits:  Button = $BG/Center/Panel/Card/BtnCredits
@onready var _title:        Label  = $BG/Center/Panel/Card/Title
@onready var _subtitle:     Label  = $BG/Center/Panel/Card/Subtitle

func _ready() -> void:
	# Title styling
	_title.add_theme_font_override("font", PIXEL_FONT)
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Subtitle styling
	_subtitle.add_theme_font_override("font", PIXEL_FONT)
	_subtitle.add_theme_font_size_override("font_size", 8)
	_subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Buttons
	_btn_jugar.pressed.connect(_on_jugar)
	_btn_niveles.pressed.connect(_on_niveles)
	_btn_settings.pressed.connect(_on_settings)
	_btn_credits.pressed.connect(_on_credits)

func _on_jugar() -> void:
	if SaveSystem.has_save():
		get_tree().change_scene_to_file.call_deferred("res://scenes/continue_screen/continue_screen.tscn")
	else:
		SaveSystem.launch_level("gym")

func _on_niveles() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn")

func _on_settings() -> void:
	# Placeholder — will be implemented later
	OS.alert("Próximamente", "Configuración")

func _on_credits() -> void:
	# Placeholder — will be implemented later
	OS.alert("Gatito Code\nDesarrollo: tu nombre aquí\n\n🐱 Gracias por jugar", "Créditos")
