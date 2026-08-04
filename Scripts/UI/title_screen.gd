extends Node2D

@onready var title_menu: Control = $CanvasLayer/TitleMenu
@onready var title_menu_buttons: Control = $CanvasLayer/TitleMenu/TitleMenuButtons

const TITLE_MENU_INIT_Y: float = -500
const TITLE_MENU_FINAL_Y: float = -24


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_menu.position.y = TITLE_MENU_INIT_Y

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_menu, "position:y", TITLE_MENU_FINAL_Y, 1.0)

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
