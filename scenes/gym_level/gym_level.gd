# GymLevel.gd
extends Node2D


const PlayerScene := preload("res://scenes/player/Player.tscn")

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var walls_layer: TileMapLayer = $WallsLayer

var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D
var pickup_manager: PickupManager
var _running := false       # true while a program or step is executing
var _func1_queue: Array = []  # populated by the UI in Step 10


func _ready() -> void:
	# 1. Load tilemap
	level_data = LevelLoader.load_gym(floor_layer, walls_layer)

	# 2. Player model (pure logic)
	player_model = PlayerModel.new(
		level_data["cols"],
		level_data["rows"],
		level_data["solid"],
		level_data["spawn"]["tx"],
		level_data["spawn"]["ty"]
	)

	# 3. Pickup manager — spawns all objects from the JSON
	pickup_manager = PickupManager.new()
	add_child(pickup_manager)
	pickup_manager.setup(level_data["objects"], level_data["solid"])

	# 4. Player sprite
	player = PlayerScene.instantiate()
	add_child(player)
	player.z_index = 4
	player.setup(player_model)


## Called by the UI "Execute" button (Step 10). Runs the full command queue.
func run_program(moves: Array) -> void:
	if _running:
		return
	_running = true
	await ProgramExecutor.execute_program(moves, player, pickup_manager, _func1_queue)
	_running = false


## Resets player and pickups back to spawn state.
func restart_level() -> void:
	if _running:
		return
	player_model.reset()
	pickup_manager.reset()
	pickup_manager.setup(level_data["objects"], level_data["solid"])
	player.setup(player_model)

# TEMPORAL — test con flechas. Se reemplaza en el paso del UI.
var _moving := false

func _process(_delta: float) -> void:
	if _running:
		return
	if Input.is_action_just_pressed("ui_up"):    _test_step("up")
	elif Input.is_action_just_pressed("ui_down"):  _test_step("down")
	elif Input.is_action_just_pressed("ui_left"):  _test_step("left")
	elif Input.is_action_just_pressed("ui_right"): _test_step("right")


func _test_step(dir: String) -> void:
	_running = true
	await player.step(dir)
	pickup_manager.check_pickup(player_model.tx, player_model.ty)
	player.play_idle()
	_running = false
