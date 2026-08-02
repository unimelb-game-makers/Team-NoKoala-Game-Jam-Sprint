extends Node
# Globally accessible variables. Access in other files as "GlobalVars"

# Enum of bug types:
enum BugTypes {
	CATERPILLAR,
	SLUG
}

func bug_type_name(bug_type: BugTypes) -> String:
	return BugTypes.find_key(bug_type)

func bug_type_from_name(p_name: String) -> BugTypes:
	return BugTypes.get(p_name)
