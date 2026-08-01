extends Bug
class_name Caterpillar

# Align each Caterpillar segment with grid
func spawn() -> void:
	segments[0].position = tilemap.map_to_local(tilemap.spawnpoint)
	tilemap.tile_data[tilemap.spawnpoint].append(segments[0])
	segment_local_pos[segments[0]] = tilemap.spawnpoint
	
	segments[1].position = tilemap.map_to_local(tilemap.spawnpoint - Vector2i(1, 0))
	tilemap.tile_data[tilemap.spawnpoint - Vector2i(1, 0)].append(segments[1])
	segment_local_pos[segments[1]] = tilemap.spawnpoint - Vector2i(1, 0)
	
	segments[2].position = tilemap.map_to_local(tilemap.spawnpoint - Vector2i(2, 0))
	tilemap.tile_data[tilemap.spawnpoint - Vector2i(2, 0)].append(segments[2])
	segment_local_pos[segments[2]] = tilemap.spawnpoint - Vector2i(2, 0)

# Update positions of each segment
func move(direction: Directions) -> void:
	var direction_vector: Vector2i = Vector2i(0, 0)
	match direction:
		Directions.UP: direction_vector = Vector2i(0, -1)
		Directions.LEFT: direction_vector = Vector2i(-1, 0)
		Directions.RIGHT: direction_vector = Vector2i(1, 0)
		Directions.DOWN: direction_vector = Vector2i(0, 1)
	
	# Catch invalid movements
	var next_tile = segment_local_pos[segments[0]] + direction_vector
	if not next_tile in tilemap.tile_data.keys(): 
		print("Movement Error: Outside of Play Space")
		return
	
	if not tilemap.tile_data[next_tile].is_empty():
		print("Movement Error: Tile is Occupied")
		return
	
	if next_tile == tilemap.spawnpoint:
		print("Movement Error: Can't move back out of fruit")
		return
	
	# Move caterpillar segments
	move_segment(2, segment_local_pos[segments[1]], Vector2(segment_local_pos[segments[0]]) - Vector2(segment_local_pos[segments[1]]))
	move_segment(1, segment_local_pos[segments[0]], Vector2(segment_local_pos[segments[0]] + direction_vector - segment_local_pos[segments[2]]))
	move_segment(0, segment_local_pos[segments[0]] + direction_vector, direction_vector)

''' 
Move the caterpillar:
	- Move individual segments
	- Erase tilemap references to a segment when a segment leaves that tile
	- Add tilemap reference to a segment when a segment enters that tile
'''
func move_segment(segment_num: int, next_segment_pos: Vector2i, move_diff: Vector2) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	tilemap.tile_data[segment_local_pos[segments[segment_num]]].erase(segments[segment_num])
	segment_local_pos[segments[segment_num]] = next_segment_pos #segment_local_pos[segments[next_segment_num]]
	tween.tween_property(segments[segment_num], "position", tilemap.map_to_local(segment_local_pos[segments[segment_num]]), 0.15).set_trans(Tween.TRANS_SINE)
	tilemap.tile_data[segment_local_pos[segments[segment_num]]].append(segments[segment_num])
	var rotate_angle = wrapf(atan2(move_diff.y, move_diff.x) - segments[segment_num].rotation, -PI, PI)
	tween.tween_property(segments[segment_num], "rotation", rotate_angle + segments[segment_num].rotation, 0.2)
