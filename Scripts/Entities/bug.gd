@abstract
extends Node2D
class_name Bug

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
var is_placed: bool = false
var segment_sprites: Array[Sprite2D]
var segment_cells: Array[Vector2i]
var length = -1
var entry_point_direction: Vector2i = Directions.RIGHT

var type: GlobalVars.BugTypes

func _ready() -> void:
	init_segments()

func set_entry_point_direction(direction: Vector2i) -> void:
	entry_point_direction = direction
	for i in segment_cells.size():
		segment_cells[i] = -direction * i
	rotate_segments()
	set_facing_direction()

func rotate_segments() -> void:
	pass

func set_facing_direction() -> void:
	pass

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

# Length parameter used for some bugs: e.g. Slug 
@abstract
func init_segments() -> void

@abstract
func move(direction: Vector2i) -> bool
