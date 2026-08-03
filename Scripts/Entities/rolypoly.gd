extends Bug
class_name Rolypoly

@export var rolled_sprite: Texture2D
@export var static_sprite: Texture2D

var is_moving: bool = false
var spin_speed: float = 2.0


func init_segments() -> void:
	segment_sprites = [$Body]
	segment_cells = [
		Vector2i(0, 0)
	]

func move(direction: Vector2i) -> bool:
	if is_moving:
		return false
	# not top down: flip it!
	if direction.x != 0:
		segment_sprites[0].flip_h = direction.x > 0
		
	var level_data := level_manager.level_data
	var current_cell := segment_cells[0]
	var next_cell := current_cell + direction
	var destination := current_cell
	var tile_data := level_data.get_tile_data(next_cell)

	if tile_data == null:
		print("Movement Error: Outside of Play Space")
		return false

	if tile_data.type in [LevelData.LevelTileData.Type.ENTRY_UP, \
	 					LevelData.LevelTileData.Type.ENTRY_DOWN, \
						LevelData.LevelTileData.Type.ENTRY_LEFT, \
						LevelData.LevelTileData.Type.ENTRY_RIGHT]:
		print("Movement Error: Can't move back out of fruit")
		return false

		destination = next_cell
		next_cell += direction
		tile_data = level_data.get_tile_data(next_cell)

	if destination == current_cell:
		print("Movement Error: Path is Blocked")
		return false
	
	is_moving = true
	level_data.remove_bug(self)
	# keeps await animation separate and returns expected bool in timely manner
	_do_roll(current_cell, destination, direction, level_data)
	return true

''' 
Move the roly poly:
	- Move the head in a straight line until the next tile is blocked
	- Update the bug's only segment position
	- Switch to rolling sprite while moving
'''

func _do_roll(current_cell: Vector2i, destination: Vector2i, direction: Vector2i, level_data: LevelData) -> void:
	await roll_to(current_cell, destination, direction)
	level_data.add_bug(self)
	is_moving = false

func roll_to(from_cell: Vector2i, to_cell: Vector2i, direction: Vector2i) -> void:
	var tilemap := level_manager.tile_map_layer
	segment_sprites[0].texture = rolled_sprite
	
	var step_count: int = max(abs(to_cell.x - from_cell.x), abs(to_cell.y - from_cell.y))
	
	var curr_cell = from_cell
	
	for i in step_count:
		$Body.rotation += spin_speed
		curr_cell += direction
		segment_cells[0] = curr_cell
		var tween = create_tween()
		tween.tween_property(segment_sprites[0], "position", tilemap.map_to_local(curr_cell), 0.15).set_trans(Tween.TRANS_SINE)
		await tween.finished
	
	$Body.rotation = 0
	segment_sprites[0].texture = static_sprite
