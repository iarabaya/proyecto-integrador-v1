extends Node

# Mirrors executeProgram() from ProgramExecutor.js
static func execute(moves: Array, player: Node, queue_func1: Array = []) -> void:
	for dir in moves:
		if dir == "func1" and queue_func1.size() > 0:
			for fdir in queue_func1:
				if fdir == "jump":      await player.jump_in_place()
				elif fdir.begins_with("jump_"): await player.jump_dir(fdir.substr(5))
				elif PlayerModel.DIRS.has(fdir): await player.step(fdir)
		elif dir == "jump":
			await player.jump_in_place()
		elif dir.begins_with("jump_"):
			await player.jump_dir(dir.substr(5))
		elif PlayerModel.DIRS.has(dir):
			await player.step(dir)
	player.model.facing = player.model.facing  # trigger idle
	player.get_node("Sprite").play("idle_" + player.model.facing)
