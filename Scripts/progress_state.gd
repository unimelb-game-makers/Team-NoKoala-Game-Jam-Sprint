extends Node

signal progress_changed

var unlocked_fruits: Dictionary[String, bool] = {"apple": true}
var completed_fruits: Dictionary[String, bool] = {}


func is_unlocked(fruit_id: String) -> bool:
	return unlocked_fruits.get(fruit_id, false)


func is_completed(fruit_id: String) -> bool:
	return completed_fruits.get(fruit_id, false)


func complete_level(fruit_id: String) -> void:
	completed_fruits[fruit_id] = true
	unlocked_fruits[fruit_id] = true

	var next_fruit := GlobalVars.get_next_level(fruit_id)
	if not next_fruit.is_empty():
		unlocked_fruits[next_fruit] = true

	progress_changed.emit()
