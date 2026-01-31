shader_type canvas_item;

// Sky colors
uniform vec3 sky_top_color : source_color = vec3(0.15, 0.45, 0.85);
uniform vec3 sky_bottom_color : source_color = vec3(0.7, 0.85, 1.0);

// Sun
uniform vec3 sun_color : source_color = vec3(1.0, 0.95, 0.6);
uniform vec2 sun_position = vec2(0.8, 0.2);
uniform float sun_size : hint_range(0.01, 0.2) = 0.05;
uniform float sun_glow_size : hint_range(0.0, 0.5) = 0.2;
uniform float sun_glow_intensity : hint_range(0.0, 1.0) = 0.4;

// Horizon haze
uniform bool enable_haze = true;
uniform float haze_height : hint_range(0.0, 1.0) = 0.3;
uniform float haze_intensity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec2 uv = UV;
	
	// Base sky gradient (top to bottom)
	vec3 sky = mix(sky_bottom_color, sky_top_color, uv.y);
	
	// Sun disc
	float sun_dist = distance(uv, sun_position);
	float sun = smoothstep(sun_size, sun_size * 0.5, sun_dist);
	
	// Sun glow
	float glow = smoothstep(sun_glow_size, 0.0, sun_dist) * sun_glow_intensity;
	
	// Apply sun and glow
	sky += sun_color * sun;
	sky += sun_color * glow;
	
	// Horizon haze (foggy bottom)
	if (enable_haze) {
		float haze = smoothstep(haze_height, 0.0, uv.y) * haze_intensity;
		sky = mix(sky, sky_bottom_color + vec3(0.1), haze);
	}
	
	COLOR = vec4(sky, 1.0);
}