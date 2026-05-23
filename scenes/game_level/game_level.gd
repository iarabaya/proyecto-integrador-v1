extends Node2D

const PlayerScene := preload("res://scenes/player/Player.tscn")

@onready var floor_layer:      TileMapLayer = $FloorLayer
@onready var walls_layer:      TileMapLayer = $WallsLayer
@onready var _ui:              CanvasLayer  = $CommandUI
@onready var _win_overlay:     CanvasLayer  = $WinOverlay
@onready var _win_restart_btn: Button       = $WinOverlay/Background/VBox/BtnRestart
@onready var _win_next_btn:    Button       = $WinOverlay/Background/VBox/BtnNext

var _level_key: String
var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D
var pickup_manager: PickupManager
var _running := false

func _ready() -> void:
	_level_key = SaveSystem.current_level_key

	level_data = LevelLoader.load_level(_level_key, floor_layer, walls_layer)

	player_model = PlayerModel.new(
		level_data["cols"],
		level_data["rows"],
		level_data["solid"],
		level_data["spawn"]["tx"],
		level_data["spawn"]["ty"]
	)

	pickup_manager = PickupManager.new()
	add_child(pickup_manager)
	pickup_manager.setup(level_data["objects"], level_data["solid"])

	player = PlayerScene.instantiate()
	add_child(player)
	player.z_index = 4
	player.setup(player_model)

	_ui.execute_requested.connect(run_program)
	_ui.restart_requested.connect(restart_level)
	_win_restart_btn.pressed.connect(restart_level)
	_win_next_btn.pressed.connect(_on_next_level)

func run_program(moves: Array) -> void:
	if _running: return
	_running = true
	_ui.lock(true)

	await ProgramExecutor.execute_program(moves, player, pickup_manager)

	if pickup_manager.get_remaining() == 0:
		SaveSystem.complete_level(_level_key)
		_win_overlay.visible = true
	else:
		_ui.lock(false)

	_running = false

func restart_level() -> void:
	_win_overlay.visible = false
	_ui.lock(false)
	if _running: return
	player_model.reset()
	pickup_manager.reset()
	pickup_manager.setup(level_data["objects"], level_data["solid"])
	player.setup(player_model)

func _on_next_level() -> void:
	var next := SaveSystem.get_continue_level()
	if next.is_empty(): return
	SaveSystem.launch_level(next["key"])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn")
