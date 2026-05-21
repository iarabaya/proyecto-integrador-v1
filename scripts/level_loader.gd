# LevelLoader.gd
# Reads a level JSON file and fills two TileMapLayer nodes (floor + walls).
# Also builds the solid[][] collision array used by PlayerModel.
class_name LevelLoader


static func load_gym(floor_layer: TileMapLayer, walls_layer: TileMapLayer) -> Dictionary:
	# Read and parse the JSON file
	var text := FileAccess.get_file_as_string("res://levels/gym.json")
	var data: Dictionary = JSON.parse_string(text)

	var cols: int = data["cols"]   # 16
	var rows: int = data["rows"]   # 12

	# Fill both tile layers
	_fill_layer(floor_layer, data["layers"]["floor"], cols)
	_fill_layer(walls_layer, data["layers"]["walls"], cols)

	# Build solid[y][x] — true means the tile blocks movement
	var solid: Array = []
	for y in rows:
		var row: Array = []
		for x in cols:
			var gid: int = int(data["layers"]["walls"][y * cols + x])
			row.append(gid != 0)
		solid.append(row)

	return {
		"cols": cols,
		"rows": rows,
		"solid": solid,
		"spawn": data["spawn"],       # {tx, ty}
		"objects": data["objects"],   # array of {tx, ty, key, frame, type}
	}


static func _fill_layer(layer: TileMapLayer, gids: Array, cols: int) -> void:
	for i in gids.size():
		var gid: int = int(gids[i])
		if gid == 0:
			continue
		var cell := GidMapper.resolve(gid)
		if cell.is_empty():
			continue
		var tile_x := i % cols
		var tile_y := i / cols
		layer.set_cell(
			Vector2i(tile_x, tile_y),
			cell["source_id"],
			cell["coords"]
		)
