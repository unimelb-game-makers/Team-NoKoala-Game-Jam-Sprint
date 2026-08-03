class_name LevelConfig
extends Resource

@export var level_key: String
@export var available_bugs: Dictionary[GlobalVars.BugTypes, int] = {}
@export var max_move: int

static func deserialize(json_string: String) -> LevelConfig:
	var dict: Dictionary = JSON.parse_string(json_string)
	var config := LevelConfig.new()

	var parsed_available_bugs: Dictionary[GlobalVars.BugTypes, int] = {}
	for id in dict["available_bugs"]:
		parsed_available_bugs.set(GlobalVars.bug_type_from_id(id), dict["available_bugs"][id])
	config.level_key = dict.get("level_key", "")
	config.available_bugs = parsed_available_bugs
	config.max_move = dict["max_move"]
	return config

func serialize() -> String:
	var dict := {}
	var serialized_available_bugs: Dictionary[String, int] = {}
	for id in available_bugs:
		serialized_available_bugs.set(GlobalVars.bug_type_id(id), available_bugs[id])
	dict["level_key"] = level_key
	dict["available_bugs"] = serialized_available_bugs
	dict["max_move"] = max_move
	return JSON.stringify(dict)
