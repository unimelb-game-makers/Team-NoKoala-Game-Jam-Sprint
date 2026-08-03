extends Node2D
class_name LevelManager

var level_data: LevelData
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug
## Retained until placement is committed so a selection can return to its jar.
var current_bug_handler: BugHandler
var previous_bug_before_selection: Bug

const level_select_scene := "res://Scenes/level_select.tscn"

@export var level_config: LevelConfig
@onready var movement_controller: MovementController = $MovementController
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

var star_count: int = 0

const ACTIVATED_ALT_ID = 1
const DEACTIVATED_ID = 0

signal config_changed(config: LevelConfig)

func _enter_tree() -> void:
	add_to_group(&"level_manager")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_bug_selection()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			# Pressing supports the existing click-to-place flow. Releasing supports
			# dragging a bug directly from its jar onto an entry tile.
			try_place_bug(event.position)

func _ready() -> void:
	level_data = LevelData.from_tilemap(tile_map_layer)
	level_data.print_debug_map()
	print(level_config.serialize())

	level_data.bonus_star_activated.connect(_on_bonus_star_activated)
	level_data.bonus_star_deactivated.connect(_on_bonus_star_deactivated)
	config_changed.emit(level_config)

func _process(_delta: float) -> void:
	if current_bug != null && !current_bug.is_placed:
		current_bug.set_free_position(tile_map_layer.to_local(get_global_mouse_position()))

func try_place_bug(mouse_pos: Vector2) -> void:
	if current_bug != null && !current_bug.is_placed:
		var pos_local := (
			tile_map_layer.get_global_transform_with_canvas().affine_inverse()
			* mouse_pos
		)
		var cell := tile_map_layer.local_to_map(pos_local)
		var tile_data := level_data.get_tile_data(cell)

		if tile_data == null or !tile_data.is_empty():
			return
		
		match tile_data.type:
			LevelData.LevelTileData.Type.ENTRY_UP:
				current_bug.set_facing_direction(Directions.UP)
			LevelData.LevelTileData.Type.ENTRY_DOWN:
				current_bug.set_facing_direction(Directions.DOWN)
			LevelData.LevelTileData.Type.ENTRY_LEFT:
				current_bug.set_facing_direction(Directions.LEFT)
			LevelData.LevelTileData.Type.ENTRY_RIGHT:
				current_bug.set_facing_direction(Directions.RIGHT)
			_:
				return

		var source_jar := current_bug_handler.get_parent() as Jar
		movement_controller.record_placement(
			current_bug,
			source_jar,
			previous_bug_before_selection
		)
		current_bug.place(cell)
		if current_bug_handler != null:
			current_bug_handler.complete_selection()
			current_bug_handler = null
		previous_bug_before_selection = null

func begin_bug_selection(bug: Bug, handler: BugHandler) -> void:
	if current_bug_handler != null:
		cancel_bug_selection()

	previous_bug_before_selection = current_bug if current_bug != bug else null
	current_bug = bug
	current_bug_handler = handler
	handler.begin_selection()

func cancel_bug_selection() -> void:
	if current_bug == null or current_bug.is_placed or current_bug_handler == null:
		return

	current_bug_handler.cancel_selection()
	current_bug = previous_bug_before_selection
	previous_bug_before_selection = null
	current_bug_handler = null

func _unhandled_input(event: InputEvent) -> void:
	# placeholder until actual exit level logic
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		exit_level()
	elif event.is_action_pressed("reset"):
		reset_level()

func reset_level() -> void:
	get_tree().reload_current_scene()

func _on_bonus_star_activated(cell: Vector2i) -> void:
	var source_id = tile_map_layer.get_cell_source_id(cell)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell)
	tile_map_layer.set_cell(cell, source_id, atlas_coords, ACTIVATED_ALT_ID)

func _on_bonus_star_deactivated(cell: Vector2i) -> void:
	var source_id = tile_map_layer.get_cell_source_id(cell)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell)
	tile_map_layer.set_cell(cell, source_id, atlas_coords, DEACTIVATED_ID)

func exit_level() -> void:
	get_tree().paused = false

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
