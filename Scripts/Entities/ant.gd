extends Bug
class_name Ant

@export var check_in_between_tiles: bool = false

func init_segments() -> void:
	segment_sprites = [$Head, $Body]
	segment_cells = [
		Vector2i(0, 0),
		Vector2i(-1, 0)
	]

func set_facing_direction(direction: Vector2i) -> void:
	super.set_facing_direction(direction)
	for sprite in segment_sprites:
		sprite.rotation = atan2(direction.y, direction.x)

# Update positions of each segment
func move(direction: Vector2i) -> bool:
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
	
	# If heading same direction as facing: move forward 1 tile
	if direction == facing_direction:
		
		if not check_tile(tile_data, direction, false): return false
		
		# Move caterpillar segments
		level_data.remove_bug(self)
		move_segment(1, segment_cells[0], Vector2(segment_cells[0]) - Vector2(segment_cells[1]))
		move_segment(0, segment_cells[0] + direction, direction)
		level_data.add_bug(self)
		var sfxplayer = SfxPlayer.play_sfx(&"crawling")
		get_tree().create_timer(0.3).timeout.connect(sfxplayer.stop)

		return true
	
	# Otherwise rotate around head as pivot
	else:
		if check_in_between_tiles:
			
			# Doing a 180 degree turn - will check in both directions
			if direction == -facing_direction:
				var tile_1 = segment_cells[1] + direction
				var tile_2 = segment_cells[0] + Vector2i(direction.y, -direction.x)
				
				var check_1 = turn_check(tile_1, tile_2, direction, level_data)
				
				tile_2 = segment_cells[0]+Vector2i(-direction.y, direction.x)
				var check_2 = turn_check(tile_1, tile_2, direction, level_data)
				
				if not (check_1 == 0 or check_2 == 0): return false
				
			# Doing a 90 degree turn - need to check 90 deg turn and 270 deg turn
			else:
				# 90 degree turn
				var tile_1 = segment_cells[0]
				var tile_2 = segment_cells[1]+direction
				
				var check_1 = turn_check(tile_1, tile_2, direction, level_data)
				
				# 270 degree turn
				tile_1 = segment_cells[1] + Vector2i(-1, -1)
				tile_2 = segment_cells[1] + Vector2i(1, 1)
				
				var check_2 = turn_check(tile_1, tile_2, direction, level_data)
				
				if check_1 > 0:
					if check_2 > 1: return false
		
		tile_data = level_data.get_tile_data(segment_cells[1] + direction)
		if not check_tile(tile_data, direction, false): return false
		
		level_data.remove_bug(self)
		move_segment(0, segment_cells[1] + direction, direction)
		level_data.add_bug(self)
		
		facing_direction = direction
		segment_sprites[0].rotation = atan2(direction.y, direction.x)
		segment_sprites[1].rotation = atan2(direction.y, direction.x)
		var sfxplayer = SfxPlayer.play_sfx(&"crawling")
		get_tree().create_timer(0.3).timeout.connect(sfxplayer.stop)

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

func check_tile(tile_data: LevelData.LevelTileData, direction: Vector2i, rotating: bool) -> bool:
	if tile_data == null: 
			print("Movement Error: Outside of Play Space")
			return false
	
	if not tile_data.is_empty():
		for bug in tile_data.bugs:
			if not bug.get_name() == "Slug" and not (rotating and bug == self):
				print("Movement Error: Tile is Occupied")
				return false
	
	if tile_data.type in [LevelData.LevelTileData.Type.INDESTRUCTIBLE, LevelData.LevelTileData.Type.HARD]:
		print("Movement Error: Can't move into hard tiles")
		return false
	
	if tile_data.type in [LevelData.LevelTileData.Type.ENTRY_UP, \
						LevelData.LevelTileData.Type.ENTRY_DOWN, \
						LevelData.LevelTileData.Type.ENTRY_LEFT, \
						LevelData.LevelTileData.Type.ENTRY_RIGHT]:
		print("Movement Error: Can't move back out of fruit")
		return false
	
	return true

func turn_check(tile_1: Vector2i, tile_2: Vector2i, direction: Vector2i, level_data) -> int:
	var temp_tile_data
	var blocked_tile_count = 0
	for x in range(min(tile_1.x, tile_2.x), max(tile_1.x, tile_2.x)+1):
		for y in range(min(tile_1.y, tile_2.y), max(tile_1.y, tile_2.y)+1):
			temp_tile_data = level_data.get_tile_data(Vector2i(x, y))
			if not check_tile(temp_tile_data, direction, true): blocked_tile_count += 1
	return blocked_tile_count

func rotate_segments() -> void:
	for segment in range(len(segment_sprites)):
		
		# Rotate Head 
		if segment == 0: 
			var direction_to_body = segment_cells[segment] - segment_cells[segment + 1]
			segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
			continue
		# Rotate Tail
		elif segment == len(segment_cells) - 1:
			var direction_to_body = segment_cells[segment - 1] - segment_cells[segment]
			segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
			break
