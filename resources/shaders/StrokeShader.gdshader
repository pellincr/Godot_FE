shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;
uniform float color_factor : hint_range(0.0, 1.0, 1.0);
uniform vec4 modulate_color : source_color = vec4(1);

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);
	
	vec4 sample = texture(TEXTURE, UV);
	vec4 mod_c = sample * modulate_color;
	float gray = sample.r * sample.r + 0.71 * sample.g + 0.07 * sample.b;
	vec4 color = vec4(mod_c.rgb * (1.0 - color_factor) + (gray * color_factor), sample.a);
	
	COLOR = mix(color, line_color, outline - color.a);
	
}