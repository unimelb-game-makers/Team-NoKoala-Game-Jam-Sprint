extends Control
@onready var level_manager : LevelManager = get_tree().get_first_node_in_group(&"level_manager")
@onready var NextLevelButton : Button = $NextLevelButton

func _ready() -> void:
	NextLevelButton.pressed.connect(_on_next_level_pressed)

func _on_next_level_pressed() -> void:
	hide()	
	level_manager.exit_level()
	
