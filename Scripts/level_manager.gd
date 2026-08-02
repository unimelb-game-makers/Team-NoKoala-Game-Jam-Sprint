extends Node2D
class_name LevelManager

var level_data: LevelData 
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

const level_select_scene := "res://Scenes/level_select.tscn"

@onready var movement_controller: MovementController = $MovementController
@onready var bug_factory: BugFactory = $BugFactory
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var level_tile_map: LevelTileMap = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

const ACTIVATED_ALT_ID = 1
const DEACTIVATED_ID = 0

func _enter_tree() -> void:
	add_to_group(&"level_manager")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_bug_debug"):
		spawn_bug(GlobalVars.BugTypes.SLUG)

func _ready() -> void:
	level_data = tile_map_layer.read_level_from_tilemap()
	level_data.print_debug_map()
	
	level_data.bonus_star_activated.connect(_on_bonus_star_activated)
	level_data.bonus_star_deactivated.connect(_on_bonus_star_deactivated)
	#spawn_bug(GlobalVars.BugTypes.CATERPILLAR)

func spawn_bug(bug_type: GlobalVars.BugTypes, length: int = -1) -> Bug:
	var bug = bug_factory.create_bug(bug_type, length)
	add_child(bug)
	current_bug = bug
	return bug

func _unhandled_input(event: InputEvent) -> void:
	# placeholder until actual exit level logic
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		exit_level()

func _on_bonus_star_activated(cell: Vector2i) -> void:
	var source_id = tile_map_layer.get_cell_source_id(cell)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell)
	tile_map_layer.set_cell(cell, source_id, atlas_coords, ACTIVATED_ALT_ID)

func _on_bonus_star_deactivated(cell: Vector2i) -> void:
	var source_id = tile_map_layer.get_cell_source_id(cell)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell)
	tile_map_layer.set_cell(cell, source_id, atlas_coords, DEACTIVATED_ID)

func exit_level() -> void:
	
	# zoom out slightly
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "zoom", Vector2(0.5, 0.5), 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(TransitionLayer.fade_rect, "modulate:a", 1.0, 0.4).set_delay(0.6)
	
	await tween.finished
	
	# change scenes
	if (level_select_scene):
		get_tree().change_scene_to_file(level_select_scene)
	
	await TransitionLayer.get_tree().process_frame
	await TransitionLayer.fade_in()
