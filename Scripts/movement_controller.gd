extends Node
class_name MovementController

@onready var level_manager: LevelManager = get_parent()
func _enter_tree() -> void: add_to_group(&"movement_controller")

@export var max_move: int = 20
var current_move: int 
signal move_committed(current: float, maximum: float)

func _ready() -> void:
	level_manager.config_changed.connect(_on_config_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
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
	if current_move <= 0:
		print("Movement Error: Run out of Moves")
		return false
	if !level_manager.current_bug.move(direction):
		return false
	current_move -= 1
	move_committed.emit(current_move, max_move)
	return true

func _on_config_changed(config: LevelConfig) -> void:
	max_move = config.max_move
	current_move = max_move
	move_committed.emit(current_move, max_move)
