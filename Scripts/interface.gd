extends Control

@onready var level_manager = $"../../"
@onready var pause_menu = $PauseMenuUI

func _on_reset_btn_pressed() -> void:
	level_manager.reset_level()

func _on_pause_menu_btn_pressed() -> void:
	pause_menu.show()
	Engine.time_scale = 0
	
