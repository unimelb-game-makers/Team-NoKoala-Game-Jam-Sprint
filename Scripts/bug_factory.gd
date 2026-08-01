extends Node
# This node spawns new bugs as children of this node

@onready var movement_controller = $"../MovementController"

# Define bug scenes here:
const CATERPILLAR_SCENE = preload("res://Scenes/Bugs/caterpillar.tscn")

# Associate bugs with their relevant scene here:
# Note: Enum "Bugs" located in global_vars.gd
var bug_scenes: Dictionary = {
	GlobalVars.Bugs.CATERPILLAR: CATERPILLAR_SCENE
}

# Usage example: spawn_bug(Bugs.CATERPILLAR) to spawn a Caterpillar
func spawn_bug(bug_type: GlobalVars.Bugs) -> void: 
	var bug = bug_scenes[bug_type].instantiate()
	add_child(bug)
	movement_controller.current_bug = bug
