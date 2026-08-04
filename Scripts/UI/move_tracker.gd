class_name MoveTracker
extends Label 

@onready var movement_controller := (
	get_tree().get_first_node_in_group(&"movement_controller") as MovementController
)

func _ready() -> void:
	movement_controller.move_committed.connect(_on_move)
	_on_move(movement_controller.current_move, movement_controller.max_move)


func _on_move(current: int, maximum: int) -> void:
	text = "%d / %d move used" % [maximum-current, maximum]

func _on_undo_btn_pressed() -> void:
	var player = SfxPlayer.play_sfx(&'undo')
	await player.finished
	movement_controller.undo()
