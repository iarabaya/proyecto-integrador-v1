extends Node

# Pure movement state & collision — no rendering (mirrors Player.js)
class_name PlayerModel

const DIRS = {
	"up":    Vector2i(0, -1),
	"down":  Vector2i(0,  1),
	"left":  Vector2i(-1, 0),
	"right": Vector2i(1,  0),
}

var cols: int
var rows: int
var solid: Array
var spawn_tx: int
var spawn_ty: int
var tx: int
var ty: int
var facing: String = "down"

func _init(c, r, s, stx, sty):
	cols=c; rows=r; solid=s; spawn_tx=stx; spawn_ty=sty
	tx=stx; ty=sty

func can_enter(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < cols and y < rows and not solid[y][x]

func try_move(dir: String) -> Dictionary:
	if not DIRS.has(dir):
		return {success=false, tx=tx, ty=ty, facing=facing}
	var d = DIRS[dir]
	var nx = tx + d.x
	var ny = ty + d.y
	if not can_enter(nx, ny):
		return {success=false, tx=tx, ty=ty, facing=dir}
	tx = nx; ty = ny; facing = dir
	return {success=true, tx=tx, ty=ty, facing=facing}

func try_jump(dir: String) -> Dictionary:
	if not DIRS.has(dir):
		return {success=true, from_tx=tx, from_ty=ty, to_tx=tx, to_ty=ty, facing=facing}
	var d = DIRS[dir]
	var lx = tx + d.x * 2
	var ly = ty + d.y * 2
	if not can_enter(lx, ly):
		return {success=false, from_tx=tx, from_ty=ty, to_tx=tx, to_ty=ty, facing=dir}
	var from_tx = tx; var from_ty = ty
	tx = lx; ty = ly; facing = dir
	return {success=true, from_tx=from_tx, from_ty=from_ty, to_tx=tx, to_ty=ty, facing=facing}

func reset() -> void:
	tx = spawn_tx; ty = spawn_ty; facing = "down"

static func base_frame_for_dir(dir: String) -> int:
	match dir:
		"up":    return 4
		"left":  return 8
		"right": return 12
	return 0
