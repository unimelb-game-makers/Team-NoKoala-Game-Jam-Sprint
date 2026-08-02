class_name LevelConfig

var available_bugs: Dictionary[GlobalVars.BugTypes, int] = {}
var max_move: int

static func deserialize(json_string: String) -> LevelConfig:
	var dict: Dictionary = JSON.parse_string(json_string)
	var config := LevelConfig.new()

	var parsed_available_bugs: Dictionary[GlobalVars.BugTypes, int] = {}
	for id in dict["available_bugs"]:
		parsed_available_bugs.set(GlobalVars.bug_type_from_id(id), dict["available_bugs"][id])
	config.available_bugs = parsed_available_bugs
	config.max_move = dict["max_move"]
	return config

func serialize() -> String:
	var dict := {}
	var serialized_available_bugs: Dictionary[String, int] = {}
	for id in available_bugs:
		serialized_available_bugs.set(GlobalVars.bug_type_id(id), available_bugs[id])
	dict["available_bugs"] = serialized_available_bugs
	dict["max_move"] = max_move
	return JSON.stringify(dict)
