# save_system.gd
extends Node

const SAVE_PATH = "user://save.json"

const LEVELS: Array[Dictionary] = [
	{ "key": "gym",    "title": "Nivel 1 - Gimnasio" },
	{ "key": "level2", "title": "Nivel 2 - Campo"    },
	{ "key": "level3", "title": "Nivel 3 - Huerto"   },
]

var _completed: Array[String] = []
var current_level_key: String = ""   # ← NEW

func _ready() -> void:
	_load()

# ── Public API ──────────────────────────────────────────

func launch_level(key: String) -> void:   # ← NEW
	current_level_key = key
	get_tree().change_scene_to_file.call_deferred(
        "res://scenes/game_level/game_level.tscn"
	)

func complete_level(key: String) -> void:
	if key not in _completed:
		_completed.append(key)
	_save()

func is_completed(key: String) -> bool:
	return key in _completed

func is_unlocked(key: String) -> bool:
	var idx := _index_of(key)
	if idx < 0:  return false
	if idx == 0: return true  # first level always unlocked
	return is_completed(LEVELS[idx - 1]["key"])

func has_save() -> bool:
	return _completed.size() > 0

func get_continue_level() -> Dictionary:
	# First unlocked-but-not-yet-completed level; falls back to last level
	for lvl in LEVELS:
		if is_unlocked(lvl["key"]) and not is_completed(lvl["key"]):
			return lvl
	return LEVELS[-1]

func get_level(key: String) -> Dictionary:
	for lvl in LEVELS:
		if lvl["key"] == key:
			return lvl
	return {}

func reset() -> void:
	_completed.clear()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

# ── Internal ─────────────────────────────────────────────

func _index_of(key: String) -> int:
	for i in LEVELS.size():
		if LEVELS[i]["key"] == key:
			return i
	return -1

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({ "completed": _completed }))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return
	var data = JSON.parse_string(file.get_as_text())
	if data and data.has("completed"):
		_completed = Array(data["completed"], TYPE_STRING, "", null)
