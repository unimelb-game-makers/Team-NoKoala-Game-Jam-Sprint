extends Bug
class_name Rolypoly


func init_segments() -> void:
	segment_sprites = [$Head]
	segment_cells = [
		Vector2i(0, 0)
	]

func move(direction: Vector2i) -> bool:
	var level_data := level_manager.level_data
	var current_cell := segment_cells[0]
	var next_cell := current_cell + direction
	var destination := current_cell
	var tile_data := level_data.get_tile_data(next_cell)

	if tile_data == null:
		print("Movement Error: Outside of Play Space")
		return false

	while tile_data != null:
		if tile_data.type == LevelData.LevelTileData.Type.ENTRY:
			break

		if not tile_data.is_empty():
			break

		destination = next_cell
		next_cell += direction
		tile_data = level_data.get_tile_data(next_cell)

	if destination == current_cell:
		print("Movement Error: Path is Blocked")
		return false

	level_data.remove_bug(self)
	move_segment(destination)
	level_data.add_bug(self)
	return true

''' 
Move the roly poly:
	- Move the head in a straight line until the next tile is blocked
	- Update the bug's only segment position
'''
func move_segment(next_cell: Vector2i) -> void:
	var tilemap := level_manager.tile_map_layer
	segment_cells[0] = next_cell
	segment_sprites[0].position = tilemap.map_to_local(segment_cells[0])
