@abstract
extends Node2D
class_name Bug

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
#@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_placed: bool = false
var segment_sprites: Array[Sprite2D]
var segment_cells: Array[Vector2i]
var length = -1
var facing_direction: Vector2i = Directions.RIGHT
var active_movement_tweens: Array[Tween] = []

var type: GlobalVars.BugTypes

func _ready() -> void:
	init_segments()

func _exit_tree() -> void:
	if is_placed and is_instance_valid(level_manager) and level_manager.level_data != null:
		level_manager.level_data.remove_bug(self)
		is_placed = false

func set_facing_direction(direction: Vector2i) -> void:
	facing_direction = direction
	for i in segment_cells.size():
		segment_cells[i] = -direction * i
	rotate_segments()

func rotate_segments() -> void:
	pass

func create_movement_tween() -> Tween:
	var tween := create_tween()
	active_movement_tweens.append(tween)
	tween.finished.connect(_forget_movement_tween.bind(tween))
	return tween

func _forget_movement_tween(tween: Tween) -> void:
	active_movement_tweens.erase(tween)

func capture_state() -> Dictionary:
	var rotations: Array[float] = []
	var textures: Array[Texture2D] = []
	for sprite in segment_sprites:
		rotations.append(sprite.rotation)
		textures.append(sprite.texture)

	return {
		&"segment_cells": segment_cells.duplicate(),
		&"facing_direction": facing_direction,
		&"is_placed": is_placed,
		&"rotations": rotations,
		&"textures": textures,
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

	var tile_map := level_manager.tile_map_layer
	var rotations: Array = state[&"rotations"]
	var textures: Array = state[&"textures"]
	for i in segment_cells.size():
		segment_sprites[i].position = tile_map.map_to_local(segment_cells[i])
		segment_sprites[i].rotation = rotations[i]
		segment_sprites[i].texture = textures[i]

	if is_placed:
		level_manager.level_data.add_bug(self)

func set_free_position(pos: Vector2) -> void:
	var tile_map := level_manager.tile_map_layer
	var head_cell := segment_cells[0]
	for i in segment_cells.size():
		var segment_cell := segment_cells[i]
		var segment_pos := pos + Vector2((segment_cell - head_cell) * tile_map.tile_set.tile_size)
		segment_sprites[i].position = segment_pos

func place(cell: Vector2i) -> void:
	var delta := cell - segment_cells[0]
	for i in segment_cells.size():
		segment_cells[i] += delta
	
	var tile_map := level_manager.tile_map_layer
	for i in segment_cells.size():
		var segment_cell := segment_cells[i]
		segment_sprites[i].position = tile_map.map_to_local(segment_cell)

	if !is_placed:
		is_placed = true
		level_manager.level_data.add_bug(self)
		for sprite in segment_sprites:
			sprite.visible = true
	
func stop_wriggle() -> void:
	pass
	#if anim_player:
	#	anim_player.stop()

func start_wriggle() -> void:
	pass
	#if anim_player:
	#	anim_player.play("wriggle")

# Length parameter used for some bugs: e.g. Slug 
@abstract
func init_segments() -> void

@abstract
func move(direction: Vector2i) -> bool
