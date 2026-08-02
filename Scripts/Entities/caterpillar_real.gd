extends Caterpillar

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
func move(direction: Vector2i) -> void:
	# Catch invalid movements
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
	if tile_data == null: 
		print("Movement Error: Outside of Play Space")
		return
	
	if not tile_data.is_empty():
		print("Movement Error: Tile is Occupied")
		return
	
	if tile_data.type == LevelData.LevelTileData.Type.ENTRY:
		print("Movement Error: Can't move back out of fruit")
		return
	
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

''' 
Move the caterpillar:
	- Move individual segments
	- Erase tilemap references to a segment when a segment leaves that tile
	- Add tilemap reference to a segment when a segment enters that tile
'''
func move_segment(index: int, next_cell: Vector2i, move_diff: Vector2) -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	var tilemap := level_manager.tile_map_layer
	segment_cells[index] = next_cell
	tween.tween_property(segment_sprites[index], "position", tilemap.map_to_local(segment_cells[index]), 0.15).set_trans(Tween.TRANS_SINE)
	var rotate_angle = wrapf(atan2(move_diff.y, move_diff.x) - segment_sprites[index].rotation, -PI, PI)
	tween.tween_property(segment_sprites[index], "rotation", rotate_angle + segment_sprites[index].rotation, 0.2)
