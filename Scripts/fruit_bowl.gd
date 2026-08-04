extends Node2D

var hovered_fruits: Array[Area2D] = []
var active_fruit: Area2D = null
var interactive: bool = true


func set_interactive(value: bool) -> void:
	interactive = value
	for child in get_children():
		if child is Area2D:
			child.input_pickable = value

	if not value:
		if active_fruit:
			active_fruit.set_hovered(false)
		hovered_fruits.clear()
		active_fruit = null

func register_hover(fruit: Area2D) -> void:
	if not interactive:
		return
	SfxPlayer.play_sfx(&'swish', -8.0, randf_range(0.9, 1.1))
	hovered_fruits.append(fruit)
	update_active()
	
func unregister_hover(fruit: Area2D) -> void:
	hovered_fruits.erase(fruit)
	update_active()

func update_active() -> void:
	var new_active: Area2D = null
	
	if (hovered_fruits.size() > 0):
		new_active = hovered_fruits.back()
	
	if new_active != active_fruit:
		if active_fruit:
			active_fruit.set_hovered(false)
		active_fruit = new_active
		if active_fruit:
			active_fruit.set_hovered(true)
	
