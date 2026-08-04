extends Node

signal progress_changed
signal all_levels_completed

var unlocked_fruits: Dictionary[String, bool] = {"orange": true}
var completed_fruits: Dictionary[String, bool] = {}


func is_unlocked(fruit_id: String) -> bool:
	return unlocked_fruits.get(fruit_id, false)


func is_completed(fruit_id: String) -> bool:
	return completed_fruits.get(fruit_id, false)


func are_all_levels_completed() -> bool:
	for fruit_id: String in GlobalVars.LevelOrder:
		if not is_completed(fruit_id):
			return false
	return true


func complete_level(fruit_id: String) -> bool:
	var were_all_levels_completed := are_all_levels_completed()
	completed_fruits[fruit_id] = true
	unlocked_fruits[fruit_id] = true

	var next_fruit := GlobalVars.get_next_level(fruit_id)
	if not next_fruit.is_empty():
		unlocked_fruits[next_fruit] = true

	progress_changed.emit()
	var completed_all_levels := not were_all_levels_completed and are_all_levels_completed()
	if completed_all_levels:
		all_levels_completed.emit()
	return completed_all_levels
