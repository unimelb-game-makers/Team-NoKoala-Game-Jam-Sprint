class_name LevelTileMap
extends TileMapLayer

func read_level_from_tilemap() -> LevelData:
	var level := LevelData.new()

	for cell in get_used_cells():
		var source_id := get_cell_source_id(cell)

		if source_id == -1:
			continue

		var source := tile_set.get_source(source_id)
		var tile_name := source.resource_name
		var atlas_coordinates := get_cell_atlas_coords(cell)

		match tile_name:
			"normal_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.NORMAL
				)

			"entry_cell":
				match atlas_coordinates:
					Vector2i(0,0):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_DOWN
						)
					Vector2i(1,0):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_UP
						)
					Vector2i(0,1):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_RIGHT
						)
					Vector2i(1,1):
						level.add_tile(
							cell,
							LevelData.LevelTileData.Type.ENTRY_LEFT
						)
					#level.add_tile(
					#	cell,
					#	LevelData.LevelTileData.Type.ENTRY
					#)

			_:
				push_warning("Unknown tile source: " + tile_name)
	return level
