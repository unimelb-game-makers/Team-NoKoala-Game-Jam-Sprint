extends Node2D

@onready var title_menu: Control = $CanvasLayer/TitleMenu
@onready var title_menu_buttons: Control = $CanvasLayer/TitleMenu/TitleMenuButtons
@onready var start_button: TextureButton = $CanvasLayer/TitleMenu/TitleMenuButtons/StartButton
@onready var options_button: TextureButton = $CanvasLayer/TitleMenu/TitleMenuButtons/OptionsButton
@onready var quit_button: TextureButton = $CanvasLayer/TitleMenu/TitleMenuButtons/QuitButton
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var options_menu: Panel = $CanvasLayer/PauseMenuUI
@onready var camera: Camera2D = $LevelSelect/Camera2D
@onready var fruit_bowl: Node2D = $LevelSelect/FruitBowl

const TITLE_MENU_INIT_Y: float = -500
const TITLE_MENU_FINAL_Y: float = -28
const TITLE_CAMERA_ZOOM := Vector2(0.24, 0.24)
const LEVEL_SELECT_CAMERA_ZOOM := Vector2(0.58, 0.58)
const LEVEL_SELECT_CAMERA_POSITION := Vector2.ZERO
const BUTTON_CONFIRM_OFFSET_X: float = 24.0
const BUTTON_CONFIRM_MOVE_DURATION: float = 0.12
const BUTTON_CONFIRM_WAIT_DURATION: float = 0.3

var transitioning: bool = false
var title_button_animating: bool = false


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
	SfxPlayer.play_sfx(&"button_click")
	play_title_button_action(start_button, _show_level_select)


func _on_options_button_pressed() -> void:
	SfxPlayer.play_sfx(&"button_click")
	play_title_button_action(options_button, _open_options)


func _on_quit_button_pressed() -> void:
	SfxPlayer.play_sfx(&"button_click")
	play_title_button_action(quit_button, _quit_game)


func play_title_button_action(button: BaseButton, callback: Callable) -> void:
	if title_button_animating or transitioning:
		return

	title_button_animating = true
	set_title_buttons_disabled(true)
	var original_x := button.position.x

	var move_tween := create_tween()
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.tween_property(
		button,
		"position:x",
		original_x + BUTTON_CONFIRM_OFFSET_X,
		BUTTON_CONFIRM_MOVE_DURATION
	)
	await move_tween.finished
	await get_tree().create_timer(BUTTON_CONFIRM_WAIT_DURATION).timeout

	set_title_buttons_disabled(false)
	callback.call()

	var return_tween := create_tween()
	return_tween.set_trans(Tween.TRANS_CUBIC)
	return_tween.set_ease(Tween.EASE_OUT)
	return_tween.tween_property(
		button,
		"position:x",
		original_x,
		BUTTON_CONFIRM_MOVE_DURATION
	)
	await return_tween.finished
	title_button_animating = false


func set_title_buttons_disabled(value: bool) -> void:
	start_button.disabled = value
	options_button.disabled = value
	quit_button.disabled = value


func _show_level_select() -> void:
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


func _open_options() -> void:
	options_menu.show()


func _on_back_button_pressed() -> void:
	SfxPlayer.play_sfx(&"button_click")
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


func _quit_game() -> void:
	get_tree().quit()
