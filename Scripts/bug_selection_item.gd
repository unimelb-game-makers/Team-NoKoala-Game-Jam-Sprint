class_name BugSelectionItem
extends Node2D

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group(&"level_manager")
@onready var label: Label = $Label
@onready var icon: Node2D = $Icon
@onready var area: Area2D = $Area2D

const RESTING_SCALE := Vector2(0.5, 0.5)
const HOVER_SCALE := Vector2.ONE
const SCALE_TRANSITION_DURATION := 0.15

var bug_type: GlobalVars.BugTypes
var bug_count: int
var scale_tween: Tween
var is_hovered := false

func _ready() -> void:
	set_bug_count(bug_count)
	icon.scale = Vector2(0.5, 0.5)
	var bug := BugFactory.create_bug(bug_type)
	icon.add_child(bug)
	bug.set_free_position(Vector2(0, 0))
	_generate_collision_shapes(bug)

func _on_area_2d_mouse_entered() -> void:
	_set_hovered(true)

func _on_area_2d_mouse_exited() -> void:
	_set_hovered(false)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_selected()

func _on_selected():
	if bug_count > 0:
		level_manager.begin_bug_selection(bug_type)

func set_bug_count(value: int) -> void:
	bug_count = maxi(value, 0)
	label.text = "x%d" % bug_count
	area.input_pickable = bug_count > 0
	modulate.a = 1.0 if bug_count > 0 else 0.5

func _generate_collision_shapes(bug: Bug) -> void:
	var tile_size: Vector2 = bug.level_manager.tile_map_layer.tile_set.tile_size
	var head_cell := bug.segment_cells[0]

	for cell in bug.segment_cells:
		var shape_node := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()

		rectangle.size = tile_size
		shape_node.shape = rectangle
		shape_node.position = Vector2(cell - head_cell) * tile_size

		area.add_child(shape_node)

func _set_hovered(value: bool) -> void:
	if is_hovered == value:
		return

	is_hovered = value
	_transition_icon_to_scale(HOVER_SCALE if value else RESTING_SCALE)

func _transition_icon_to_scale(target_scale: Vector2) -> void:
	if scale_tween != null and scale_tween.is_valid():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_QUAD)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(icon, "scale", target_scale, SCALE_TRANSITION_DURATION)
