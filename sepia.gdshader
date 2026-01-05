shader_type canvas_item;

uniform sampler2D gradient;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	vec4 gray_scale = vec4(vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b), COLOR.a);
	float brightness = (pixelColor.r + pixelColor.b + pixelColor.g)/ 3.0;
	vec4 gradientColor = texture(gradient, vec2(brightness));
	COLOR = mix(gray_scale, gradientColor, .5);
}

