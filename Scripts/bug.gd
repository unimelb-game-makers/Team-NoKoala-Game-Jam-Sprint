@abstract
extends Node2D
class_name Bug

@onready var tilemap: TileMapLayer = $"../../TileMapLayer"
@onready var segments: Array = [$Head, $Body, $Tail]
@onready var segment_local_pos: Dictionary = {}

enum Directions {
	UP,
	LEFT,
	DOWN,
	RIGHT
}

func _ready() -> void:
	spawn()

@abstract
func spawn() -> void

@abstract
func move(direction: Directions) -> void
