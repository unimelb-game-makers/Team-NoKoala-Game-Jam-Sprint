class_name BoardDropArea
extends Control

@onready var level_manager: LevelManager = get_parent().get_parent()



func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		print("no data in dictionary")
		return false

	if data.get("kind") != "bug":
		print("not bug")
		return false

	var cell := get_mouse_cell()
	var tile_data := level_manager.level_data.get_tile_data(cell)
	return tile_data != null and tile_data.is_empty() and tile_data.type == LevelData.LevelTileData.Type.ENTRY


func _drop_data(_position: Vector2, data: Variant) -> void:
	var cell := get_mouse_cell()
	place_bug(data["bug_type"], cell)


func get_mouse_cell() -> Vector2i:
	var viewport_mouse := get_viewport().get_mouse_position()
	var tile_map = level_manager.tile_map_layer
	var tile_local := (
		tile_map.get_global_transform_with_canvas().affine_inverse()
		* viewport_mouse
	)

	return tile_map.local_to_map(tile_local)


func place_bug(bug_type: GlobalVars.BugTypes, cell: Vector2i) -> void:
	var bug := level_manager.spawn_bug(bug_type)
	var tile_map = level_manager.tile_map_layer

	bug.teleport(cell)
