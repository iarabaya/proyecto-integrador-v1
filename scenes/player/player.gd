# Player.gd
# Visual layer — sprite, animations, and movement tweens.
# All collision/state logic lives in PlayerModel.
extends Node2D


const STEP_SEC  := 0.30   # seconds per tile step (matches JS STEP_MS = 160)
const JUMP_HEIGHT := 10.0  # pixels of arc at the peak of a jump

@onready var sprite: AnimatedSprite2D = $Sprite

var model: PlayerModel


func setup(p_model: PlayerModel) -> void:
	model    = p_model
	position = tile_center(model.tx, model.ty)
	sprite.play("idle_" + model.facing)


# ── Helpers ───────────────────────────────────────────────────────────────────

func tile_center(tile_x: int, tile_y: int) -> Vector2:
	return Vector2(tile_x * 16.0 + 8.0, tile_y * 16.0 + 8.0)


# ── Movement ──────────────────────────────────────────────────────────────────

# Move one tile in dir. Waits until the tween finishes before returning.
func step(dir: String) -> void:
	var result := model.try_move(dir)

	if not result["success"]:
		# Blocked — face that direction and wait one step duration
		sprite.play("idle_" + result["facing"])
		await get_tree().create_timer(STEP_SEC).timeout
		return

	sprite.play("walk_" + result["facing"])
	var tween := create_tween()
	tween.tween_property(self, "position",
		tile_center(result["tx"], result["ty"]), STEP_SEC)
	await tween.finished


# Jump in place — animation only, no tile movement.
func jump_in_place() -> void:
	var result := model.jump_in_place()
	await _play_jump_arc(result["facing"],
		tile_center(result["from_tx"], result["from_ty"]),
		tile_center(result["to_tx"],   result["to_ty"]))


# Jump two tiles in dir, arcing over the middle tile.
func jump_dir(dir: String) -> void:
	var result := model.try_jump(dir)
	await _play_jump_arc(result["facing"],
		tile_center(result["from_tx"], result["from_ty"]),
		tile_center(result["to_tx"],   result["to_ty"]))


# Internal: plays the jump arc tween and sets jump frames.
func _play_jump_arc(dir: String, from_pos: Vector2, to_pos: Vector2) -> void:
	var frames := PlayerModel.jump_frames_for_dir(dir)
	sprite.stop()
	sprite.frame = frames[0]

	var elapsed := 0.0
	var half := STEP_SEC * 0.5

	while elapsed < STEP_SEC:
		elapsed += get_process_delta_time()
		var t := clampf(elapsed / STEP_SEC, 0.0, 1.0)

		# Switch to second jump frame at the halfway point
		if elapsed >= half:
			sprite.frame = frames[1]

		# Lerp position + sine arc
		position = from_pos.lerp(to_pos, t)
		position.y -= sin(PI * t) * JUMP_HEIGHT

		await get_tree().process_frame

	position = to_pos
	sprite.stop()
	sprite.frame = PlayerModel.idle_frame_for_dir(dir)


# Called by ProgramExecutor after all moves finish.
func play_idle() -> void:
	sprite.play("idle_" + model.facing)
