extends Node2D
class_name LevelManager

var level_data: LevelData
## Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug
var previous_bug_before_selection: Bug
const title_screen_scene := "res://Scenes/title_screen.tscn"

@export var level_config: LevelConfig
@onready var movement_controller: MovementController = $MovementController
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
@onready var interface = $UI/Interface

var star_count: int = 0

const ACTIVATED_ALT_ID = 1
const DEACTIVATED_ID = 0
const SELECTED_BUG_Z_INDEX = 100

signal config_changed(config: LevelConfig)
signal status_message_requested(message: String)

func _enter_tree() -> void:
	add_to_group(&"level_manager")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_bug_selection()
		elif event.button_index == MOUSE_BUTTON_LEFT:
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

		movement_controller.record_placement(
			current_bug,
			previous_bug_before_selection
		)
		current_bug.z_index = 0
		current_bug.place(cell)
		var selection_menu := get_tree().get_first_node_in_group(&"bug_selection_menu") as BugSelectionMenu
		if selection_menu != null:
			selection_menu.consume_bug(current_bug.type)
		previous_bug_before_selection = null

func begin_bug_selection(bug_type: GlobalVars.BugTypes) -> void:
	if _has_occupied_entry_point():
		status_message_requested.emit("Move the bug off the entry point first")
		return
	
	if current_bug != null and not current_bug.is_placed:
		cancel_bug_selection()
	
	if current_bug != null:
		current_bug.stop_wriggle()

	previous_bug_before_selection = current_bug
	var bug := BugFactory.create_bug(bug_type)
	tile_map_layer.add_child(bug)
	bug.z_index = SELECTED_BUG_Z_INDEX
	current_bug = bug
	current_bug.start_wriggle()

func _has_occupied_entry_point() -> bool:
	for tile_data in level_data.get_tile_datas():
		if tile_data.type in [
			LevelData.LevelTileData.Type.ENTRY_UP,
			LevelData.LevelTileData.Type.ENTRY_DOWN,
			LevelData.LevelTileData.Type.ENTRY_LEFT,
			LevelData.LevelTileData.Type.ENTRY_RIGHT,
		] and not tile_data.is_empty():
			return true

	return false

func cancel_bug_selection() -> void:
	if current_bug == null or current_bug.is_placed:
		return

	current_bug.queue_free()
	current_bug = previous_bug_before_selection
	previous_bug_before_selection = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		interface.toggle_pause_menu()
		get_viewport().set_input_as_handled()
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
	SfxPlayer.play_sfx(&"crunch_reverse", -5.0)
	
	get_tree().paused = false
	TransitionLayer.entering_level_select = true

	# zoom out slightly
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "zoom", Vector2(0.5, 0.5), 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(TransitionLayer.fade_rect, "modulate:a", 1.0, 0.4).set_delay(0.6)
	
	await tween.finished
	
	# change scenes
	if title_screen_scene:
		get_tree().change_scene_to_file(title_screen_scene)
	
	await TransitionLayer.get_tree().process_frame
	await TransitionLayer.fade_in()
