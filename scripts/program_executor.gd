class_name ProgramExecutor

## Valid directional commands
const VALID_DIRS: Array[String] = ["up", "down", "left", "right"]

## Execute a sequence of commands, driving the player step by step.
## Awaitable — caller must use: await ProgramExecutor.execute_program(...)
##
## moves       : Array of strings — "up","down","left","right","jump","jump_up",
##               "jump_down","jump_left","jump_right","func1"
## player      : Player node (must have .step(), .jump_in_place(), .jump_dir(), .play_idle(), .model)
## pickups     : PickupManager node
## func1_queue : Optional secondary command queue (Function 1 slot)
static func execute_program(
	moves: Array,
	player: Node,
	pickups: PickupManager,
	func1_queue: Array = [],
	on_step: Callable = Callable()
) -> void:
	var step_index := 0
	for move in moves:
		# Notify which step is about to execute
		if on_step.is_valid():
			on_step.call(step_index)

		if move == "func1":
			for sub_move in func1_queue:
				await _run_single(sub_move, player, pickups)
		else:
			await _run_single(move, player, pickups)

		step_index += 1

	player.play_idle()


static func _run_single(move: String, player: Node, pickups: PickupManager) -> void:
	if move == "jump":
		# In-place jump: no position change, no pickup check
		await player.jump_in_place()

	elif move.begins_with("jump_"):
		var dir := move.substr(5)   # strip "jump_" prefix
		await player.jump_dir(dir)
		pickups.check_pickup(player.model.tx, player.model.ty)

	elif move in VALID_DIRS:
		await player.step(move)
		pickups.check_pickup(player.model.tx, player.model.ty)
	# Unknown commands are silently skipped (safe for future additions)
