class_name JarManager
extends Node2D

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group(&"level_manager")

const JAR_SCENE = preload("res://Scenes/jar.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_manager.config_changed.connect(_on_config_changed)

func _on_config_changed(config: LevelConfig) -> void:
	var i = 0
	for bug_type in config.available_bugs:
		var jar: Jar = JAR_SCENE.instantiate()
		jar.bug_type = bug_type
		jar.bug_count = config.available_bugs[bug_type]
		if i % 2 == 0:
			jar.position.y = i * 380
		else:
			jar.position.x = 400
			jar.position.y = (i - 1) * 380
		add_child(jar)
		i += 1
