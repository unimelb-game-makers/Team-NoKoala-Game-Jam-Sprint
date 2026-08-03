@abstract
extends Bug
class_name MeshBug

var mesh_segments: Array[MeshInstance2D] = []


func is_move_animation_active() -> bool:
	for tween in active_movement_tweens:
		if tween.is_valid() and tween.is_running():
			return true
	return false


func capture_state() -> Dictionary:
	var mesh_states: Array[Dictionary] = []
	for mesh_segment in mesh_segments:
		mesh_states.append({
			&"position": mesh_segment.position,
			&"rotation": mesh_segment.rotation,
			&"scale": mesh_segment.scale,
			&"visible": mesh_segment.visible,
			&"modulate": mesh_segment.modulate,
		})

	return {
		&"segment_cells": segment_cells.duplicate(),
		&"facing_direction": facing_direction,
		&"is_placed": is_placed,
		&"mesh_states": mesh_states,
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

	var mesh_states: Array = state[&"mesh_states"]
	if mesh_states.size() != mesh_segments.size():
		push_error(
			"Cannot fully restore MeshBug visual state: expected %d mesh segments, found %d."
			% [mesh_states.size(), mesh_segments.size()]
		)

	for i in mini(mesh_states.size(), mesh_segments.size()):
		var mesh_state: Dictionary = mesh_states[i]
		var mesh_segment := mesh_segments[i]
		mesh_segment.position = mesh_state[&"position"]
		mesh_segment.rotation = mesh_state[&"rotation"]
		mesh_segment.scale = mesh_state[&"scale"]
		mesh_segment.visible = mesh_state[&"visible"]
		mesh_segment.modulate = mesh_state[&"modulate"]

	_sync_mesh_to_cells()
	if is_placed:
		level_manager.level_data.add_bug(self)


func set_free_position(pos: Vector2) -> void:
	_set_mesh_free_position(pos)


func place(cell: Vector2i) -> void:
	var delta := cell - segment_cells[0]
	for i in segment_cells.size():
		segment_cells[i] += delta

	_sync_mesh_to_cells()
	if not is_placed:
		is_placed = true
		level_manager.level_data.add_bug(self)
		for mesh_segment in mesh_segments:
			mesh_segment.visible = true


@abstract
func _set_mesh_free_position(pos: Vector2) -> void


@abstract
func _sync_mesh_to_cells() -> void
