extends Control

@onready var level_manager = $"../../"
@onready var pause_menu = $PauseMenuUI
@onready var encyclopedia_menu = $EncyclopediaUI

func _ready() -> void:
	if GlobalVars.players_first_level:
		GlobalVars.players_first_level = false
		_on_encyclopedia_btn_pressed()

func _on_reset_btn_pressed() -> void:
	level_manager.reset_level()

func _on_pause_menu_btn_pressed() -> void:
	GlobalVars.pause_movement = true
	pause_menu.show()
	Engine.time_scale = 0

func _on_encyclopedia_btn_pressed() -> void:
	GlobalVars.pause_movement = true
	encyclopedia_menu.anim_player.play("show_encyclopedia", -1.0, 1.3)
