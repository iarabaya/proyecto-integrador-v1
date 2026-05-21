extends Node

func _ready() -> void:
	if SaveSystem.has_save():
		get_tree().change_scene_to_file.call_deferred("res://scenes/continue_screen/continue_screen.tscn")
	else:
		get_tree().change_scene_to_file.call_deferred("res://scenes/gym_level/gym_level.tscn")
