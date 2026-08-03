class_name LevelData

class LevelTileData:
	enum Type { 
		NORMAL,
		ENTRY_UP,
		ENTRY_DOWN,
		ENTRY_LEFT,
		ENTRY_RIGHT,
		HARD,
		HARD_BROKEN,
		INDESTRUCTIBLE
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

static func from_tilemap(tilemap: TileMapLayer) -> LevelData:
	var level := LevelData.new()

	for cell in tilemap.get_used_cells():
		var source_id := tilemap.get_cell_source_id(cell)

		if source_id == -1:
			continue

		var source := tilemap.tile_set.get_source(source_id)
		var tile_name := source.resource_name
		var atlas_coordinates := tilemap.get_cell_atlas_coords(cell)

		match tile_name:
			"normal_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.NORMAL
				)

			"entry_cell":
				match atlas_coordinates:
					Vector2i(0,0):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_DOWN
						)
					Vector2i(1,0):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_UP
						)
					Vector2i(0,1):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_RIGHT
						)
					Vector2i(1,1):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_LEFT
						)
					#level.add_tile(
					#	cell,
					#	LevelData.LevelTileData.Type.ENTRY
					#)

			"hard_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.HARD
				)

			"hard_broken_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.HARD_BROKEN
				)

			"indestructible_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.INDESTRUCTIBLE
				)

			_:
				push_warning("Unknown tile source: " + tile_name)
	
	return level

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

func get_tile_datas() -> Array[LevelTileData]:
	var tiles: Array[LevelTileData] = _grid.values()
	return tiles
	
func set_tile_data(cell: Vector2i, new_tile_type: LevelTileData.Type) -> void:
	var tile = _grid.get(cell)
	tile.type = new_tile_type

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
					LevelTileData.Type.HARD:
						row += "H"
					LevelTileData.Type.HARD_BROKEN:
						row += "B"
					LevelTileData.Type.INDESTRUCTIBLE:
						row += "I"
					_:
						row += "?"

		print(row)
