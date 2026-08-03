@abstract
extends MeshBug
class_name CurvedMeshBug

const BEND_SHADER := preload("res://Shaders/mesh_spine_bend.gdshader")
const CURVE_POINT_COUNT := 32

@export var MOVE_DURATION := 0.15
@export var POINT_EPSILON := 0.001
@export var CURVE_RADIUS_IN_TILES := 0.5
@export var CURVE_SAMPLE_COUNT := 6
@export_range(0.1, 1.0, 0.05) var STRIP_WIDTH_IN_TILES := 1.0

#ideally between 1 and 64
@export_range(1, 64, 1) var default_subdivisions := 32


func _initialize_mesh_rendering() -> void:
	var tile_size := level_manager.tile_map_layer.tile_set.tile_size
	for mesh_segment in mesh_segments:
		mesh_segment.position = Vector2.ZERO
		mesh_segment.rotation = 0.0
		mesh_segment.scale = Vector2.ONE
		mesh_segment.mesh = _create_subdivided_strip(default_subdivisions, tile_size)
		var material := ShaderMaterial.new()
		material.shader = BEND_SHADER
		material.set_shader_parameter(
			&"strip_width",
			level_manager.tile_map_layer.tile_set.tile_size.y * STRIP_WIDTH_IN_TILES,
		)
		mesh_segment.material = material

	_sync_mesh_to_cells()


#creating splits of meshes during initialising the mesh 
func _create_subdivided_strip(subdivisions: int, tile_size: Vector2) -> ArrayMesh:
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var half_width := tile_size.x * 0.5
	var half_height := tile_size.y * 0.5

	for column in subdivisions + 1:
		var u := float(column) / float(subdivisions)
		var x := lerpf(-half_width, half_width, u)
		vertices.append(Vector2(x, -half_height))
		vertices.append(Vector2(x, half_height))
		uvs.append(Vector2(u, 0.0))
		uvs.append(Vector2(u, 1.0))

	for column in subdivisions:
		var top_left := column * 2
		var bottom_left := top_left + 1
		var top_right := top_left + 2
		var bottom_right := top_left + 3
		indices.append_array(PackedInt32Array([
			top_left, bottom_left, top_right,
			top_right, bottom_left, bottom_right,
		]))

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result


func _start_follow_step(direction: Vector2i) -> Tween:
	var old_cells := segment_cells.duplicate()
	var new_cells: Array[Vector2i] = []
	new_cells.resize(old_cells.size())
	new_cells[0] = old_cells[0] + direction
	for i in range(1, old_cells.size()):
		new_cells[i] = old_cells[i - 1]

	var old_centers := _cells_to_local_centers(old_cells)
	var new_centers := _cells_to_local_centers(new_cells)
	var corner_pivots: Array[Vector2] = []
	for i in range(old_centers.size() - 1):
		#the pivots where the bug should turn 
		corner_pivots.append(old_centers[i])

	segment_cells.assign(new_cells)
	var tween := create_movement_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		_render_movement_frame.bind(old_centers, new_centers, corner_pivots),
		0.0,
		1.0,
		MOVE_DURATION,
	)
	tween.finished.connect(_sync_mesh_to_cells)
	return tween


#iterate movestep perframe, fix the pivot while increment centers
func _render_movement_frame(
	progress: float,
	old_centers: Array[Vector2],
	new_centers: Array[Vector2],
	corner_pivots: Array[Vector2],
) -> void:
	var centers: Array[Vector2] = []
	for i in old_centers.size():
		centers.append(old_centers[i].lerp(new_centers[i], progress))
	_render_mesh(centers, corner_pivots)


func _set_mesh_free_position(pos: Vector2) -> void:
	var tile_size := level_manager.tile_map_layer.tile_set.tile_size
	var head_cell := segment_cells[0]
	var centers: Array[Vector2] = []
	for cell in segment_cells:
		centers.append(pos + Vector2((cell - head_cell) * tile_size))
	_render_mesh(centers)


#used to set mesh snap to grid after movement completed 
func _sync_mesh_to_cells() -> void:
	_render_mesh(_cells_to_local_centers(segment_cells))


#convert cell space coordinate to position coordinates
func _cells_to_local_centers(cells: Array) -> Array[Vector2]:
	var tile_map := level_manager.tile_map_layer
	var centers: Array[Vector2] = []
	for cell in cells:
		centers.append(tile_map.map_to_local(cell))
	return centers







