extends Bug
class_name Slug

const BODY_REGULAR_SPRITE = preload("res://Sprites/slug_body_topdown.png")
const BODY_CORNER_SPRITE = preload("res://Sprites/slug_corner_topdown.png")
const TAIL_SPRITE = preload("res://Sprites/slug_tail_topdown.png")
var alternate: bool = false

func init_segments() -> void:
	if length < 3: length = 3
	segment_sprites = [$Head]
	segment_cells = []
	for i in range(length):
		segment_cells.append(Vector2i(-i, 0))
		
		if i > 1: 
			var body_segment = Sprite2D.new()
			add_child(body_segment)
			segment_sprites.append(body_segment)
			body_segment.texture = BODY_REGULAR_SPRITE
	var tail_segment = Sprite2D.new()
	
	tail_segment.name = "Tail"
	tail_segment.texture = TAIL_SPRITE
	add_child(tail_segment)
	segment_sprites.append(tail_segment)

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
	move_segment(length-1, segment_cells[length-2], Vector2(segment_cells[length-3] + direction - segment_cells[length-1]))
	for i in range(length-2):
		move_segment(length-i-2, segment_cells[length-i-3], Vector2(segment_cells[0+i] + direction - segment_cells[1+i]))
	move_segment(0, segment_cells[0] + direction, direction)
	
	for segment in range(len(segment_sprites)):
		if segment == 0: 
			var direction_to_body = segment_cells[segment] - segment_cells[segment + 1]
			segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
			continue
		elif segment == len(segment_cells) - 1:
			var direction_to_body = segment_cells[segment - 1] - segment_cells[segment]
			segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
			break
		segment_sprites[segment].texture = BODY_REGULAR_SPRITE
		var corner_direction: Vector2i = segment_cells[segment + 1] - segment_cells[segment - 1]
		if corner_direction not in [Vector2i(1,1), Vector2i(-1,-1), Vector2i(-1,1), Vector2i(1,-1)]: 
			segment_sprites[segment].texture = BODY_REGULAR_SPRITE
			if corner_direction in [Vector2i(2,0), Vector2i(-2,0)]: 
				segment_sprites[segment + 1].rotation = 0
				segment_sprites[segment].rotation = 0
			else: segment_sprites[segment].rotation = PI/2
		else: 
			segment_sprites[segment].texture = BODY_CORNER_SPRITE
			segment_sprites[segment + 1].rotation = PI/2
			
			if (segment_cells[segment].y > segment_cells[segment + 1].y and segment_cells[segment].x == segment_cells[segment + 1].x) \
				or (segment_cells[segment].y > segment_cells[segment - 1].y and segment_cells[segment].x == segment_cells[segment - 1].x):
					if (segment_cells[segment].x < segment_cells[segment + 1].x) or (segment_cells[segment].x < segment_cells[segment - 1].x):
						segment_sprites[segment].rotation = PI
					else:
						segment_sprites[segment].rotation = PI/2
			
			elif (segment_cells[segment].y < segment_cells[segment + 1].y and segment_cells[segment].x == segment_cells[segment + 1].x) \
				or (segment_cells[segment].y < segment_cells[segment - 1].y and segment_cells[segment].x == segment_cells[segment - 1].x):
					if (segment_cells[segment].x < segment_cells[segment + 1].x) or (segment_cells[segment].x < segment_cells[segment - 1].x):
						segment_sprites[segment].rotation = 3*PI/2
					else:
						segment_sprites[segment].rotation = 0
	level_data.add_bug(self)

''' 
Move the caterpillar:
	- Move individual segments
	- Erase tilemap references to a segment when a segment leaves that tile
	- Add tilemap reference to a segment when a segment enters that tile
'''
func move_segment(index: int, next_cell: Vector2i, _move_diff: Vector2) -> void:
	var tilemap := level_manager.tile_map_layer
	segment_cells[index] = next_cell
	segment_sprites[index].position = tilemap.map_to_local(segment_cells[index])
