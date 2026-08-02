extends Node2D
class_name LevelManager

var level_data: LevelData = AllLevels.LEVEL_1
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

const level_select_scene := "res://Scenes/level_select.tscn"

@onready var movement_controller: MovementController = $MovementController
@onready var bug_factory: BugFactory = $BugFactory
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	spawn_bug()

func spawn_bug() -> void:
	var bug = bug_factory.create_bug(GlobalVars.BugTypes.CATERPILLAR)
	add_child(bug)
	current_bug = bug
	bug.teleport(level_data.start_cell)

func _unhandled_input(event: InputEvent) -> void:
	# placeholder until actual exit level logic
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		exit_level()

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
