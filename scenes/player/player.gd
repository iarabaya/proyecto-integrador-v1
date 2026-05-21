extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const STEP_SEC = 0.16
var model: PlayerModel  # injected by GymLevel

func tile_center(x: int, y: int) -> Vector2:
	return Vector2(x * 16 + 8, y * 16 + 8)

func step(dir: String) -> void:
	var result = model.try_move(dir)
	if not result.success:
		$Sprite.play("idle_" + result.facing)
		await get_tree().create_timer(STEP_SEC).timeout
		return
	
	$Sprite.play("walk_" + result.facing)
	var tween = create_tween()
	tween.tween_property(self, "position", tile_center(result.tx, result.ty), STEP_SEC)
	await tween.finished

func jump_in_place() -> void:
	var f = model.base_frame_for_dir(model.facing)
	$Sprite.stop(); $Sprite.frame = f + 1
	await get_tree().create_timer(STEP_SEC * 0.5).timeout
	$Sprite.frame = f + 2
	await get_tree().create_timer(STEP_SEC * 0.5).timeout

func jump_dir(dir: String) -> void:
	var result = model.try_jump(dir)
	var start = position
	var end = tile_center(result.to_tx, result.to_ty)
	var f = PlayerModel.base_frame_for_dir(dir)
	$Sprite.stop(); $Sprite.frame = f + 1
	var t = 0.0
	while t < STEP_SEC:
		t += get_process_delta_time()
		var pct = clampf(t / STEP_SEC, 0.0, 1.0)
		if pct >= 0.5: $Sprite.frame = f + 2
		position = start.lerp(end, pct)
		position.y -= sin(PI * pct) * 10.0   # arc
		await get_tree().process_frame
	position = end
