extends Node2D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const TILE := 16

# ── MapRoot wraps all world-space objects so we can offset them together ──
@onready var map_root:         Node2D       = $MapRoot
@onready var floor_layer:      TileMapLayer = $MapRoot/FloorLayer
@onready var walls_layer:      TileMapLayer = $MapRoot/WallsLayer

# commands and reaction panel
@onready var _ui:              CanvasLayer  = $CommandUI
@onready var _character_reaction: CharacterReaction = $CommandUI/ReactionPanel/Reaction

# pause menu ui
@onready var _btn_pause: TextureButton = $CommandUI/PauseButton
@onready var _pause_menu: PauseMenu = $PauseMenu

# win screen
@onready var _win_overlay:     CanvasLayer  = $WinOverlay
@onready var _win_restart_btn: Button       = $WinOverlay/Background/Panel/VBox/BtnRestart
@onready var _win_next_btn:    Button       = $WinOverlay/Background/Panel/VBox/BtnNext

# mission overlay
@onready var _mission_overlay: MissionOverlay = $MissionOverlay

# ── Sound effects ────────────────────────────────────────────────────
@onready var _sfx_pickup:      AudioStreamPlayer = $SfxPickup
@onready var _sfx_step:        AudioStreamPlayer = $SfxStep
@onready var _sfx_win:         AudioStreamPlayer = $SfxWin
@onready var _sfx_fail:        AudioStreamPlayer = $SfxFail
@onready var _sfx_level_start: AudioStreamPlayer = $SfxLevelStart
@onready var _sfx_level_restart: AudioStreamPlayer = $SfxLevelRestart
@onready var _sfx_wall_hit:    AudioStreamPlayer = $SfxWallHit
@onready var _music:           AudioStreamPlayer = $MusicPlayer


var _step_sounds: Array[AudioStream] = [
	preload("res://assets/sounds/footstep_grass_000.ogg"),
	preload("res://assets/sounds/footstep_grass_001.ogg"),
	preload("res://assets/sounds/footstep_grass_002.ogg"),
	preload("res://assets/sounds/footstep_grass_003.ogg"),
	preload("res://assets/sounds/footstep_grass_004.ogg")]

var _wall_sounds: Array[AudioStream] = [
	preload("res://assets/sounds/impactPlank_000.ogg"),
	preload("res://assets/sounds/impactPlank_001.ogg"),
	preload("res://assets/sounds/impactPlank_002.ogg"),
	preload("res://assets/sounds/impactPlank_003.ogg"),
	preload("res://assets/sounds/impactPlank_004.ogg")]

var _level_key: String
var level_data: Dictionary
var player_model: PlayerModel
var player: Node2D
var pickup_manager: PickupManager
var _running := false
var _has_executed := false

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
	
	# Grid overlay
	var grid := TileGrid.new()
	grid.z_index = 3
	map_root.add_child(grid)
	grid.setup(int(level_data["cols"]), int(level_data["rows"]))
	
	# Mission overlay
	var mission: Dictionary = level_data.get("mission", {})
	_mission_overlay.setup(mission)
	_ui.mission_requested.connect(_mission_overlay.toggle)

	_ui.execute_requested.connect(run_program)
	_ui.restart_requested.connect(restart_level)
	_btn_pause.pressed.connect(_pause_menu.open)
	_win_restart_btn.pressed.connect(restart_level)
	_win_next_btn.pressed.connect(_on_next_level)
	
	_character_reaction.show_emote("appear")
	_update_pickup_counter()
	player_model.stepped.connect(_play_step)
	player_model.blocked.connect(_play_wall_hit)
	
	_sfx_level_start.play()
	
	for btn in [_btn_pause, _win_restart_btn, _win_next_btn]:
		btn.pressed.connect(AudioManager.play_click)
	
	_music.stream = preload("res://assets/sounds/songs/section-farm-music.mp3")
	_music.volume_db = -10.0     # quieter so it doesn't overpower SFX
	_music.play()
	
		  
func run_program(moves: Array) -> void:
	if _running: return
	_running = true
	_ui.lock(true)
	
	if _has_executed:
		await _restart_state() 
	
	_has_executed = true
	_character_reaction.show_emote("neutral")
	
	# Build console lines
	var console: ConsolePanel = _ui.get_console()
	console.build_from_queue(moves)
	
	var state := [pickup_manager.get_collected(), -1]  # [pickup_before, last_index]

	await ProgramExecutor.execute_program(
		moves, player, pickup_manager, [],
		func(i: int):
			_ui.highlight_slot(i)
			console.highlight_line(i)
			if state[1] >= 0:
				_mark_step_result(console, state[1], state[0])
				state[0] = pickup_manager.get_collected()
			state[1] = i
	)
	
	# Mark the last step
	if moves.size() > 0:
		_mark_step_result(console, state[1], state[0])
	_ui.clear_highlight()
	console.clear_highlight()

	# Add summary line
	if pickup_manager.get_remaining() == 0:
		console.add_summary("→ ¡Completado! ✓", Color(0.0, 0.535, 0.0, 1.0))
		SaveSystem.complete_level(_level_key)
		_character_reaction.show_emote("boss")
		_sfx_win.play()  
		_win_overlay.visible = true
	else:
		console.add_summary("→ Error: faltan %d frutas ✗" % pickup_manager.get_remaining(), Color(1.0, 0.152, 0.152, 1.0))
		_sfx_fail.play()
		_ui.lock(false)

	_running = false

	if pickup_manager.get_remaining() > 0:
		await _character_reaction.show_emote_after_current("annoyed")

func _restart_state() -> void:
	player_model.reset()
	pickup_manager.reset()
	await get_tree().process_frame  # ← wait for old sprites to be freed
	pickup_manager.setup(level_data["objects"], level_data["solid"])
	player.setup(player_model)
	_update_pickup_counter()
	_sfx_level_restart.play()

func restart_level() -> void:
	_win_overlay.visible = false
	_ui.lock(false)
	if _running: return
	await _restart_state()
	_has_executed = false
	_ui.clear_queue()   # clears the sequence
	_character_reaction.show_emote("happy")

func _on_next_level() -> void:
	var next := SaveSystem.get_continue_level()
	if next.is_empty(): return
	SaveSystem.launch_level(next["key"])

func _on_pickup_collected() -> void:
	_character_reaction.show_emote("heart")
	_update_pickup_counter()
	_sfx_pickup.play()

func _update_pickup_counter() -> void:
	var collected := pickup_manager.get_collected()
	var total := collected + pickup_manager.get_remaining()
	_ui.update_pickup_counter(collected, total)

func _mark_step_result(console: ConsolePanel, index: int, pickup_before: int) -> void:
	var collected_now := pickup_manager.get_collected()
	if collected_now > pickup_before:
		console.mark_line(index, "→ fruta ✓")
	else:
		console.mark_line(index, "")

# ── Sound effects helper methods ────────────────────────────────────────────────────

func _play_step() -> void:
	_sfx_step.stream = _step_sounds.pick_random()
	_sfx_step.pitch_scale = randf_range(0.95, 1.05)
	_sfx_step.play()

func _play_wall_hit() -> void:
	_sfx_wall_hit.stream = _wall_sounds.pick_random()
	_sfx_wall_hit.pitch_scale = randf_range(0.95, 1.05)
	_sfx_wall_hit.play()
