extends CurvedMeshBug

@export var MIN_SEGMENT_LENGTH := 3

var is_moving := false

@onready var head_mesh: MeshInstance2D = $Head
@onready var body_mesh: MeshInstance2D = $Body
@onready var tail_mesh: MeshInstance2D = $Tail


#initialise each segment of the bug 
func init_segments() -> void:
	if length < MIN_SEGMENT_LENGTH:
		length = MIN_SEGMENT_LENGTH

	mesh_segments = [head_mesh]
	for i in length - 2:
		var segment: MeshInstance2D
		if i == 0:
			segment = body_mesh
		else:
			segment = MeshInstance2D.new()
			segment.name = "Body%d" % (i + 1)
			segment.texture = body_mesh.texture
			add_child(segment)
		mesh_segments.append(segment)
	mesh_segments.append(tail_mesh)

	segment_cells.clear()
	for i in length:
		segment_cells.append(-facing_direction * i)

	_initialize_mesh_rendering()


func is_move_animation_active() -> bool:
	return is_moving or super.is_move_animation_active()


func move(direction: Vector2i) -> bool:
	if is_moving:
		return false

	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)
	var current_cell := segment_cells[0]
	var destination := current_cell

	while tile_data != null:
		if self in tile_data.bugs:
			print("Movement Error: Cannot overlap self")
			break

		if not tile_data.is_empty():
			if len(tile_data.bugs.filter(func(bug): return bug.get_name() != "Slug")) > 0:
				break

		if tile_data.type in [
			LevelData.LevelTileData.Type.HARD,
			LevelData.LevelTileData.Type.INDESTRUCTIBLE,
		]:
			print("Movement Error: Can't move into hard tiles")
			break

		if tile_data.type in [
			LevelData.LevelTileData.Type.ENTRY_UP,
			LevelData.LevelTileData.Type.ENTRY_DOWN,
			LevelData.LevelTileData.Type.ENTRY_LEFT,
			LevelData.LevelTileData.Type.ENTRY_RIGHT,
		]:
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
	SfxPlayer.play_sfx(&"slug")

	return true


func _do_slide(
	current_cell: Vector2i,
	destination: Vector2i,
	direction: Vector2i,
	level_data: LevelData,
) -> void:
	await _slide_to(current_cell, destination, direction)
	level_data.add_bug(self)
	is_moving = false


func _slide_to(from_cell: Vector2i, to_cell: Vector2i, direction: Vector2i) -> void:
	var step_count := maxi(
		absi(to_cell.x - from_cell.x),
		absi(to_cell.y - from_cell.y),
	)

	for step in step_count:
		var tween := _start_follow_step(direction)
		await tween.finished
	SfxPlayer.stop(&"slug")
