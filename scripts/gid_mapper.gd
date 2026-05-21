extends Node

# Maps Phaser GIDs → Godot TileSet source_id + atlas coords
# Matches TileLevel.TILESETS exactly — do not change the firstgid values

const SOURCES = [
	{first=1,   last=99,  id=0, cols=11},  # grass
	{first=100, last=199, id=1, cols=4 },  # fences
	{first=200, last=299, id=2, cols=11},  # dirt
	{first=300, last=399, id=3, cols=11},  # hills
	{first=400, last=499, id=4, cols=4 },  # water
]

static func resolve(gid: int) -> Dictionary:
	for s in SOURCES:
		if gid >= s.first and gid <= s.last:
			var idx = gid - s.first
			return {source_id=s.id, coords=Vector2i(idx % s.cols, idx / s.cols)}
	return {}
