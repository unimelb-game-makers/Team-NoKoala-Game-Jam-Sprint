extends Centipede

func init_segments() -> void:
	segment_sprites = [$Head, $Body, $Body2, $Body3, $Tail]
	segment_cells = [
		Vector2i(0, 0),
		Vector2i(-1, 0),
		Vector2i(-2, 0),
		Vector2i(-3, 0),
		Vector2i(-4, 0),
	]

# Update positions of each segment
func move(direction: Vector2i) -> bool:
	# Catch invalid movements
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
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

	if tile_data.type in [LevelData.LevelTileData.Type.ENTRY_UP, \
						LevelData.LevelTileData.Type.ENTRY_DOWN, \
						LevelData.LevelTileData.Type.ENTRY_LEFT, \
						LevelData.LevelTileData.Type.ENTRY_RIGHT]:
		print("Movement Error: Can't move back out of fruit")
		return false

	# Move caterpillar segments
	level_data.remove_bug(self)

	var old_cells = segment_cells.duplicate()
	var n = segment_cells.size()

	# for every segment
	for i in range(n - 1, 0, -1):
		var new_pos: Vector2
		# special case for head segment (follow direction)
		if i - 1 == 0:
			new_pos = Vector2(old_cells[0] + direction)
		# otherwise follow predecessor
		else:
			new_pos = Vector2(old_cells[i - 2])

		# only rotates if diff > 0
		var diff = new_pos - Vector2(old_cells[i])
		move_segment(i, old_cells[i - 1], diff)

	move_segment(0, old_cells[0] + direction, Vector2(direction))
	level_data.add_bug(self)
	return true

'''
Move the caterpillar:
	- Move individual segments
	- Erase tilemap references to a segment when a segment leaves that tile
	- Add tilemap reference to a segment when a segment enters that tile
'''
func move_segment(index: int, next_cell: Vector2i, move_diff: Vector2) -> void:
	var tween := create_movement_tween()
	tween.set_parallel(true)

	var tilemap := level_manager.tile_map_layer
	segment_cells[index] = next_cell
	tween.tween_property(segment_sprites[index], "position", tilemap.map_to_local(segment_cells[index]), 0.15).set_trans(Tween.TRANS_SINE)
	var rotate_angle = wrapf(atan2(move_diff.y, move_diff.x) - segment_sprites[index].rotation, -PI, PI)
	tween.tween_property(segment_sprites[index], "rotation", rotate_angle + segment_sprites[index].rotation, 0.2)

#func _unhandled_input(event: InputEvent) -> void:
	## placeholder until actual transform logic
	#if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		#transform_cocoon()

func transform_cocoon() -> void:
	var tilemap = level_manager.tile_map_layer
	var level_data = level_manager.level_data

	# while the size of the segments is > 1 (i.e isn't just the head)
	while segment_sprites.size() > 1:
		var tween = create_tween()
		tween.set_parallel(true)
		var count = segment_sprites.size()
		# move everything but the head up one
		for i in range(1, count):
			tween.tween_property(segment_sprites[i], "position", tilemap.map_to_local(segment_cells[i - 1]), 0.15)

		#tween.tween_property(segment_sprites[1], "modulate:a", 0.0, 0.15)
		await tween.finished

		# remove segment[1] (i.e the one just after the head)
		var absorbed_segment = segment_sprites.pop_at(1)

		# remove from tile data too
		var vacated_cell = segment_cells[-1]
		if level_data._grid.has(vacated_cell):
			level_data._grid[vacated_cell].remove_bug(self)

		segment_cells.pop_back()
		absorbed_segment.queue_free()

	# change head texture
	#segment_sprites[0].texture = cocoon
	#segment_sprites[0].rotation = 0
	#isCocoon = true
	#level_data.print_debug_map()

func transform_butterfly() -> void:
	return
