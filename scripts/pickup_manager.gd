# PickupManager.gd
# Spawns deco and pickup sprites from the level objects array.
# Handles floating animation, collection detection, and collect effects.
class_name PickupManager
extends Node2D


const FRAME_SIZE := 16

# Maps object keys from gym.json to their spritesheet info
const OBJECT_SHEETS: Dictionary = {
	"plants":      {"path": "res://assets/objects/Basic Plants.png",             "cols": 6},
	"grass_props": {"path": "res://assets/objects/Basic Grass Biom things 1.png","cols": 9},
	"furniture":   {"path": "res://assets/objects/Basic Furniture.png",          "cols": 9},
	"tools":       {"path": "res://assets/objects/Basic tools and meterials.png","cols": 3},
}

# "tx,ty" → {sprite, tween}
var pickups: Dictionary = {}
var collected: int = 0

var _objects_data: Array = []
var _solid: Array = []


func setup(objects: Array, solid: Array) -> void:
	_objects_data = objects
	_solid = solid
	for obj in objects:
		if obj["type"] == "pickup":
			_spawn_pickup(obj)
		else:
			_spawn_deco(obj)


func check_pickup(tx: int, ty: int) -> void:
	var key := "%d,%d" % [tx, ty]
	if not pickups.has(key):
		return
	var data: Dictionary = pickups[key]
	pickups.erase(key)
	collected += 1
	_play_collect(data["sprite"], data["tween"])


func get_collected() -> int:
	return collected

func get_remaining() -> int:
	return pickups.size()

func reset() -> void:
	for child in get_children():
		child.queue_free()
	pickups.clear()
	collected = 0
	for obj in _objects_data:
		if obj["type"] == "pickup":
			_spawn_pickup(obj)
		else:
			_spawn_deco(obj)


# ── Spawning ──────────────────────────────────────────────────────────────────

func _spawn_pickup(obj: Dictionary) -> void:
	var pos := _tile_center(obj["tx"], obj["ty"])
	var sprite := _make_sprite(obj["key"], obj["frame"], pos)
	sprite.z_index = 5
	add_child(sprite)

	# Floating bob — loops forever
	var tween := sprite.create_tween().set_loops()
	tween.tween_property(sprite, "position:y", pos.y - 2.0, 0.6) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", pos.y, 0.6) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	pickups["%d,%d" % [obj["tx"], obj["ty"]]] = {"sprite": sprite, "tween": tween}


func _spawn_deco(obj: Dictionary) -> void:
	var pos := _tile_center(obj["tx"], obj["ty"])
	var sprite := _make_sprite(obj["key"], obj["frame"], pos)
	sprite.z_index = 3
	add_child(sprite)


func _make_sprite(sheet_key: String, frame: int, pos: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.position = pos

	if not OBJECT_SHEETS.has(sheet_key):
		push_warning("PickupManager: clave desconocida '%s'" % sheet_key)
		return sprite

	var info: Dictionary = OBJECT_SHEETS[sheet_key]
	var texture := load(info["path"]) as Texture2D

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	var cols: int = int(info["cols"])
	var col: int = frame % cols
	var row := int(frame / float(cols))
	atlas.region = Rect2(col * FRAME_SIZE, row * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)

	sprite.texture = atlas
	return sprite


# ── Collection effect ─────────────────────────────────────────────────────────

func _play_collect(sprite: Sprite2D, float_tween: Tween) -> void:
	float_tween.kill()

	# Sprite: scale up + fade out + float up
	var tween := sprite.create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.38) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.38) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "position:y", sprite.position.y - 14.0, 0.38) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback(sprite.queue_free)

	# "+1" floating label
	var label := Label.new()
	label.text = "+1"
	label.position = Vector2(sprite.position.x - 6.0, sprite.position.y - 25.0)
	label.z_index = 10
	var style := LabelSettings.new()
	style.font = load("res://assets/pixelFont-7-8x14-sproutLands.ttf")
	style.font_size = 12
	style.font_color = Color.YELLOW  # amarillo suave
	style.outline_color = Color.BLACK
	style.outline_size = 3
	label.label_settings = style
	add_child(label)

	var ltween := label.create_tween().set_parallel(true)
	ltween.tween_property(label, "position:y", label.position.y - 30.0, 2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ltween.tween_property(label, "modulate:a", 0.0, 1.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ltween.chain().tween_callback(label.queue_free)


# ── Helper ────────────────────────────────────────────────────────────────────

func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2(tx * 16.0 + 8.0, ty * 16.0 + 8.0)
