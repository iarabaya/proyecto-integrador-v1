# GymLevel.gd
# Main gameplay scene for the Gym level.
extends Node2D


@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var walls_layer: TileMapLayer = $WallsLayer

# Level data populated in _ready
var cols: int
var rows: int
var solid: Array
var spawn: Dictionary
var objects: Array


func _ready() -> void:
	var level := LevelLoader.load_gym(floor_layer, walls_layer)
	cols    = level["cols"]
	rows    = level["rows"]
	solid   = level["solid"]
	spawn   = level["spawn"]
	objects = level["objects"]

	print("Nivel cargado: %d x %d" % [cols, rows])
	print("Spawn: tx=%d ty=%d" % [spawn["tx"], spawn["ty"]])
	print("Objetos: %d" % objects.size())
