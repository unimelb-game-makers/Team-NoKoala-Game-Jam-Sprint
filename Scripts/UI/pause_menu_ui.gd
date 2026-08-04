extends Panel

@onready var level_manager = $"../../../"

func _on_exit_btn_pressed() -> void:
	hide()
	GlobalVars.pause_movement = false
	Engine.time_scale = 1.0

func _on_level_select_btn_pressed() -> void:
	GlobalVars.pause_movement = false
	Engine.time_scale = 1.0
	level_manager.exit_level()
	hide()
