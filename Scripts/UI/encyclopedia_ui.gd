extends Panel

@onready var anim_player = $AnimationPlayer
@onready var texture_rect = $TextureRect
@onready var prev_page_btn = $TextureRect/FlipPrevPageBtn
@onready var next_page_btn = $TextureRect/FlipNextPageBtn
@onready var page_flip_frame: TextureRect = $TextureRect/PageFlipFrame
@onready var pages: Array[Control] = [
	$TextureRect/Page0,
	$TextureRect/Page1,
	$TextureRect/Page2,
	$TextureRect/Page3,
	$TextureRect/Page4,
]

@export var book_normal_texture: Texture2D
@export var book_next_texture: Texture2D
@export var book_prev_texture: Texture2D
@export var book_no_worms: Texture2D
@export var book_no_worms_prev_texture: Texture2D
@export var book_no_worms_next_texture: Texture2D
@export var book_frame_1: Texture2D
@export var book_frame_2: Texture2D

var current_page: int = 0
var page_flip_tween: Tween

const ANIM_SPEED: float = 1.7
const LAST_REGULAR_PAGE: int = 3
const FINAL_PAGE: int = 4
const PAGE_FADE_DURATION: float = 0.4 / ANIM_SPEED
const PAGE_HIDE_DELAY: float = 0.43333334 / ANIM_SPEED
const PAGE_SHOW_DELAY: float = 0.5 / ANIM_SPEED
const PAGE_FADE_IN_DELAY: float = 0.53333336 / ANIM_SPEED
const FLIP_FRAME_DURATION: float = 0.1

func _ready() -> void:
	ProgressState.all_levels_completed.connect(_on_all_levels_completed)

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("left"): _on_flip_prev_page_btn_pressed()
		if event.is_action_pressed("right"): _on_flip_next_page_btn_pressed()

func _on_exit_btn_pressed() -> void:
	if _is_busy(): return
	SfxPlayer.play_sfx(&'button_click')
	GlobalVars.pause_movement = false
	anim_player.play("show_encyclopedia", -1, -ANIM_SPEED, true)

func _on_flip_next_page_btn_pressed() -> void:
	if _is_busy() or current_page >= _last_unlocked_page(): return
	SfxPlayer.play_sfx(&'page_turn')
	_set_book_texture(book_normal_texture, book_no_worms)
	_flip_to_page(current_page + 1)

func _on_flip_prev_page_btn_pressed() -> void:
	if _is_busy() or current_page <= 0: return
	SfxPlayer.play_sfx(&'page_turn')
	_set_book_texture(book_normal_texture, book_no_worms)
	_flip_to_page(current_page - 1)

func _flip_to_page(target_page: int) -> void:
	var outgoing_page := pages[current_page]
	var incoming_page := pages[target_page]
	var flipping_forward := target_page > current_page

	incoming_page.modulate.a = 0.0
	page_flip_tween = create_tween().set_parallel(true)
	page_flip_tween.tween_property(
		outgoing_page, "modulate:a", 0.0, PAGE_FADE_DURATION
	)
	page_flip_tween.tween_callback(
		func() -> void: outgoing_page.visible = false
	).set_delay(PAGE_HIDE_DELAY)
	page_flip_tween.tween_callback(
		func() -> void: incoming_page.visible = true
	).set_delay(PAGE_SHOW_DELAY)
	page_flip_tween.tween_property(
		incoming_page, "modulate:a", 1.0, PAGE_FADE_DURATION
	).set_delay(PAGE_FADE_IN_DELAY)
	_play_book_flip_frames(flipping_forward)

	if current_page == 0 or target_page == 0:
		_fade_page_button(prev_page_btn, target_page > 0, flipping_forward)
	var last_page := _last_unlocked_page()
	if current_page == last_page or target_page == last_page:
		_fade_page_button(next_page_btn, target_page < last_page, flipping_forward)

	current_page = target_page
	page_flip_tween.finished.connect(_on_page_flip_finished)

func _play_book_flip_frames(flipping_forward: bool) -> void:
	var first_frame := book_frame_1 if flipping_forward else book_frame_2
	var second_frame := book_frame_2 if flipping_forward else book_frame_1
	var frame_start := PAGE_HIDE_DELAY

	page_flip_tween.tween_callback(func() -> void:
		page_flip_frame.texture = first_frame
		page_flip_frame.visible = true
	).set_delay(frame_start)
	page_flip_tween.tween_callback(func() -> void:
		page_flip_frame.texture = second_frame
	).set_delay(frame_start + FLIP_FRAME_DURATION)
	page_flip_tween.tween_callback(func() -> void:
		page_flip_frame.visible = false
	).set_delay(frame_start + FLIP_FRAME_DURATION * 2.0)

func _fade_page_button(button: TextureButton, fade_in: bool, flipping_forward: bool) -> void:
	var delay := PAGE_FADE_IN_DELAY if flipping_forward else 0.0
	page_flip_tween.tween_property(
		button, "modulate:a", float(fade_in), PAGE_FADE_DURATION
	).set_delay(delay)

func _is_busy() -> bool:
	return anim_player.is_playing() or page_flip_tween != null

func _on_page_flip_finished() -> void:
	page_flip_tween = null
	_set_book_texture(book_normal_texture, book_no_worms)
	if current_page > 0 and prev_page_btn.is_hovered():
		_set_book_texture(book_prev_texture, book_no_worms_prev_texture)
	elif current_page < _last_unlocked_page() and next_page_btn.is_hovered():
		_set_book_texture(book_next_texture, book_no_worms_next_texture)

func _last_unlocked_page() -> int:
	return FINAL_PAGE if ProgressState.are_all_levels_completed() else LAST_REGULAR_PAGE

func _on_all_levels_completed() -> void:
	for page: Control in pages:
		page.visible = false
		page.modulate.a = 1.0

	current_page = FINAL_PAGE
	pages[current_page].visible = true
	page_flip_frame.visible = false
	prev_page_btn.modulate.a = 1.0
	next_page_btn.modulate.a = 0.0
	_set_book_texture(book_normal_texture, book_no_worms)
	GlobalVars.pause_movement = true
	anim_player.play("show_encyclopedia", -1.0, 1.3)

func _set_book_texture(page_zero_texture: Texture2D, later_page_texture: Texture2D) -> void:
	texture_rect.texture = later_page_texture if current_page > 0 else page_zero_texture

func _on_flip_next_page_btn_mouse_entered() -> void:
	if current_page != _last_unlocked_page():
		_set_book_texture(book_next_texture, book_no_worms_next_texture)

func _on_flip_next_page_btn_mouse_exited() -> void:
	_set_book_texture(book_normal_texture, book_no_worms)

func _on_flip_prev_page_btn_mouse_entered() -> void:
	if current_page != 0:
		_set_book_texture(book_prev_texture, book_no_worms_prev_texture)

func _on_flip_prev_page_btn_mouse_exited() -> void:
	_set_book_texture(book_normal_texture, book_no_worms)
