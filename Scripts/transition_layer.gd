extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

# to be passed between scenes
var zoom_target: Vector2
var zoom_colour: Color = Color.BLACK
var zoom_amount: Vector2 = Vector2(4, 4)
var zoom_fruit_id: String = ""
var entering_level_select: bool = false

func fade_out(duration: float = 0.15) -> void:
	fade_rect.color = zoom_colour
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
