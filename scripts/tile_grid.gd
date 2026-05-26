class_name TileGrid
extends Node2D

var cols: int = 0
var rows: int = 0
var tile_size: int = 16
var grid_color: Color = Color(0.0, 0.0, 0.0, 0.15)   # black at 15% opacity

func setup(p_cols: int, p_rows: int, p_tile_size: int = 16) -> void:
	cols = p_cols
	rows = p_rows
	tile_size = p_tile_size
	queue_redraw()

func _draw() -> void:
	if cols == 0 or rows == 0: return
	var w: float = cols * tile_size
	var h: float = rows * tile_size
	for x in range(cols + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, h), grid_color, 1.0)
	for y in range(rows + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(w, y * tile_size), grid_color, 1.0)
