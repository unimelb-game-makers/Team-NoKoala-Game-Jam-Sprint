class_name BugHandler
extends Node2D

const RESTING_SCALE := Vector2(0.5, 0.5)
const HOVER_SCALE := Vector2.ONE
const SCALE_TRANSITION_DURATION := 0.15

@onready var level_manager: LevelManager = get_tree().get_first_node_in_group(&"level_manager")
@onready var area: Area2D = $Area2D

var bug: Bug
var scale_tween: Tween
var is_hovered := false
var collision_layer_before_selection: int
var bug_z_index_before_selection: int
var bug_z_as_relative_before_selection: bool

func _ready() -> void:
	add_child(bug)
	bug.set_free_position(Vector2(0, 0))
	_generate_collision_shapes()

func _generate_collision_shapes() -> void:
	var tile_size: Vector2 = bug.level_manager.tile_map_layer.tile_set.tile_size
	var head_cell := bug.segment_cells[0]

	for cell in bug.segment_cells:
		var shape_node := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()

		rectangle.size = tile_size
		shape_node.shape = rectangle
		shape_node.position = Vector2(cell - head_cell) * tile_size

		area.add_child(shape_node)

func _on_selected():
	level_manager.begin_bug_selection(bug, self)

func begin_selection() -> void:
	visible = false
	area.input_pickable = false
	collision_layer_before_selection = area.collision_layer
	area.collision_layer = 0
	bug_z_index_before_selection = bug.z_index
	bug_z_as_relative_before_selection = bug.z_as_relative
	bug.reparent(level_manager.tile_map_layer, false)
	bug.z_as_relative = false
	bug.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_set_hovered(false)
	call_deferred(&"_update_hovered_bug")

func cancel_selection() -> void:
	bug.reparent(self, false)
	bug.set_free_position(Vector2.ZERO)
	_restore_bug_draw_order()
	visible = true
	area.input_pickable = true
	area.collision_layer = collision_layer_before_selection
	_set_hovered(false)

func complete_selection() -> void:
	_restore_bug_draw_order()
	queue_free()

func _restore_bug_draw_order() -> void:
	bug.z_index = bug_z_index_before_selection
	bug.z_as_relative = bug_z_as_relative_before_selection

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	_update_hovered_bug()

	if _get_top_bug_handler_at_mouse() == self:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_on_selected()

func _on_area_2d_mouse_entered() -> void:
	_update_hovered_bug()

func _on_area_2d_mouse_exited() -> void:
	_set_hovered(false)
	_update_hovered_bug()

func _update_hovered_bug() -> void:
	var handlers := _get_bug_handlers_at_mouse()
	var top_handler := _get_top_bug_handler(handlers)

	# Reset this handler even when it is no longer beneath the mouse.
	_set_hovered(self == top_handler)
	for handler in handlers:
		handler._set_hovered(handler == top_handler)

func _set_hovered(value: bool) -> void:
	if is_hovered == value:
		return

	is_hovered = value
	_transition_to_scale(HOVER_SCALE if value else RESTING_SCALE)

func _transition_to_scale(target_scale: Vector2) -> void:
	if scale_tween != null and scale_tween.is_valid():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_QUAD)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", target_scale, SCALE_TRANSITION_DURATION)

func _get_top_bug_handler_at_mouse() -> BugHandler:
	return _get_top_bug_handler(_get_bug_handlers_at_mouse())

func _get_bug_handlers_at_mouse() -> Array[BugHandler]:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := get_world_2d().direct_space_state.intersect_point(query, 64)
	var handlers: Array[BugHandler] = []

	for result in results:
		var collider := result["collider"] as Area2D
		if collider == null or collider.get_parent() is not BugHandler:
			continue

		var handler := collider.get_parent() as BugHandler
		if handler not in handlers:
			handlers.append(handler)

	return handlers

func _get_top_bug_handler(handlers: Array[BugHandler]) -> BugHandler:
	var top_handler: BugHandler = null

	for handler in handlers:
		if top_handler == null or _is_drawn_above(handler, top_handler):
			top_handler = handler

	return top_handler

func _is_drawn_above(candidate: BugHandler, current: BugHandler) -> bool:
	if candidate.z_index != current.z_index:
		return candidate.z_index > current.z_index

	return candidate.is_greater_than(current)
