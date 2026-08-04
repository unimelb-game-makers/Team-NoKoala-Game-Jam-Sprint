extends Control

@onready var level_manager = $"../../"
@onready var pause_menu = $PauseMenuUI
@onready var encyclopedia_menu = $EncyclopediaUI

func _ready() -> void:
	if GlobalVars.players_first_level:
		GlobalVars.players_first_level = false
		_on_encyclopedia_btn_pressed()

func _on_reset_btn_pressed() -> void:
	var player = SfxPlayer.play_sfx(&'reset')
	await player.finished
	level_manager.reset_level()

func _on_pause_menu_btn_pressed() -> void:
	GlobalVars.pause_movement = true
	var player = SfxPlayer.play_sfx(&'button_click')
	await player.finished
	pause_menu.show()
	Engine.time_scale = 0

func _on_pause_menu_level_select_requested() -> void:
	level_manager.exit_level()

func _on_encyclopedia_btn_pressed() -> void:
	if GlobalVars.players_first_level == false:
		SfxPlayer.play_sfx(&'button_click')
	GlobalVars.pause_movement = true
	encyclopedia_menu.anim_player.play("show_encyclopedia", -1.0, 1.3)
