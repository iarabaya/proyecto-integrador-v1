# GymLevel.gd
extends Node2D


const PlayerScene := preload("res://scenes/player/Player.tscn")

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var walls_layer: TileMapLayer = $WallsLayer

var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D
var pickup_manager: PickupManager


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


# TEMPORAL — test con flechas. Se reemplaza en el paso del UI.
var _moving := false

func _process(_delta: float) -> void:
	if _moving:
		return
	if Input.is_action_just_pressed("ui_up"):
		_test_step("up")
	elif Input.is_action_just_pressed("ui_down"):
		_test_step("down")
	elif Input.is_action_just_pressed("ui_left"):
		_test_step("left")
	elif Input.is_action_just_pressed("ui_right"):
		_test_step("right")


func _test_step(dir: String) -> void:
	_moving = true
	await player.step(dir)
	pickup_manager.check_pickup(player_model.tx, player_model.ty)
	player.play_idle()
	_moving = false
