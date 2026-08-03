class_name JarManager
extends Node2D

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group(&"level_manager")

const BUG_SELECTION_ITEM_SCENE = preload("res://Scenes/bug_selection_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_manager.config_changed.connect(_on_config_changed)

func _on_config_changed(config: LevelConfig) -> void:
	for child in get_children():
		child.queue_free()
	
	var i = 0
	for bug_type in config.available_bugs:
		var item: BugSelectionItem = BUG_SELECTION_ITEM_SCENE.instantiate()
		item.bug_type = bug_type
		item.bug_count = config.available_bugs[bug_type]
		item.position.y = i * 100
		add_child(item)
		i += 1
