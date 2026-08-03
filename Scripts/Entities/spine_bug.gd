@abstract
extends Bug
class_name SpineBug
var spine_lines: Array[Line2D] = []


func is_move_animation_active() -> bool:
	for tween in active_movement_tweens:
		if tween.is_valid() and tween.is_running():
			return true
	return false


func capture_state() -> Dictionary:
	var line_states: Array[Dictionary] = []
	for line in spine_lines:
		line_states.append({
			&"points": line.points.duplicate(),
			&"position": line.position,
			&"rotation": line.rotation,
			&"scale": line.scale,
			&"visible": line.visible,
			&"modulate": line.modulate,
		})

	return {
		&"segment_cells": segment_cells.duplicate(),
		&"facing_direction": facing_direction,
		&"is_placed": is_placed,
		&"line_states": line_states,
	}


func restore_state(state: Dictionary) -> void:
	for tween in active_movement_tweens:
		if tween.is_valid():
			tween.kill()
	active_movement_tweens.clear()

	if is_placed:
		level_manager.level_data.remove_bug(self)

	segment_cells.assign(state[&"segment_cells"])
	facing_direction = state[&"facing_direction"]
	is_placed = state[&"is_placed"]

	var line_states: Array = state[&"line_states"]
	if line_states.size() != spine_lines.size():
		push_error(
			"Cannot fully restore SpineBug visual state: expected %d Line2D nodes, found %d."
			% [line_states.size(), spine_lines.size()]
		)

	for i in mini(line_states.size(), spine_lines.size()):
		var line_state: Dictionary = line_states[i]
		var line := spine_lines[i]
		line.points = line_state[&"points"]
		line.position = line_state[&"position"]
		line.rotation = line_state[&"rotation"]
		line.scale = line_state[&"scale"]
		line.visible = line_state[&"visible"]
		line.modulate = line_state[&"modulate"]

	if is_placed:
		level_manager.level_data.add_bug(self)


func set_free_position(pos: Vector2) -> void:
	_set_spine_free_position(pos)


func place(cell: Vector2i) -> void:
	var delta := cell - segment_cells[0]
	for i in segment_cells.size():
		segment_cells[i] += delta

	_sync_spine_to_cells()

	if not is_placed:
		is_placed = true
		level_manager.level_data.add_bug(self)
		for line in spine_lines:
			line.visible = true


@abstract
func _set_spine_free_position(pos: Vector2) -> void


@abstract
func _sync_spine_to_cells() -> void
