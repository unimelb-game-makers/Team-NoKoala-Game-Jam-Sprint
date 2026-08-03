class_name BugFactory

# This node spawns new bugs as children of this node

# Define bug scenes here:
const CATERPILLAR_SCENE = preload("res://Scenes/Bugs/caterpillar.tscn")
const SLUG_SCENE = preload("res://Scenes/Bugs/slug.tscn")
const ANT_SCENE = preload("res://Scenes/Bugs/ant.tscn")
const STAG_BEETLE_SCENE = preload("res://Scenes/Bugs/stag_beetle.tscn")

# Associate bugs with their relevant scene here:
# Note: Enum "Bugs" located in global_vars.gd
const bug_scenes: Dictionary = {
	GlobalVars.BugTypes.CATERPILLAR: CATERPILLAR_SCENE,
	GlobalVars.BugTypes.SLUG: SLUG_SCENE,
	GlobalVars.BugTypes.ANT: ANT_SCENE,
	GlobalVars.BugTypes.STAG_BEETLE: STAG_BEETLE_SCENE
}

# Usage example: create_bug(Bugs.CATERPILLAR) to create a Caterpillar
static func create_bug(bug_type: GlobalVars.BugTypes, bug_length: int = -1) -> Bug: 
	var bug = bug_scenes[bug_type].instantiate()
	bug.length = bug_length
	return bug
