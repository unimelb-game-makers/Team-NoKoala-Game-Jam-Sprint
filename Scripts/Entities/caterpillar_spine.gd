extends SpineBug

@export var MOVE_DURATION := 0.15
@export var POINT_EPSILON := 0.001
@export var CURVE_RADIUS_IN_TILES := 0.6
@export var CURVE_SAMPLE_COUNT := 6


func init_segments() -> void:
	spine_lines = [$Head, $Body, $Tail]
	segment_cells = [
		Vector2i(0, 0),
		Vector2i(-1, 0),
		Vector2i(-2, 0),
	]

	var tile_size := Vector2(level_manager.tile_map_layer.tile_set.tile_size)
	for line in spine_lines:
		line.position = Vector2.ZERO
		line.rotation = 0.0
		line.scale = Vector2.ONE
		line.width = tile_size.y
		line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.antialiased = true
	#generate the initial body from grid position
	_sync_spine_to_cells()



func move(direction: Vector2i) -> bool:
	var next_cell := segment_cells[0] + direction
	var level_data := level_manager.level_data
	var tile_data := level_data.get_tile_data(next_cell)

	if tile_data == null:
		print("Movement Error: Outside of Play Space")
		return false

	if not tile_data.is_empty():
		for bug in tile_data.bugs:
			if bug.get_name() != "Slug":
				print("Movement Error: Tile is Occupied")
				return false

	if tile_data.type in [
		LevelData.LevelTileData.Type.HARD,
		LevelData.LevelTileData.Type.INDESTRUCTIBLE,
	]:
		print("Movement Error: Can't move into hard tiles")
		return false

	if tile_data.type in [
		LevelData.LevelTileData.Type.ENTRY_UP,
		LevelData.LevelTileData.Type.ENTRY_DOWN,
		LevelData.LevelTileData.Type.ENTRY_LEFT,
		LevelData.LevelTileData.Type.ENTRY_RIGHT,
	]:
		print("Movement Error: Can't move back out of fruit")
		return false

	level_data.remove_bug(self)

	var old_cells := segment_cells.duplicate()
	var new_cells: Array[Vector2i] = []
	new_cells.resize(segment_cells.size())
	new_cells[0] = old_cells[0] + direction
	for i in range(1, old_cells.size()):
		new_cells[i] = old_cells[i - 1]

	var old_centers := _cells_to_local_centers(old_cells)
	var new_centers := _cells_to_local_centers(new_cells)
	var corner_pivots: Array[Vector2] = [old_centers[0], old_centers[1]]

	segment_cells.assign(new_cells)
	level_data.add_bug(self)

	var tween := create_movement_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		_render_movement_frame.bind(old_centers, new_centers, corner_pivots),
		0.0,
		1.0,
		MOVE_DURATION,
	)
	tween.finished.connect(_sync_spine_to_cells)
	return true




func _render_movement_frame(
	progress: float,
	old_centers: Array[Vector2],
	new_centers: Array[Vector2],
	corner_pivots: Array[Vector2],
) -> void:
	var centers: Array[Vector2] = []
	for i in old_centers.size():
		centers.append(old_centers[i].lerp(new_centers[i], progress))
	_render_spine(centers, corner_pivots)


func _set_spine_free_position(pos: Vector2) -> void:
	var tile_size := level_manager.tile_map_layer.tile_set.tile_size
	var head_cell := segment_cells[0]
	var centers: Array[Vector2] = []

	for cell in segment_cells:
		centers.append(pos + Vector2((cell - head_cell) * tile_size))

	_render_spine(centers)


func _sync_spine_to_cells() -> void:
	_render_spine(_cells_to_local_centers(segment_cells))


func _cells_to_local_centers(cells: Array) -> Array[Vector2]:
	var tile_map := level_manager.tile_map_layer
	var centers: Array[Vector2] = []
	for cell in cells:
		centers.append(tile_map.map_to_local(cell))
	return centers


func _render_spine(
	centers: Array[Vector2],
	corner_pivots: Array[Vector2] = [],
) -> void:
	if centers.size() != 3 or spine_lines.size() != 3:
		push_error("CaterpillarSpine requires three segment centers and three Line2D nodes.")
		return

	var head_to_body := _build_grid_connection(
		centers[0],
		centers[1],
		corner_pivots[0] if corner_pivots.size() > 0 else Vector2.INF,
	)
	var body_to_tail := _build_grid_connection(
		centers[1],
		centers[2],
		corner_pivots[1] if corner_pivots.size() > 1 else Vector2.INF,
	)
	var head_direction := _first_path_direction(head_to_body)
	var tail_direction := _last_path_direction(body_to_tail)
	var tile_length := float(level_manager.tile_map_layer.tile_set.tile_size.x)
	var half_tile := tile_length * 0.5

	var grid_path: Array[Vector2] = []
	_append_unique(grid_path, centers[0] - head_direction * half_tile)
	_append_path(grid_path, head_to_body)
	_append_path(grid_path, body_to_tail)
	_append_unique(grid_path, centers[2] + tail_direction * half_tile)

	var curved_path := _smooth_path(
		grid_path,
		tile_length * CURVE_RADIUS_IN_TILES,
	)
	var sections := _split_path_into_sections(curved_path, spine_lines.size())
	for i in spine_lines.size():
		spine_lines[i].points = PackedVector2Array(sections[i])


