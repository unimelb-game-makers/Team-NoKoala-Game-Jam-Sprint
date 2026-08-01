extends Bug
class_name Slug

const BODY_REGULAR_SPRITE = preload("res://Sprites/slug_body.png")
const BODY_CORNER_SPRITE = preload("res://Sprites/slug_corner.png")

func init_segments() -> void:
	segment_sprites = [$Head, $Body, $Tail]
	segment_cells = [
		Vector2i(0, 0),
		Vector2i(-1, 0),
		Vector2i(-2, 0),
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
	
	if next_cell == level_data.start_cell:
		print("Movement Error: Can't move back out of fruit")
		return
	
	# Move caterpillar segments
	level_data.remove_bug(self)
	move_segment(2, segment_cells[1], Vector2(segment_cells[0]) - Vector2(segment_cells[1]))
	move_segment(1, segment_cells[0], Vector2(segment_cells[0] + direction - segment_cells[2]))
	move_segment(0, segment_cells[0] + direction, direction)
	
	for segment in range(len(segment_sprites)):
		if segment == 0: continue
		elif segment == len(segment_cells) - 1: break
		
		segment_sprites[segment].texture = BODY_REGULAR_SPRITE
		var corner_direction: Vector2i = segment_cells[segment + 1] - segment_cells[segment - 1]
		if corner_direction.x > 0:
			if corner_direction.y == 0: return
			segment_sprites[segment].texture = BODY_CORNER_SPRITE
			#Head to the right
			if corner_direction.y > 0:
				segment_sprites[segment].rotation = PI
			else:
				segment_sprites[segment].rotation = 0
		elif corner_direction.x < 0:
			if corner_direction.y == 0: return
			segment_sprites[segment].texture = BODY_CORNER_SPRITE
			#Head to the right
			if corner_direction.y > 0:
				segment_sprites[segment].rotation = PI/2
			else:
				segment_sprites[segment].rotation = 3*PI/2
		
	
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
	#var rotate_angle = wrapf(atan2(move_diff.y, move_diff.x) - segment_sprites[index].rotation, -PI, PI)
	#tween.tween_property(segment_sprites[index], "rotation", rotate_angle + segment_sprites[index].rotation, 0.2)
	
