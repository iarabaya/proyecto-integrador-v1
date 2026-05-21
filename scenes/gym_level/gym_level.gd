# GymLevel.gd
extends Node2D


const PlayerScene := preload("res://scenes/player/Player.tscn")

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var walls_layer: TileMapLayer = $WallsLayer

var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D


func _ready() -> void:
	# 1. Load tilemap
	level_data = LevelLoader.load_gym(floor_layer, walls_layer)

	# 2. Create player model (pure logic)
	player_model = PlayerModel.new(
		level_data["cols"],
		level_data["rows"],
		level_data["solid"],
		level_data["spawn"]["tx"],
		level_data["spawn"]["ty"]
	)

	# 3. Spawn player sprite
	player = PlayerScene.instantiate()
	add_child(player)
	player.z_index = 4
	player.setup(player_model)

	print("Jugador en: tx=%d ty=%d" % [player_model.tx, player_model.ty])

# TEMPORAL — test de movimiento con flechas. Se borrará en el paso del UI.
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
	player.play_idle()
	_moving = false
