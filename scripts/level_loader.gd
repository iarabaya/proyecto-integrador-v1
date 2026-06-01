# LevelLoader.gd
# Reads a level JSON file and fills two TileMapLayer nodes (floor + walls).
# Also builds the solid[][] collision array used by PlayerModel.
class_name LevelLoader


static func load_level(key: String, floor_layer: TileMapLayer, walls_layer: TileMapLayer) -> Dictionary:
	var text := FileAccess.get_file_as_string("res://levels/" + key + ".json")
	var data: Dictionary = JSON.parse_string(text)

	var cols: int = data["cols"]
	var rows: int = data["rows"]

	_fill_layer(floor_layer, data["layers"]["floor"], cols)
	_fill_layer(walls_layer, data["layers"]["walls"], cols)

	var solid: Array = []
	for y in rows:
		var row: Array = []
		for x in cols:
			var wall_gid  := int(data["layers"]["walls"][y * cols + x])
			var floor_gid := int(data["layers"]["floor"][y * cols + x])
			var is_water  := floor_gid >= 400 and floor_gid <= 499
			row.append(wall_gid != 0 or is_water)
		solid.append(row)

	return {
		"cols": cols,
		"rows": rows,
		"solid": solid,
		"spawn": data["spawn"],
		"objects": data["objects"],
		"mission": data.get("mission", {})
	}


# Kept for backward compatibility — gym_level.gd can keep calling this
static func load_gym(floor_layer: TileMapLayer, walls_layer: TileMapLayer) -> Dictionary:
	return load_level("gym", floor_layer, walls_layer)


static func _fill_layer(layer: TileMapLayer, gids: Array, cols: int) -> void:
	for i in gids.size():
		var gid: int = int(gids[i])
		if gid == 0:
			continue
		var cell := GidMapper.resolve(gid)
		if cell.is_empty():
			continue
		var tile_x := i % cols
		var tile_y := int(i / float(cols))
		layer.set_cell(
			Vector2i(tile_x, tile_y),
			cell["source_id"],
			cell["coords"]
		)
