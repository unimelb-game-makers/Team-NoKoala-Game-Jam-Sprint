class_name AllBugs
extends Resource

@export var bug_definitions: Array[BugDefinition]

func get_definition(type: GlobalVars.BugTypes) -> BugDefinition:
	var index = bug_definitions.find_custom(func(def: BugDefinition): return def.type == type);
	return bug_definitions[index];
