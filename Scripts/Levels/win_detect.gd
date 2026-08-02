extends Node

@onready var movement_controller := (
	get_tree().get_first_node_in_group(&"movement_controller") as MovementController
)
func _ready() -> void:
	movement_controller.move_committed.connect(win_detect)
	win_detect(movement_controller.current_move, movement_controller.max_move)


func win_detect(current: float, maximum: float) -> void:
	pass
