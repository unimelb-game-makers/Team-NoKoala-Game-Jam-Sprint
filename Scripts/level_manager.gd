extends Node2D
class_name LevelManager

var level_data: LevelData 
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

@onready var movement_controller: MovementController = $MovementController
@onready var bug_factory: BugFactory = $BugFactory
@onready var tile_map_layer: LevelTileMap = $TileMapLayer

func _ready() -> void:
	level_data = tile_map_layer.read_level_from_tilemap()
	level_data.print_debug_map()
	spawn_bug()

func spawn_bug() -> void:
	var bug = bug_factory.create_bug(GlobalVars.BugTypes.CATERPILLAR)
	add_child(bug)
	current_bug = bug
	var entries := level_data.get_cells_by_type(
		LevelData.LevelTileData.Type.ENTRY
	)
	if entries:
		bug.teleport(entries[0])
