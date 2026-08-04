class_name BugFactory

# This node spawns new bugs as children of this node

# Define bug scenes here:
const CENTIPEDE_SCENE = preload("res://Scenes/Bugs/centipede.tscn")
const SLUG_SCENE = preload("res://Scenes/Bugs/slug.tscn")
const ROLY_POLY_SCENE = preload("res://Scenes/Bugs/rolypoly.tscn")
const WORM_SCENE = preload("res://Scenes/Bugs/worm.tscn")
const ANT_SCENE = preload("res://Scenes/Bugs/ant.tscn")
const STAG_BEETLE_SCENE = preload("res://Scenes/Bugs/stag_beetle.tscn")
const CATERPILLAR_SCENE = preload("res://Scenes/Bugs/caterpillar.tscn")


#Experiemental Spine-Based Bug Scenes
const CATERPILLAR_SPINE_SCENE = preload("res://Scenes/Bugs/caterpillar_spine.tscn")
const CATERPILLAR_MESH_SCENE = preload("res://Scenes/Bugs/caterpillar_mesh_sprite.tscn")
const WORM_MESH_SCENE = preload("res://Scenes/Bugs/worm_mesh_sprite.tscn")
const SLUG_MESH_SCENE = preload("res://Scenes/Bugs/slug_mesh_sprite.tscn")
const CENTIPEDE_MESH_SCENE = preload("res://Scenes/Bugs/centipede_mesh_sprite.tscn")


# Associate bugs with their relevant scene here:
# Note: Enum "Bugs" located in global_vars.gd
const bug_scenes: Dictionary = {
	GlobalVars.BugTypes.CENTIPEDE: CENTIPEDE_MESH_SCENE,
	GlobalVars.BugTypes.SLUG: SLUG_MESH_SCENE,
	GlobalVars.BugTypes.ROLY_POLY: ROLY_POLY_SCENE,
	GlobalVars.BugTypes.WORM: WORM_MESH_SCENE,
	GlobalVars.BugTypes.ANT: ANT_SCENE,
	GlobalVars.BugTypes.STAG_BEETLE: STAG_BEETLE_SCENE,
	GlobalVars.BugTypes.CATERPILLAR: CATERPILLAR_MESH_SCENE
}

# Usage example: create_bug(GlobalVars.BugTypes.CATERPILLAR) to create a caterpillar
static func create_bug(bug_type: GlobalVars.BugTypes, bug_length: int = -1) -> Bug: 
	var bug = bug_scenes[bug_type].instantiate()
	bug.type = bug_type
	bug.length = bug_length
	return bug
