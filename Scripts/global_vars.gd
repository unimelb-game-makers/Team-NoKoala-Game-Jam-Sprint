extends Node
# Globally accessible variables. Access in other files as "GlobalVars"

# Enum of bug types:
enum BugTypes {
	CATERPILLAR,
	SLUG,
	ANT,
	STAG_BEETLE,
	CATERPILLAR_REAL,
	ROLY_POLY,
	WORM
}

# Array of level order:
var LevelOrder = ["apple", "grape", "banana", "orange", "melon"]

func get_next_level(level_key: String) -> String:
	var idex = LevelOrder.find(level_key)
	if idex == -1 or idex + 1 >= LevelOrder.size():
		return ""  # no next level
	return LevelOrder[idex + 1]

func bug_type_id(bug_type: BugTypes) -> String:
	return BugTypes.find_key(bug_type)

func bug_type_from_id(p_name: String) -> BugTypes:
	return BugTypes.get(p_name)
