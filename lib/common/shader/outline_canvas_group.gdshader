shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 100) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	if(uv.x > 1. || uv.x < 0.0 || uv.y > 1.0 || uv.y < 0.0) {
		return false;
	}
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

float fmod(float a, float b) {
	return a - (b * floor(a/b));
}

vec2 vec2mod(vec2 v, float modulo) {
	return vec2(fmod(v.x, modulo), fmod(v.y, modulo));
}

void fragment() {
	vec2 uv = SCREEN_UV;

    vec4 base_color =  textureLod(screen_texture, SCREEN_UV, 0.0);

   	if (base_color.a > 0.0001) {
        base_color.rgb /= base_color.a;
    }

	vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / SCREEN_PIXEL_SIZE + vec2(width * 2.0));

	if (add_margins &&  (uv.x > 1. || uv.x < 0.0 || uv.y > 1.0 || uv.y < 0.0)) {

		uv = (uv - texture_pixel_size * width) * SCREEN_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			base_color.a = 0.0;
		} else {
			base_color = textureLod(screen_texture, uv, 0.0);
		}
	} else {
		base_color = textureLod(screen_texture, uv, 0.0);
	}

	if ((base_color.a > 0.0) == inside && hasContraryNeighbour(uv, SCREEN_PIXEL_SIZE, screen_texture)) {
		vec4 noise_color = texture(noise_texture, vec2mod(UV * 50.0, 1.0));
		noise_color *= noise_color;
		//vec4 c = mix(color,noise_color, 0.5);
		vec4 c = color;
		//base_color.rgb = inside ? mix(base_color.rgb, noise_color.rgb, noise_color.a) : noise_color.rgb;
		base_color.rgb = inside ? mix(base_color.rgb, c.rgb, c.a) : c.rgb;
		base_color.a += (1.0 - base_color.a) * c.a;
	}

	COLOR = base_color;
}