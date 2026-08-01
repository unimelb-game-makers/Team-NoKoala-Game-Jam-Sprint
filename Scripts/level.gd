extends Node2D

var bugs = []
@onready var bug_factory = $BugFactory

func _ready() -> void:
	bug_factory.spawn_bug(GlobalVars.Bugs.CATERPILLAR)
