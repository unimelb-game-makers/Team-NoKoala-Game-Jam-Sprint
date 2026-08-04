extends Panel

signal level_select_requested

@export var show_level_select_button: bool = true

@onready var level_select_button: Button = $TextureRect/VBoxContainer/LevelSelectBtn


func _ready() -> void:
	visible = false
	level_select_button.visible = show_level_select_button


func close() -> void:
	hide()
	GlobalVars.pause_movement = false
	Engine.time_scale = 1.0


func _on_exit_btn_pressed() -> void:
	close()

func _on_level_select_btn_pressed() -> void:
	GlobalVars.pause_movement = false
	Engine.time_scale = 1.0
	level_select_requested.emit()
	hide()
