extends CurvedMeshBug

@export var SEGMENT_LENGTH := 4

@onready var head_mesh: MeshInstance2D = $Head
@onready var body_mesh: MeshInstance2D = $Body
@onready var tail_mesh: MeshInstance2D = $Tail
	
#initialise each segment of the bug 
func init_segments() -> void:
	var segment_count = SEGMENT_LENGTH
	mesh_segments = [head_mesh]
	for i in segment_count - 2:
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

	for i in segment_count:
		segment_cells.append(-facing_direction * i)

	_initialize_mesh_rendering()


func move(direction: Vector2i) -> bool:
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)

	if tile_data == null:
		print("Movement Error: Outside of Play Space")
		return false

	if not tile_data.is_empty():
		for bug in tile_data.bugs:
			if bug.get_name() != "Slug":
				print("Movement Error: Tile is Occupied")
				return false

	if tile_data.type in [
		LevelData.LevelTileData.Type.HARD,
		LevelData.LevelTileData.Type.INDESTRUCTIBLE,
	]:
		print("Movement Error: Can't move into hard tiles")
		return false

	if tile_data.type in [
		LevelData.LevelTileData.Type.ENTRY_UP,
		LevelData.LevelTileData.Type.ENTRY_DOWN,
		LevelData.LevelTileData.Type.ENTRY_LEFT,
		LevelData.LevelTileData.Type.ENTRY_RIGHT,
	]:
		print("Movement Error: Can't move back out of fruit")
		return false

	level_data.remove_bug(self)
	_start_follow_step(direction)
	level_data.add_bug(self)
	return true

func _on_body_texture_changed() -> void:
	get_node("Body2").texture = body_mesh.texture
