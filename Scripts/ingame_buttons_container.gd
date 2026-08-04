extends HBoxContainer

@onready var level_manager = $"../../../"

func _on_reset_btn_pressed() -> void:
	level_manager.reset_level()
