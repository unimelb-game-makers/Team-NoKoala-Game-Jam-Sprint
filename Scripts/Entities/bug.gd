@abstract
extends Node2D
class_name Bug

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
var is_placed: bool = false
var segment_sprites: Array[Sprite2D]
var segment_cells: Array[Vector2i]
var length = -1

func _ready() -> void:
	init_segments()
	for sprite in segment_sprites:
		sprite.visible = false

func teleport(cell: Vector2i) -> void:
	var delta := cell - segment_cells[0]
	for i in segment_cells.size():
		segment_cells[i] += delta
	
	var tile_map := level_manager.tile_map_layer
	for i in segment_cells.size():
		var segment_cell := segment_cells[i]
		segment_sprites[i].position = tile_map.to_global(tile_map.map_to_local(segment_cell))

	if !is_placed:
		is_placed = true
		for sprite in segment_sprites:
			sprite.visible = true

# Length parameter used for some bugs: e.g. Slug 
@abstract
func init_segments() -> void

@abstract
func move(direction: Vector2i) -> bool
