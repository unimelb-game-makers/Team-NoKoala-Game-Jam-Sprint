class_name Jar
extends Node2D

@onready var bugs: Node2D = $Bugs
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

const BUG_HANDLER_SCENE = preload("res://Scenes/bug_handler.tscn")

var bug_type: GlobalVars.BugTypes
var bug_count: int

func _ready() -> void:
	for i in bug_count:
		var bug = BugFactory.create_bug(bug_type)
		var handler: BugHandler = BUG_HANDLER_SCENE.instantiate()
		handler.rotation = randf_range(0, TAU)
		handler.position = random_position()
		handler.scale = Vector2(0.5, 0.5)
		handler.bug = bug
		add_child(handler)
		
func random_position() -> Vector2:
	var shape = collision_shape.shape as CircleShape2D
	var extents = shape.radius
	
	# Generate a random point within the bounds
	var random_x = randf_range(-extents, extents)
	var random_y = randf_range(-extents, extents)
	
	# Offset by the shape's global position
	return collision_shape.position + Vector2(random_x, random_y)
