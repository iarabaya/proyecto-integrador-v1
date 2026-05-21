extends Node


static func load_gym(floor_layer: TileMapLayer, walls_layer: TileMapLayer) -> Dictionary:
	var text = FileAccess.get_file_as_string("res://levels/gym.json")
	var data = JSON.parse_string(text)
	var cols: int = data.cols   # 16
	var rows: int = data.rows   # 12

	_fill_layer(floor_layer, data.layers.floor, cols)
	_fill_layer(walls_layer, data.layers.walls, cols)

	# Build solid[][] — same logic as TileLevel.js
	var solid = []
	for y in rows:
		var row = []
		for x in cols:
			row.append(int(data.layers.walls[y * cols + x]) != 0)
		solid.append(row)

	return {
		cols=cols, rows=rows, solid=solid,
		spawn=data.spawn,   # {tx, ty}
		objects=data.objects,
		weather=data.get("weather", {})
	}

static func _fill_layer(layer: TileMapLayer, gids: Array, cols: int) -> void:
	for i in gids.size():
		var gid = int(gids[i])
		if gid == 0:
			continue
		var m = GidMapper.resolve(gid)
		if not m.is_empty():
			layer.set_cell(Vector2i(i % cols, i / cols), m.source_id, m.coords)
