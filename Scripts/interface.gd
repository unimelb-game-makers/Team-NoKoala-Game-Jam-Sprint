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
	open_pause_menu()

func open_pause_menu() -> void:
	if pause_menu.visible:
		return

	GlobalVars.pause_movement = true
	SfxPlayer.play_sfx(&'button_click')
	pause_menu.show()
	Engine.time_scale = 0

func toggle_pause_menu() -> void:
	if pause_menu.visible:
		pause_menu.close()
	else:
		open_pause_menu()

func _on_pause_menu_level_select_requested() -> void:
	level_manager.exit_level()

func _on_encyclopedia_btn_pressed() -> void:
	if GlobalVars.players_first_level == false:
		SfxPlayer.play_sfx(&'button_click')
	GlobalVars.pause_movement = true
	encyclopedia_menu.anim_player.play("show_encyclopedia", -1.0, 1.3)
