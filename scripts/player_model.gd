# PlayerModel.gd
# Pure movement logic and collision — no rendering, no nodes.
# Direct port of Player.js. Used by Player.gd (the visual layer).
class_name PlayerModel
extends RefCounted

signal stepped()
signal blocked()

const DIRS: Dictionary = {
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


func _init(p_cols: int, p_rows: int, p_solid: Array, p_spawn_tx: int, p_spawn_ty: int) -> void:
	cols     = p_cols
	rows     = p_rows
	solid    = p_solid
	spawn_tx = p_spawn_tx
	spawn_ty = p_spawn_ty
	tx       = p_spawn_tx
	ty       = p_spawn_ty


# Returns true if the tile at (x, y) is within bounds and not solid.
func can_enter(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < cols and y < rows and not solid[y][x]

# Attempt a one-tile move in dir.
# Returns {success, tx, ty, facing}
func try_move(dir: String) -> Dictionary:
	if not DIRS.has(dir):
		return {success=false, tx=tx, ty=ty, facing=facing}

	var d: Vector2i = DIRS[dir]
	var nx: int = tx + d.x
	var ny: int = ty + d.y

	if not can_enter(nx, ny):
		# Blocked — update facing but stay in place
		facing = dir
		blocked.emit()
		return {success=false, tx=tx, ty=ty, facing=facing}

	tx = nx
	ty = ny
	facing = dir
	stepped.emit()
	return {success=true, tx=tx, ty=ty, facing=facing}


# Attempt a jump: leap 2 tiles over 1 (even if the middle tile is solid).
# Returns {success, from_tx, from_ty, to_tx, to_ty, facing}
func try_jump(dir: String) -> Dictionary:
	if not DIRS.has(dir):
		# Jump in place — no direction given
		return {
			success=true,
			from_tx=tx, from_ty=ty,
			to_tx=tx,   to_ty=ty,
			facing=facing
		}

	var d: Vector2i = DIRS[dir]
	var lx: int = tx + d.x * 2
	var ly: int = ty + d.y * 2

	var from_tx := tx
	var from_ty := ty

	if not can_enter(lx, ly):
		# Can't land — stay in place, update facing only
		facing = dir
		return {
			success=false,
			from_tx=from_tx, from_ty=from_ty,
			to_tx=tx,        to_ty=ty,
			facing=facing
		}

	tx = lx
	ty = ly
	facing = dir
	return {
		success=true,
		from_tx=from_tx, from_ty=from_ty,
		to_tx=tx,        to_ty=ty,
		facing=facing
	}


# Jump in place, no movement, just the animation.
func jump_in_place() -> Dictionary:
	return {
		success=true,
		from_tx=tx, from_ty=ty,
		to_tx=tx,   to_ty=ty,
		facing=facing
	}


# Reset to spawn position.
func reset() -> void:
	tx     = spawn_tx
	ty     = spawn_ty
	facing = "down"
	print("reset player")


# ── Animation frame helpers (mirrors Player.js static methods) ────────────────

static func base_frame_for_dir(dir: String) -> int:
	match dir:
		"up":    return 4
		"left":  return 8
		"right": return 12
	return 0  # down


static func idle_frame_for_dir(dir: String) -> int:
	return base_frame_for_dir(dir)


static func jump_frames_for_dir(dir: String) -> Array[int]:
	var base := base_frame_for_dir(dir)
	return [base + 1, base + 2]
