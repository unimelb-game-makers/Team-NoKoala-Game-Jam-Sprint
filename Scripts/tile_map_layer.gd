extends TileMapLayer

@export var spawnpoint: Vector2i

# TBD: Will need a better way to define the play-space
var tile_data: Dictionary = {
	Vector2i(-3, 2): [],
	Vector2i(-4, 2): [],
	Vector2i(-5, 2): [],
	
	Vector2i(-2, 2): [],
	Vector2i(-1, 2): [],
	Vector2i(0, 2): [],
	Vector2i(1, 2): [],
	
	Vector2i(-2, 1): [],
	Vector2i(-1, 1): [],
	Vector2i(0, 1): [],
	Vector2i(1, 1): [],
	
	Vector2i(-2, 0): [],
	Vector2i(-1, 0): [],
	Vector2i(0, 0): [],
	Vector2i(1, 0): [],
	
	Vector2i(-2, -1): [],
	Vector2i(-1, -1): [],
	Vector2i(0, -1): [],
	Vector2i(1, -1): [],
	
	Vector2i(-2, -2): [],
	Vector2i(-1, -2): [],
	Vector2i(0, -2): [],
	Vector2i(1, -2): []
}
