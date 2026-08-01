extends Node
class_name MovementController

@onready var level_manager: LevelManager = get_parent()

func _input(event: InputEvent) -> void:
	if level_manager.current_bug == null:
		return
		
	if event.is_action_pressed("up"):
		level_manager.current_bug.move(Directions.UP)
	elif event.is_action_pressed("left"):
		level_manager.current_bug.move(Directions.LEFT)
	elif event.is_action_pressed("down"):
		level_manager.current_bug.move(Directions.DOWN)
	elif event.is_action_pressed("right"):
		level_manager.current_bug.move(Directions.RIGHT)
