extends Node2D

@onready var title_menu: Control = $CanvasLayer/TitleMenu
@onready var title_menu_buttons: Control = $CanvasLayer/TitleMenu/TitleMenuButtons
@onready var start_button: TextureButton = $CanvasLayer/TitleMenu/TitleMenuButtons/StartButton
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var camera: Camera2D = $LevelSelect/Camera2D
@onready var fruit_bowl: Node2D = $LevelSelect/FruitBowl

const TITLE_MENU_INIT_Y: float = -500
const TITLE_MENU_FINAL_Y: float = -28
const TITLE_CAMERA_ZOOM := Vector2(0.24, 0.24)
const LEVEL_SELECT_CAMERA_ZOOM := Vector2(0.58, 0.58)
const LEVEL_SELECT_CAMERA_POSITION := Vector2.ZERO

var transitioning: bool = false


func _ready() -> void:
	if TransitionLayer.entering_level_select:
		TransitionLayer.entering_level_select = false
		title_menu.hide()
		back_button.show()
		fruit_bowl.set_interactive(true)
		return

	back_button.hide()
	fruit_bowl.set_interactive(false)
	camera.global_position = fruit_bowl.global_position
	camera.zoom = TITLE_CAMERA_ZOOM
	title_menu.position.y = TITLE_MENU_INIT_Y

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_menu, "position:y", TITLE_MENU_FINAL_Y, 1.0)


func _on_start_button_pressed() -> void:
	if transitioning:
		return

	transitioning = true
	start_button.disabled = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "global_position", LEVEL_SELECT_CAMERA_POSITION, 1.0)
	tween.tween_property(camera, "zoom", LEVEL_SELECT_CAMERA_ZOOM, 1.0)
	tween.tween_property(title_menu, "position:y", TITLE_MENU_FINAL_Y - 80.0, 0.45)
	tween.tween_property(title_menu, "modulate:a", 0.0, 0.35)

	await tween.finished
	title_menu.hide()
	back_button.show()
	fruit_bowl.set_interactive(true)
	transitioning = false


func _on_back_button_pressed() -> void:
	if transitioning:
		return

	transitioning = true
	back_button.disabled = true
	fruit_bowl.set_interactive(false)

	title_menu.position.y = TITLE_MENU_FINAL_Y - 80.0
	title_menu.modulate.a = 0.0
	title_menu.show()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "global_position", fruit_bowl.global_position, 1.0)
	tween.tween_property(camera, "zoom", TITLE_CAMERA_ZOOM, 1.0)
	tween.tween_property(title_menu, "position:y", TITLE_MENU_FINAL_Y, 0.55).set_delay(0.35)
	tween.tween_property(title_menu, "modulate:a", 1.0, 0.4).set_delay(0.35)

	await tween.finished
	back_button.hide()
	back_button.disabled = false
	start_button.disabled = false
	transitioning = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
