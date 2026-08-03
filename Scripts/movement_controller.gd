extends Node
class_name MovementController

@onready var level_manager: LevelManager = get_parent()
func _enter_tree() -> void: add_to_group(&"movement_controller")

var max_move: int = 50
var current_move: int 
var undo_stack: Array[Dictionary] = []
signal move_committed(current: float, maximum: float)

func _ready() -> void:
	level_manager.config_changed.connect(_on_config_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		undo()
	elif event.is_action_pressed("up"):
		commit_move(Directions.UP)
	elif event.is_action_pressed("left"):
		commit_move(Directions.LEFT)
	elif event.is_action_pressed("down"):
		commit_move(Directions.DOWN)
	elif event.is_action_pressed("right"):
		commit_move(Directions.RIGHT)
	
func commit_move(direction: Vector2i) -> bool:
	if level_manager.current_bug == null:
		return false
	if !level_manager.current_bug.is_placed:
		return false

	var bug := level_manager.current_bug
	var action := _capture_action(bug, &"move")
	if !bug.move(direction):
		_restore_action_state(action)
		return false

	undo_stack.append(action)
	current_move -= 1
	move_committed.emit(current_move, max_move)
	return true

func record_placement(bug: Bug, previous_bug: Bug) -> void:
	var action := _capture_action(bug, &"placement")
	action[&"previous_bug"] = previous_bug
	undo_stack.append(action)

func undo() -> bool:
	if level_manager.current_bug != null and not level_manager.current_bug.is_placed:
		level_manager.cancel_bug_selection()

	if undo_stack.is_empty():
		return false

	var action: Dictionary = undo_stack.pop_back()
	var bug: Bug = action[&"bug"]
	_restore_action_state(action)

	if action[&"kind"] == &"placement":
		var selection_menu := get_tree().get_first_node_in_group(&"bug_selection_menu") as BugSelectionMenu
		if selection_menu != null:
			selection_menu.return_bug(bug.type)
		bug.queue_free()
		level_manager.current_bug = action[&"previous_bug"]
	else:
		level_manager.current_bug = bug

	move_committed.emit(current_move, max_move)
	return true

func _capture_action(bug: Bug, kind: StringName) -> Dictionary:
	return {
		&"kind": kind,
		&"bug": bug,
		&"bug_state": bug.capture_state(),
		&"map_state": _capture_map_state(),
		&"moves_before": current_move,
	}

func _restore_action_state(action: Dictionary) -> void:
	var bug: Bug = action[&"bug"]
	bug.restore_state(action[&"bug_state"])
	_restore_map_state(action[&"map_state"])
	current_move = action[&"moves_before"]

func _capture_map_state() -> Dictionary:
	var state: Dictionary = {}
	var tile_map: TileMapLayer = level_manager.tile_map_layer
	for cell in level_manager.level_data.get_cells():
		var tile_data: LevelData.LevelTileData = level_manager.level_data.get_tile_data(cell)
		state[cell] = {
			&"type": tile_data.type,
			&"required_bug_type": tile_data.required_bug_type,
			&"source_id": tile_map.get_cell_source_id(cell),
			&"atlas_coordinates": tile_map.get_cell_atlas_coords(cell),
			&"alternative_tile": tile_map.get_cell_alternative_tile(cell),
		}
	return state

func _restore_map_state(state: Dictionary) -> void:
	var tile_map: TileMapLayer = level_manager.tile_map_layer
	for cell: Vector2i in state:
		var tile_state: Dictionary = state[cell]
		var tile_data: LevelData.LevelTileData = level_manager.level_data.get_tile_data(cell)
		tile_data.type = tile_state[&"type"]
		tile_data.required_bug_type = tile_state[&"required_bug_type"]
		tile_map.set_cell(
			cell,
			tile_state[&"source_id"],
			tile_state[&"atlas_coordinates"],
			tile_state[&"alternative_tile"]
		)

func _on_config_changed(config: LevelConfig) -> void:
	max_move = config.max_move
	current_move = max_move
	undo_stack.clear()
	move_committed.emit(current_move, max_move)
