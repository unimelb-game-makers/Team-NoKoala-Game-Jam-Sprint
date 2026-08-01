class_name LevelData

class LevelTileData:
	enum Type { NORMAL }

	var type: Type
	var bugs: Array[Bug]

	func _init(p_type: Type):
		type = p_type
		bugs = []
	
	func is_empty() -> bool:
		return bugs.is_empty()

	func add_bug(bug: Bug) -> void:
		if not bugs.has(bug):
			bugs.append(bug)
	
	func remove_bug(bug: Bug) -> void:
		bugs.erase(bug)

var start_cell: Vector2i
var _grid: Dictionary[Vector2i, LevelTileData]

func _init(p_start_tile: Vector2i):
	start_cell = p_start_tile
	_grid = {}

func add_rectangle_region(c1: Vector2i, c2: Vector2i) -> LevelData:
	var sx = [c1.x, c2.x]
	var sy = [c1.y, c2.y]
	sx.sort()
	sy.sort()

	for x in range(sx[0], sx[1] + 1):
		for y in range(sy[0], sy[1] + 1):
			add_tile(Vector2i(x, y))
	return self

func add_tile(cell: Vector2i) -> LevelData:
	if !_grid.has(cell):
		_grid[cell] = LevelTileData.new(LevelTileData.Type.NORMAL)
	return self

## Returns null if the cell is outside of play space
func get_tile_data(cell: Vector2i) -> LevelTileData:
	return _grid.get(cell)

func add_bug(bug: Bug) -> void:
	for segment_cell in bug.segment_cells:
		var tile_data := get_tile_data(segment_cell)
		if tile_data != null:
			tile_data.add_bug(bug)

func remove_bug(bug: Bug) -> void:
	for segment_cell in bug.segment_cells:
		var tile_data := get_tile_data(segment_cell)
		if tile_data != null:
			tile_data.remove_bug(bug)
