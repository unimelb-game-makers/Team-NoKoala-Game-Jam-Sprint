extends Bug
class_name Ant

var facing_direction = Directions.RIGHT

func init_segments() -> void:
	segment_sprites = [$Head, $Body]
	segment_cells = [
		Vector2i(0, 0),
		Vector2i(-1, 0)
	]

# Update positions of each segment
func move(direction: Vector2i) -> bool:
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
	
	# If heading same direction as facing: move forward 1 tile
	if direction == facing_direction:
		
		
		if tile_data == null: 
			print("Movement Error: Outside of Play Space")
			return false
		
		if not tile_data.is_empty():
			for bug in tile_data.bugs:
				if not bug.get_name() == "Slug":
					print("Movement Error: Tile is Occupied")
					return false
		
		if tile_data.type in [LevelData.LevelTileData.Type.HARD, LevelData.LevelTileData.Type.INDESTRUCTIBLE]:
			print("Movement Error: Can't move into hard tiles")
			return false
		
		if tile_data.type == LevelData.LevelTileData.Type.ENTRY:
			print("Movement Error: Can't move back out of fruit")
			return false
		
		# Move caterpillar segments
		level_data.remove_bug(self)
		move_segment(1, segment_cells[0], Vector2(segment_cells[0]) - Vector2(segment_cells[1]))
		move_segment(0, segment_cells[0] + direction, direction)
		level_data.add_bug(self)
		return true
	
	# Otherwise rotate around head as pivot
	else:
		tile_data = level_data.get_tile_data(segment_cells[1] + direction)
		
		if tile_data == null: 
			print("Movement Error: Outside of Play Space")
			return false
		
		if not tile_data.is_empty():
			for bug in tile_data.bugs:
				if not bug.get_name() == "Slug":
					print("Movement Error: Tile is Occupied")
					return false
		
		if tile_data.type in [LevelData.LevelTileData.Type.HARD, LevelData.LevelTileData.Type.INDESTRUCTIBLE]:
			print("Movement Error: Can't move into hard tiles")
			return false
		
		if tile_data.type == LevelData.LevelTileData.Type.ENTRY:
			print("Movement Error: Can't move back out of fruit")
			return false
		
		level_data.remove_bug(self)
		move_segment(0, segment_cells[1] + direction, direction)
		level_data.add_bug(self)
		
		facing_direction = direction
		segment_sprites[0].rotation = atan2(direction.y, direction.x)
		segment_sprites[1].rotation = atan2(direction.y, direction.x)
		return true
''' 
Move the caterpillar:
	- Move individual segments
	- Erase tilemap references to a segment when a segment leaves that tile
	- Add tilemap reference to a segment when a segment enters that tile
'''
func move_segment(index: int, next_cell: Vector2i, move_diff: Vector2) -> void:
	var tilemap := level_manager.tile_map_layer
	segment_cells[index] = next_cell
	segment_sprites[index].position = tilemap.map_to_local(segment_cells[index])
