class_name BugDragIcon
extends TextureRect

@export var bug_type: GlobalVars.BugTypes = GlobalVars.BugTypes.CATERPILLAR
@export var hover_scale := 1.2
@export var animation_duration := 0.12

var scale_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = size * 0.5

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size * 0.5


func _on_mouse_entered() -> void:
	animate_scale(Vector2.ONE * hover_scale)


func _on_mouse_exited() -> void:
	animate_scale(Vector2.ONE)


func animate_scale(target_scale: Vector2) -> void:
	if scale_tween != null:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(
		self,
		"scale",
		target_scale,
		animation_duration
	)
func _get_drag_data(_at_position: Vector2) -> Variant:
	var data := {
		"kind": "bug",
		"bug_type": bug_type,
		"texture": texture
	}

	var preview := TextureRect.new()
	preview.texture = texture
	preview.custom_minimum_size = Vector2(48, 48)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)

	return data
