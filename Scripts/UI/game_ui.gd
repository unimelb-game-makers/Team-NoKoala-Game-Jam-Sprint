extends CanvasLayer

@onready var status_message: Label = $Interface/StatusMessage
var status_tween: Tween

func _ready() -> void:
	var level_manager := get_tree().get_first_node_in_group(&"level_manager") as LevelManager
	level_manager.status_message_requested.connect(show_status_message)

func show_status_message(message: String) -> void:
	if status_tween != null and status_tween.is_valid():
		status_tween.kill()

	status_message.text = message
	status_message.modulate.a = 1.0
	status_message.show()

	status_tween = create_tween()
	status_tween.tween_interval(2.0)
	status_tween.tween_property(status_message, "modulate:a", 0.0, 0.3)
	status_tween.tween_callback(status_message.hide)