# --- bug render logics ---
func _render_mesh(
	centers: Array[Vector2],
	corner_pivots: Array[Vector2] = [],
) -> void:
	if centers.size() < 2 or centers.size() != mesh_segments.size():
		push_error("CurvedMeshBug requires one center per mesh segment and at least two segments.")
		return

	var connections: Array[Array] = []
	for i in range(centers.size() - 1):
		connections.append(_build_grid_connection(
			centers[i],
			centers[i + 1],
			corner_pivots[i] if i < corner_pivots.size() else Vector2.INF,
		))

	var head_direction := _first_path_direction(connections[0])
	var tail_direction := _last_path_direction(connections[-1])
	var tile_length := float(level_manager.tile_map_layer.tile_set.tile_size.x)
	var half_tile := tile_length * 0.5
	var grid_path: Array[Vector2] = []
	_append_unique(grid_path, centers[0] - head_direction * half_tile)
	for connection in connections:
		for point in connection:
			_append_unique(grid_path, point)
	_append_unique(grid_path, centers[-1] + tail_direction * half_tile)

	var curved_path := _smooth_path(grid_path, tile_length * CURVE_RADIUS_IN_TILES)
	var sections := _split_path_into_sections(curved_path, mesh_segments.size())
	for i in mesh_segments.size():
		_set_segment_curve(mesh_segments[i], sections[i])


func _set_segment_curve(mesh_segment: MeshInstance2D, path: Array[Vector2]) -> void:
	var total_length := _path_length(path)
	var points := PackedVector2Array()
	for i in CURVE_POINT_COUNT:
		points.append(_point_at_distance(
			path,
			total_length * float(i) / float(CURVE_POINT_COUNT - 1),
		))

	var material := mesh_segment.material as ShaderMaterial
	material.set_shader_parameter(&"curve_point_count", CURVE_POINT_COUNT)
	material.set_shader_parameter(&"curve_points", points)


func _build_grid_connection(from: Vector2, to: Vector2, pivot: Vector2) -> Array[Vector2]:
	var path: Array[Vector2] = [from]
	var is_diagonal := not is_equal_approx(from.x, to.x) and not is_equal_approx(from.y, to.y)
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
	if path.size() < 3 or radius <= POINT_EPSILON:
		return path.duplicate()

	var smoothed: Array[Vector2] = [path[0]]
	var sample_count := maxi(CURVE_SAMPLE_COUNT, 1)

	for i in range(1, path.size() - 1):
		var previous := path[i - 1]
		var corner := path[i]
		var following := path[i + 1]

		var incoming := corner - previous
		var outgoing := following - corner
		var incoming_length := incoming.length()
		var outgoing_length := outgoing.length()

		if (
			incoming_length <= POINT_EPSILON
			or outgoing_length <= POINT_EPSILON
		):
			_append_unique(smoothed, corner)
			continue

		var incoming_direction := incoming / incoming_length
		var outgoing_direction := outgoing / outgoing_length
		var turn_cross := incoming_direction.cross(outgoing_direction)
		var turn_angle := acos(clampf(
			incoming_direction.dot(outgoing_direction),
			-1.0,
			1.0,
		))

		# Ignore straight lines and 180-degree reversals.
		if (
			absf(turn_cross) <= POINT_EPSILON
			or turn_angle <= POINT_EPSILON
			or turn_angle >= PI - POINT_EPSILON
		):
			_append_unique(smoothed, corner)
			continue

		# Distance from the corner to each circle tangent point.
		var tangent_scale := tan(turn_angle * 0.5)
		var max_tangent_distance := minf(
			incoming_length,
			outgoing_length,
		) * 0.5

		var tangent_distance := minf(
			radius * tangent_scale,
			max_tangent_distance,
		)
		var actual_radius := tangent_distance / tangent_scale

		var curve_start := corner - incoming_direction * tangent_distance
		var curve_end := corner + outgoing_direction * tangent_distance

		# Locate the circle's center on the inside of the turn.
		var turn_sign := 1.0 if turn_cross > 0.0 else -1.0
		var incoming_normal := Vector2(
			-incoming_direction.y,
			incoming_direction.x,
		) * turn_sign

		var circle_center := curve_start + incoming_normal * actual_radius
		var start_angle := (curve_start - circle_center).angle()
		var end_angle := (curve_end - circle_center).angle()

		var angle_sweep: float
		if turn_sign > 0.0:
			angle_sweep = fposmod(end_angle - start_angle, TAU)
		else:
			angle_sweep = -fposmod(start_angle - end_angle, TAU)

		_append_unique(smoothed, curve_start)

		for sample in range(1, sample_count):
			var weight := float(sample) / float(sample_count)
			var angle := start_angle + angle_sweep * weight
			_append_unique(
				smoothed,
				circle_center
				+ Vector2(cos(angle), sin(angle)) * actual_radius,
			)

		_append_unique(smoothed, curve_end)

	_append_unique(smoothed, path[-1])
	return smoothed


func _split_path_into_sections(path: Array[Vector2], section_count: int) -> Array[Array]:
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


func _slice_path(path: Array[Vector2], start_distance: float, end_distance: float) -> Array[Vector2]:
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
	var result := 0.0
	for i in range(1, path.size()):
		result += path[i - 1].distance_to(path[i])
	return result


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


#Adds a point only if it is not effectively identical to the previous point.
func _append_unique(points: Array[Vector2], point: Vector2) -> void:
	if points.is_empty() or points[-1].distance_to(point) > POINT_EPSILON:
		points.append(point)
