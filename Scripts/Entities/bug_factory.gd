extends Node
class_name BugFactory

# This node spawns new bugs as children of this node

# Define bug scenes here:
const CATERPILLAR_SCENE = preload("res://Scenes/Bugs/caterpillar.tscn")
const CATERPILLAR_REAL_SCENE = preload("res://Scenes/Bugs/caterpillar_real.tscn")

# Associate bugs with their relevant scene here:
# Note: Enum "Bugs" located in global_vars.gd
var bug_scenes: Dictionary = {
	GlobalVars.BugTypes.CATERPILLAR: CATERPILLAR_SCENE,
	GlobalVars.BugTypes.CATERPILLAR_REAL: CATERPILLAR_REAL_SCENE
}

# Usage example: create_bug(Bugs.CATERPILLAR) to create a Caterpillar
func create_bug(bug_type: GlobalVars.BugTypes) -> Bug: 
	var bug = bug_scenes[bug_type].instantiate()
	return bug
