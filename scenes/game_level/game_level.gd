extends Node2D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const TILE := 16

# ── MapRoot wraps all world-space objects so we can offset them together ──
@onready var map_root:         Node2D       = $MapRoot
@onready var floor_layer:      TileMapLayer = $MapRoot/FloorLayer
@onready var walls_layer:      TileMapLayer = $MapRoot/WallsLayer
@onready var _ui:              CanvasLayer  = $CommandUI
@onready var _character_reaction: CharacterReaction = $CommandUI/Reaction
@onready var _btn_menu: TextureButton = $CommandUI/MenuButton
@onready var _win_overlay:     CanvasLayer  = $WinOverlay
@onready var _win_restart_btn: Button       = $WinOverlay/Background/Panel/VBox/BtnRestart
@onready var _win_next_btn:    Button       = $WinOverlay/Background/Panel/VBox/BtnNext

var _level_key: String
var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D
var pickup_manager: PickupManager
var _running := false

func _ready() -> void:
	_level_key = SaveSystem.current_level_key
	level_data = LevelLoader.load_level(_level_key, floor_layer, walls_layer)

	# ── Center the map horizontally in the viewport ──────────────────────
	var vp        := get_viewport_rect().size          # e.g. 480 × 270
	var map_w:    int   = int(level_data["cols"]) * TILE         # 16 × 16 = 256
	#var map_h:    int   = int(level_data["rows"]) * TILE        # 12 × 16 = 192
	var offset_x: float = floor((vp.x - float(map_w)) / 2.0)      # (480-256)/2 = 112
	#var offset_y: float = floor((vp.y - float(map_h)) / 2.0)      # (270-192)/2 =  39  ← optional
	# If you prefer top-aligned (tilemap touches top edge), use:
	map_root.position = Vector2(offset_x, 0.0)
	# ─────────────────────────────────────────────────────────────────────

	player_model = PlayerModel.new(
		level_data["cols"],
		level_data["rows"],
		level_data["solid"],
		level_data["spawn"]["tx"],
		level_data["spawn"]["ty"]
	)

	pickup_manager = PickupManager.new()
	map_root.add_child(pickup_manager)
	pickup_manager.setup(level_data["objects"], level_data["solid"])
	pickup_manager.pickup_collected.connect(_on_pickup_collected)

	player = PlayerScene.instantiate()
	map_root.add_child(player)
	player.z_index = 4
	player.setup(player_model)

	_ui.execute_requested.connect(run_program)
	_ui.restart_requested.connect(restart_level)
	_btn_menu.pressed.connect(_on_menu_pressed)
	_win_restart_btn.pressed.connect(restart_level)
	_win_next_btn.pressed.connect(_on_next_level)
	
	_character_reaction.show_emote("appear")    

func run_program(moves: Array) -> void:
	if _running: return
	_running = true
	_ui.lock(true)
	_character_reaction.show_emote("neutral") 

	await ProgramExecutor.execute_program(moves, player, pickup_manager)

	if pickup_manager.get_remaining() == 0:
		SaveSystem.complete_level(_level_key)
		_character_reaction.show_emote("boss")
		_win_overlay.visible = true
	else:
		_ui.lock(false)
	
	_running = false                                     # ← always runs now
	
	if pickup_manager.get_remaining() > 0:
		await _character_reaction.show_emote_after_current("annoyed")

func restart_level() -> void:
	_win_overlay.visible = false
	_ui.lock(false)
	if _running: return
	print("restart")
	player_model.reset()
	pickup_manager.reset()
	pickup_manager.setup(level_data["objects"], level_data["solid"])
	player.setup(player_model)
	_character_reaction.show_emote("happy")

func _on_next_level() -> void:
	var next := SaveSystem.get_continue_level()
	if next.is_empty(): return
	SaveSystem.launch_level(next["key"])

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu/main_menu.tscn")

func _on_pickup_collected() -> void:
	_character_reaction.show_emote("heart")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn")
