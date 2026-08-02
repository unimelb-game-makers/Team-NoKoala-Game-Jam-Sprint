extends Node
@onready var level_manager : LevelManager = get_tree().get_first_node_in_group(&"level_manager")
@onready var movement_controller := (
	get_tree().get_first_node_in_group(&"movement_controller") as MovementController
)
@onready var complete_screen = %LevelCompleteUI

func _ready() -> void:
	movement_controller.move_committed.connect(win_detect)


func win_detect(current: float, maximum: float) -> bool:
	var level_data = level_manager.level_data
	for tile_data : LevelData.LevelTileData in level_data.get_tile_datas():
		if (tile_data.type == LevelData.LevelTileData.Type.NORMAL 
			and tile_data.bugs.is_empty() ):
				return false
	get_tree().paused = true
	complete_screen.show()

	return true
	
				
				
		
