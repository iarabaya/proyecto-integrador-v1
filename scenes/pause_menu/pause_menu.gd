class_name PauseMenu
extends CanvasLayer

@onready var _btn_continue:  Button = $Background/Panel/VBox/BtnContinue
@onready var _btn_levels:    Button = $Background/Panel/VBox/BtnLevels
@onready var _btn_settings:  Button = $Background/Panel/VBox/BtnSettings
@onready var _btn_main_menu: Button = $Background/Panel/VBox/BtnMainMenu

func _ready() -> void:
	visible = false
	_btn_continue.pressed.connect(close)
	_btn_levels.pressed.connect(_go_levels)
	_btn_settings.pressed.connect(_go_settings)
	_btn_main_menu.pressed.connect(_go_main_menu)
	
	for btn in [_btn_continue, _btn_levels, _btn_settings, _btn_main_menu]:
		btn.pressed.connect(AudioManager.play_click)

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _go_levels() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn")

func _go_settings() -> void:
	# Placeholder for now
	OS.alert("Configuración — próximamente")

func _go_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu/main_menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
