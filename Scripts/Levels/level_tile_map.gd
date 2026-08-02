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

		match tile_name:
			"normal_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.NORMAL
				)

			"entry_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.ENTRY
				)

			"hard_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.HARD
				)

			"hard_broken_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.HARD_BROKEN
				)

			"indestructible_cell":
				level.add_tile(
					cell,
					LevelData.LevelTileData.Type.INDESTRUCTIBLE
				)

			_:
				push_warning("Unknown tile source: " + tile_name)
	return level
