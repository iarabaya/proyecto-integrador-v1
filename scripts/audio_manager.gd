extends Node

var _sfx_click: AudioStreamPlayer

func _ready() -> void:
	_sfx_click = AudioStreamPlayer.new()
	_sfx_click.stream = preload("res://assets/sounds/ui-click.ogg")
	_sfx_click.volume_db = -3.0
	add_child(_sfx_click)

func play_click() -> void:
	_sfx_click.play()
