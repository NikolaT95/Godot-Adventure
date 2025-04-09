shader_type canvas_item;

uniform float time_scale = 20;
uniform float gb_ceil = 0.75;


void fragment() {
	float time_cycle = sin(TIME + time_scale);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(
		tex_color.r,
		tex_color.g * time_cycle * gb_ceil,
		tex_color.b * time_cycle * gb_ceil,
		tex_color.a);
}

