class_name BugSelectionMenu
extends Node2D

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group(&"level_manager")

const BUG_SELECTION_ITEM_SCENE = preload("res://Scenes/bug_selection_item.tscn")
var items: Dictionary[GlobalVars.BugTypes, BugSelectionItem] = {}

func _enter_tree() -> void:
	add_to_group(&"bug_selection_menu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_manager.config_changed.connect(_on_config_changed)

	position.x = 850
	position.y = -425

func _on_config_changed(config: LevelConfig) -> void:
	items.clear()
	for child in get_children():
		child.queue_free()
	
	var i = 0
	for bug_type in config.available_bugs:
		var item: BugSelectionItem = BUG_SELECTION_ITEM_SCENE.instantiate()
		item.bug_type = bug_type
		item.bug_count = config.available_bugs[bug_type]
		item.position.y = i * 100
		add_child(item)
		items[bug_type] = item
		i += 1

func consume_bug(bug_type: GlobalVars.BugTypes) -> void:
	if items.has(bug_type):
		items[bug_type].set_bug_count(items[bug_type].bug_count - 1)

func return_bug(bug_type: GlobalVars.BugTypes) -> void:
	if items.has(bug_type):
		items[bug_type].set_bug_count(items[bug_type].bug_count + 1)
