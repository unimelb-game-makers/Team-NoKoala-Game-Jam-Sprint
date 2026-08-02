class_name LevelConfig

enum PlaceMode {
	SEQUENCE,
	INVENTORY,
	FREE,
}

var place_mode: PlaceMode = PlaceMode.FREE
var candidates: Array[GlobalVars.BugTypes] = []

static func deserialize(json_string: String) -> LevelConfig:
	var dict: Dictionary = JSON.parse_string(json_string)
	var config := LevelConfig.new()

	config.place_mode = dict["place_mode"]
	var parsed_candidates: Array[GlobalVars.BugTypes] = []
	for candidate_name in dict["candidates"]:
		parsed_candidates.append(GlobalVars.bug_type_from_name(candidate_name))
	config.candidates = parsed_candidates
	return config

func serialize() -> String:
	var dict := {}
	dict["place_mode"] = place_mode
	dict["candidates"] = candidates.map(GlobalVars.bug_type_name)
	return JSON.stringify(dict)
