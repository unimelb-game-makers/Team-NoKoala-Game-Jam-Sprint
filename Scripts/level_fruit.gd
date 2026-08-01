extends Area2D

func _on_mouse_entered() -> void:
	get_parent().register_hover(self)


func _on_mouse_exited() -> void:
	get_parent().unregister_hover(self)

func set_hovered(is_hovered: bool) -> void:
	var tween = create_tween()
	if (is_hovered):
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
