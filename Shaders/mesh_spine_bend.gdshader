shader_type canvas_item;
render_mode unshaded;

const int MAX_CURVE_POINTS = 32;

uniform int curve_point_count = 2;
uniform vec2 curve_points[MAX_CURVE_POINTS];
uniform float strip_width = 128.0;


vec2 safe_normalize(vec2 value) {
	float magnitude = length(value);

	if (magnitude <= 0.00001) {
		return vec2(1.0, 0.0);
	}

	return value / magnitude;
}


vec2 tangent_at(int index, int point_count) {
	int previous = max(index - 1, 0);
	int following = min(index + 1, point_count - 1);

	return safe_normalize(
		curve_points[following]
		- curve_points[previous]
	);
}


void vertex() {
	int point_count = clamp(
		curve_point_count,
		2,
		MAX_CURVE_POINTS
	);

	int last_index = point_count - 1;

	float progress = clamp(1.0 - UV.x, 0.0, 1.0);
	float cursor = progress * float(last_index);

	int start_index = min(
		int(floor(cursor)),
		last_index - 1
	);
	int end_index = start_index + 1;

	float weight = cursor - float(start_index);

	vec2 center = mix(
		curve_points[start_index],
		curve_points[end_index],
		weight
	);

	vec2 start_tangent = tangent_at(
		start_index,
		point_count
	);
	vec2 end_tangent = tangent_at(
		end_index,
		point_count
	);

	float smooth_weight = smoothstep(0.0, 1.0, weight);

	vec2 tangent = safe_normalize(mix(
		start_tangent,
		end_tangent,
		smooth_weight
	));

	vec2 normal = vec2(
		-tangent.y,
		tangent.x
	);

	float width_offset = (
		UV.y - 0.5
	) * strip_width;

	VERTEX = center + normal * width_offset;
}