func _build_grid_connection(
	from: Vector2,
	to: Vector2,
	pivot: Vector2,
) -> Array[Vector2]:
	var path: Array[Vector2] = [from]
	var is_diagonal := (
		not is_equal_approx(from.x, to.x)
		and not is_equal_approx(from.y, to.y)
	)
	var pivot_connects_both := (
		pivot != Vector2.INF
		and (is_equal_approx(from.x, pivot.x) or is_equal_approx(from.y, pivot.y))
		and (is_equal_approx(to.x, pivot.x) or is_equal_approx(to.y, pivot.y))
	)

	if is_diagonal and pivot_connects_both:
		_append_unique(path, pivot)
	_append_unique(path, to)
	return path


func _smooth_path(path: Array[Vector2], radius: float) -> Array[Vector2]:
	if path.size() < 3:
		return path.duplicate()

	var smoothed: Array[Vector2] = [path[0]]
	for i in range(1, path.size() - 1):
		var previous := path[i - 1]
		var corner := path[i]
		var following := path[i + 1]
		var incoming := previous - corner
		var outgoing := following - corner

		if (
			incoming.length() <= POINT_EPSILON
			or outgoing.length() <= POINT_EPSILON
			or absf(incoming.normalized().cross(outgoing.normalized())) <= POINT_EPSILON
		):
			_append_unique(smoothed, corner)
			continue

		var corner_radius := minf(
			radius,
			minf(incoming.length(), outgoing.length()) * 0.7,
		)
		var curve_start := corner + incoming.normalized() * corner_radius
		var curve_end := corner + outgoing.normalized() * corner_radius
		_append_unique(smoothed, curve_start)

		for sample in range(1, CURVE_SAMPLE_COUNT + 1):
			var weight := float(sample) / float(CURVE_SAMPLE_COUNT)
			var inverse := 1.0 - weight
			var curve_point := (
				inverse * inverse * curve_start
				+ 2.0 * inverse * weight * corner
				+ weight * weight * curve_end
			)
			_append_unique(smoothed, curve_point)

	_append_unique(smoothed, path[-1])
	return smoothed


func _split_path_into_sections(
	path: Array[Vector2],
	section_count: int,
) -> Array[Array]:
	var sections: Array[Array] = []
	var total_length := _path_length(path)
	var section_length := total_length / float(section_count)

	for section in section_count:
		sections.append(_slice_path(
			path,
			section_length * float(section),
			section_length * float(section + 1),
		))
	return sections


func _slice_path(
	path: Array[Vector2],
	start_distance: float,
	end_distance: float,
) -> Array[Vector2]:
	var result: Array[Vector2] = []
	_append_unique(result, _point_at_distance(path, start_distance))

	var traversed := 0.0
	for i in range(1, path.size()):
		traversed += path[i - 1].distance_to(path[i])
		if traversed > start_distance and traversed < end_distance:
			_append_unique(result, path[i])

	_append_unique(result, _point_at_distance(path, end_distance))
	return result


func _point_at_distance(path: Array[Vector2], distance: float) -> Vector2:
	var traversed := 0.0
	for i in range(1, path.size()):
		var segment_length := path[i - 1].distance_to(path[i])
		if traversed + segment_length >= distance:
			if segment_length <= POINT_EPSILON:
				return path[i]
			var weight := (distance - traversed) / segment_length
			return path[i - 1].lerp(path[i], clampf(weight, 0.0, 1.0))
		traversed += segment_length
	return path[-1]


func _path_length(path: Array[Vector2]) -> float:
	var length := 0.0
	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])
	return length


func _first_path_direction(path: Array[Vector2]) -> Vector2:
	for i in range(1, path.size()):
		var direction := path[i] - path[0]
		if direction.length() > POINT_EPSILON:
			return direction.normalized()
	return Vector2.RIGHT


func _last_path_direction(path: Array[Vector2]) -> Vector2:
	for i in range(path.size() - 2, -1, -1):
		var direction := path[-1] - path[i]
		if direction.length() > POINT_EPSILON:
			return direction.normalized()
	return Vector2.RIGHT


func _append_path(target: Array[Vector2], path: Array[Vector2]) -> void:
	for point in path:
		_append_unique(target, point)


func _append_unique(points: Array[Vector2], point: Vector2) -> void:
	if points.is_empty() or points[-1].distance_to(point) > POINT_EPSILON:
		points.append(point)
