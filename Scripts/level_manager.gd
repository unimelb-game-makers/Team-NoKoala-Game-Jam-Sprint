extends Node2D
class_name LevelManager

var level_data: LevelData = AllLevels.LEVEL_1
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

@onready var movement_controller: MovementController = $MovementController
@onready var bug_factory: BugFactory = $BugFactory
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
	spawn_bug()

func spawn_bug() -> void:
	var bug = bug_factory.create_bug(GlobalVars.BugTypes.SLUG, 3)
	add_child(bug)
	current_bug = bug
	bug.teleport(level_data.start_cell)
