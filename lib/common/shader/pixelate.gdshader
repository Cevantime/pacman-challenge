shader_type canvas_item;

uniform float smoothness = 40.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = round(UV * smoothness) / smoothness;
	COLOR = texture(TEXTURE, uv);
}
