class_name LevelData

class LevelTileData:
	enum Type { 
		NORMAL,
		ENTRY_UP,
		ENTRY_DOWN,
		ENTRY_LEFT,
		ENTRY_RIGHT
	}

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

var _grid: Dictionary[Vector2i, LevelTileData]

func get_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for cell: Vector2i in _grid:
		cells.append(cell)

	return cells
	
func get_cells_by_type(tile_type: LevelTileData.Type) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for cell: Vector2i in _grid:
		if _grid[cell].type == tile_type:
			cells.append(cell)

	return cells
	
func _init():
	_grid = {}

func add_rectangle_region(c1: Vector2i, c2: Vector2i, tileType: LevelTileData.Type = LevelTileData.Type.NORMAL) -> LevelData:
	var sx = [c1.x, c2.x]
	var sy = [c1.y, c2.y]
	sx.sort()
	sy.sort()

	for x in range(sx[0], sx[1] + 1):
		for y in range(sy[0], sy[1] + 1):
			add_tile(Vector2i(x, y), tileType)
	return self

func add_tile(cell: Vector2i, tileType: LevelTileData.Type = LevelTileData.Type.NORMAL) -> LevelData:
	if !_grid.has(cell):
		_grid[cell] = LevelTileData.new(tileType)
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
			
			
func print_debug_map() -> void:
	if _grid.is_empty():
		print("[LevelData: empty]")
		return

	var first_cell: Vector2i = _grid.keys()[0]
	var min_x := first_cell.x
	var max_x := first_cell.x
	var min_y := first_cell.y
	var max_y := first_cell.y

	for cell: Vector2i in _grid:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	print("Level map:")

	for y in range(min_y, max_y + 1):
		var row := ""

		for x in range(min_x, max_x + 1):
			var cell := Vector2i(x, y)
			var tile_data: LevelTileData = _grid.get(cell)

			if tile_data == null:
				row += " "
			elif not tile_data.is_empty():
				row += "B"  # has a bug on it
			else:
				match tile_data.type:
					LevelTileData.Type.NORMAL:
						row += "."
					LevelTileData.Type.ENTRY_UP, LevelTileData.Type.ENTRY_DOWN, \
					LevelTileData.Type.ENTRY_LEFT, LevelTileData.Type.ENTRY_RIGHT:
						row += "E"
					_:
						row += "?"

		print(row)
