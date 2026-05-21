# GidMapper.gd
# Converts Phaser-style GIDs from gym.json to Godot TileSet source_id + atlas coords.
# GID ranges match TileLevel.TILESETS exactly — do NOT change these values,
# they are baked into gym.json and main.json.
class_name GidMapper


const SOURCES: Array[Dictionary] = [
	{"first": 1,   "last": 99,  "id": 0, "cols": 11},  # grass   (Grass.png)
	{"first": 100, "last": 199, "id": 1, "cols": 4 },  # fences  (Fences.png)
	{"first": 200, "last": 299, "id": 2, "cols": 11},  # dirt    (Tilled_Dirt.png)
	{"first": 300, "last": 399, "id": 3, "cols": 11},  # hills   (Hills.png)
	{"first": 400, "last": 499, "id": 4, "cols": 4 },  # water   (Water.png)
]


## Returns {source_id: int, coords: Vector2i} for a given GID.
## Returns an empty Dictionary if the GID is 0 or unrecognised.
static func resolve(gid: int) -> Dictionary:
	if gid <= 0:
		return {}
	for s in SOURCES:
		if gid >= s["first"] and gid <= s["last"]:
			var idx: int = gid - s["first"]
			return {
				"source_id": s["id"],
				"coords": Vector2i(idx % s["cols"], idx / s["cols"])
			}
	return {}
