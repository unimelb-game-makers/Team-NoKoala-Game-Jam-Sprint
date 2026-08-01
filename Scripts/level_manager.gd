extends Node2D
class_name LevelManager

var level_data: LevelData 
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

@onready var movement_controller: MovementController = $MovementController
@onready var bug_factory: BugFactory = $BugFactory
@onready var tile_map_layer: LevelTileMap = $TileMapLayer

func _enter_tree() -> void:
	add_to_group(&"level_manager")
		
func _ready() -> void:
	level_data = tile_map_layer.read_level_from_tilemap()
	level_data.print_debug_map()


func spawn_bug(bug_type: GlobalVars.BugTypes = GlobalVars.BugTypes.CATERPILLAR) -> Bug:
	var bug = bug_factory.create_bug(bug_type)
	add_child(bug)
	current_bug = bug
	return bug
