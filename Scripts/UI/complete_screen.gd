extends Control
@onready var level_manager : LevelManager = get_tree().get_first_node_in_group(&"level_manager")
@onready var NextLevelButton : Button = $NextLevelButton
@export var starCollectedIcon: Dictionary[GlobalVars.BugTypes, Texture2D] = {}
@export var starUnCollectedIcon: Dictionary[GlobalVars.BugTypes, Texture2D] = {}
@onready var star_container: HBoxContainer = $StarContainer

const star_prefab = preload("res://Scenes/UI/star.tscn")
func _ready() -> void:
	NextLevelButton.pressed.connect(_on_next_level_pressed)

	
func _instantiate_stars() -> void:
	for child in star_container.get_children():
		child.queue_free()
		
	var bonus_stars = level_manager.level_data._bonus_stars.values()
	for bonus_star in bonus_stars:
		var star_instance : Panel = star_prefab.instantiate()
		star_container.add_child(star_instance)
		print(bonus_star)
		var texture
		if bonus_star[1]:
			texture = starCollectedIcon[bonus_star[0]]
		else:
			texture = starUnCollectedIcon[bonus_star[0]]
		var style := StyleBoxTexture.new()
		style.texture = texture
		star_instance.add_theme_stylebox_override("panel", style)
		
func _on_next_level_pressed() -> void:
	hide()	
	level_manager.exit_level()
	
