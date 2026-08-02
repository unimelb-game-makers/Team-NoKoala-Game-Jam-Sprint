shader_type canvas_item;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float gray_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float grayscale = dot(original.rgb, vec3(0.299, 0.587, 0.114));
	vec3 mixed = mix(original.rgb, vec3(grayscale), gray_amount);
	COLOR = vec4(mixed, original.a) * color;
}
