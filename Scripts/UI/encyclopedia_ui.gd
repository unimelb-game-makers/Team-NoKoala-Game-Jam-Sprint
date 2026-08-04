extends Panel

@onready var anim_player = $AnimationPlayer
@onready var prev_page_btn = $TextureRect/FlipPrevPageBtn
@onready var next_page_btn = $TextureRect/FlipNextPageBtn
var current_page: int = 0
const ANIM_SPEED: float = 1.7

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("left"): _on_flip_prev_page_btn_pressed()
		if event.is_action_pressed("right"): _on_flip_next_page_btn_pressed()

func _on_exit_btn_pressed() -> void:
	if anim_player.is_playing(): return
	SfxPlayer.play_sfx(&'button_click')
	GlobalVars.pause_movement = false
	anim_player.play("show_encyclopedia", -1, -ANIM_SPEED, true)

func _on_flip_next_page_btn_pressed() -> void:
	if anim_player.is_playing(): return
	SfxPlayer.play_sfx(&'page_turn')
	if current_page <= 0: current_page = 0
	
	current_page += 1
	
	match current_page:
		1: anim_player.play("flip_to_page_1", -1, ANIM_SPEED)
		2: anim_player.play("flip_to_page_2", -1, ANIM_SPEED)
		3: anim_player.play("flip_to_page_3", -1, ANIM_SPEED)

func _on_flip_prev_page_btn_pressed() -> void:
	if anim_player.is_playing(): return
	SfxPlayer.play_sfx(&'page_turn')
	if current_page >= 3: current_page = 3
	
	current_page -= 1
	
	match current_page:
		0: anim_player.play("flip_to_page_1", -1, -ANIM_SPEED, true)
		1: anim_player.play("flip_to_page_2", -1, -ANIM_SPEED, true)
		2: anim_player.play("flip_to_page_3", -1, -ANIM_SPEED, true)
