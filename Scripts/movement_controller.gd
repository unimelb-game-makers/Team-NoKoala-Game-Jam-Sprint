extends Node

# Stores the currently controlled bug so players aren't controlling multiple bugs at once
var current_bug: Bug

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		current_bug.move(Bug.Directions.UP)
	elif event.is_action_pressed("left"):
		current_bug.move(Bug.Directions.LEFT)
	elif event.is_action_pressed("down"):
		current_bug.move(Bug.Directions.DOWN)
	elif event.is_action_pressed("right"):
		current_bug.move(Bug.Directions.RIGHT)
