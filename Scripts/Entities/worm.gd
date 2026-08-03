extends Bug
class_name Worm

@export var curve_alt: Texture2D
@export var curve: Texture2D

const BODY_REGULAR_SPRITE = preload("res://Sprites/worm-straight.png")
const BODY_CORNER_SPRITE = preload("res://Sprites/worm-curved.png")
const TAIL_SPRITE = preload("res://Sprites/worm-tail.png")
var alternate: bool = false
var is_moving: bool = false
var curve_hold_active: bool = false

func init_segments() -> void:
	if length < 3: length = 3
	segment_sprites = [$Head]
	segment_cells = []
	for i in range(length):
		segment_cells.append(Vector2i(-i, 0))
		
		# Spawn body segments based on length
		if i > 1: 
			var body_segment = Sprite2D.new()
			body_segment.z_index = 0
			add_child(body_segment)
			segment_sprites.append(body_segment)
			body_segment.texture = BODY_REGULAR_SPRITE
	
	# Add tail segment 
	var tail_segment = Sprite2D.new()
	tail_segment.name = "Tail"
	tail_segment.texture = TAIL_SPRITE
	add_child(tail_segment)
	tail_segment.z_index = 0
	segment_sprites.append(tail_segment)

# Update positions of each segment
func move(direction: Vector2i) -> bool:
	if is_moving:
		return false
	# Catch invalid movements
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
	var current_cell := segment_cells[0]
	var destination := current_cell
	
	if tile_data == null: 
		print("Movement Error: Outside of Play Space")
		return false
	
	while tile_data != null:
		if self in tile_data.bugs:
			print("Movement Error: Cannot overlap self")
			break
		
		if not tile_data.is_empty():
			break
		
		if tile_data.type in [LevelData.LevelTileData.Type.HARD, LevelData.LevelTileData.Type.INDESTRUCTIBLE]:
			print("Movement Error: Can't move into hard tiles")
			break
		
		if tile_data.type in [LevelData.LevelTileData.Type.ENTRY_UP, \
		 					LevelData.LevelTileData.Type.ENTRY_DOWN, \
							LevelData.LevelTileData.Type.ENTRY_LEFT, \
							LevelData.LevelTileData.Type.ENTRY_RIGHT]:
			print("Movement Error: Can't move back out of fruit")
			break

		destination = next_cell
		next_cell += direction
		tile_data = level_data.get_tile_data(next_cell)

	if destination == current_cell:
		print("Movement Error: Path is Blocked")
		return false
	
	is_moving = true
	level_data.remove_bug(self)
	_do_slide(current_cell, destination, direction, level_data)
	return true

func _do_slide(current_cell: Vector2i, destination: Vector2i, direction: Vector2i, level_data: LevelData) -> void:
	await slide_to(current_cell, destination, direction)
	level_data.add_bug(self)
	is_moving = false

func slide_to(from_cell: Vector2i, to_cell: Vector2i, direction: Vector2i) -> void:
	var tilemap = level_manager.tile_map_layer
	
	var step_count: int = max(abs(to_cell.x - from_cell.x), abs(to_cell.y - from_cell.y))
	var n = segment_cells.size()
	
	for step in step_count:
		var old_cells = segment_cells.duplicate()

		var tween = create_tween()
		tween.set_parallel(true)
		
		# body/tail follow it's predecessor
		for i in range(n - 1, 0, -1):
			var new_pos: Vector2i = old_cells[i - 1]
			segment_cells[i] = new_pos
			tween.tween_property(segment_sprites[i], "position", tilemap.map_to_local(new_pos), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			var delay := i * 0.08  # stagger animation
			tween.tween_callback(_update_segment_rotations.bind(i)).set_delay(delay)
			
		# handle head as special case
		segment_cells[0] = old_cells[0] + direction
		tween.tween_property(segment_sprites[0], "position", tilemap.map_to_local(segment_cells[0]), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_callback(_update_segment_rotations.bind(0))
		await tween.finished

func _update_segment_rotations(index: int) -> void:
	# Segment rotation logic 
	var segment: int = index
		
	# Rotate Head 
	if segment == 0: 
		var direction_to_body = segment_cells[segment] - segment_cells[segment + 1]
		segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
		return
	
	# Rotate Tail
	elif segment == len(segment_cells) - 1:
		var direction_to_body = segment_cells[segment - 1] - segment_cells[segment]
		segment_sprites[segment].rotation = atan2(direction_to_body.y, direction_to_body.x)
		return
	
	# Body Rotation/Sprite Logic
	var corner_direction: Vector2i = segment_cells[segment + 1] - segment_cells[segment - 1]
	
	# Check if the body segment is not on a corner
	if corner_direction not in [Vector2i(1,1), Vector2i(-1,-1), Vector2i(-1,1), Vector2i(1,-1)]: 
		segment_sprites[segment].texture = BODY_REGULAR_SPRITE
		
		if corner_direction in [Vector2i(2,0), Vector2i(-2,0)]:
			segment_sprites[segment].rotation = 0
		else: segment_sprites[segment].rotation = PI/2
	# It is a corner
	else: 
		segment_sprites[segment].texture = BODY_CORNER_SPRITE
		
		# Determine rotation of corner piece
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
