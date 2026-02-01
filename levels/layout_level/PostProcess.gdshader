shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Screen texture
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Mask state: 0 = None, 1 = Blue, 2 = Red, 3 = Black
uniform int mask_state : hint_range(0, 3) = 0;
uniform float transition_progress : hint_range(0.0, 1.0) = 1.0;

// Time for animated effects
uniform float time_offset = 0.0;

// Color grading per state
const vec3 JUNGLE_TINT = vec3(1.0, 0.98, 0.9);
const vec3 WATER_TINT = vec3(0.7, 0.85, 1.0);
const vec3 FIRE_TINT = vec3(1.2, 0.6, 0.4);
const vec3 NIGHT_TINT = vec3(0.6, 0.7, 1.0);

// Caustics function for water effect
float caustics(vec2 uv, float time) {
    vec2 p = mod(uv * 6.0, 1.0) - 0.5;
    float t = time * 0.5;
    
    float a = atan(p.y, p.x);
    float r = length(p);
    
    float wave1 = sin(r * 20.0 - t * 3.0 + sin(a * 5.0 + t));
    float wave2 = sin(r * 15.0 - t * 2.0 + sin(a * 3.0 - t * 0.5));
    
    return smoothstep(0.0, 0.3, wave1 * wave2);
}

// Noise for fire/smoke effect
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Ember particles
float embers(vec2 uv, float time) {
    float result = 0.0;
    for (int i = 0; i < 8; i++) {
        vec2 ember_pos = vec2(
            hash(vec2(float(i), 0.0)),
            fract(hash(vec2(float(i), 1.0)) - time * (0.1 + hash(vec2(float(i), 2.0)) * 0.1))
        );
        ember_pos.x += sin(time + float(i)) * 0.05;
        
        float dist = distance(uv, ember_pos);
        result += smoothstep(0.02, 0.0, dist) * (0.5 + 0.5 * sin(time * 10.0 + float(i)));
    }
    return result;
}

// Vignette effect
float vignette(vec2 uv, float intensity) {
    vec2 center = uv - 0.5;
    return 1.0 - dot(center, center) * intensity;
}

// Mist/fog effect
float mist(vec2 uv, float time) {
    float n1 = noise(uv * 3.0 + vec2(time * 0.1, 0.0));
    float n2 = noise(uv * 5.0 + vec2(0.0, time * 0.15));
    return (n1 + n2) * 0.5;
}

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
	float hdr_threshold = 0.4; // Exagerated, almost everything will glow
	return max(textureLod(tex, uv, 2.0) - hdr_threshold, vec4(0.0));
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float time = TIME + time_offset;
    
    // Sample the screen
    vec4 screen_color = texture(screen_texture, uv);
    vec3 final_color = screen_color.rgb;
    
    // === NONE (Jungle) ===
    vec3 jungle_color = screen_color.rgb * JUNGLE_TINT;
    jungle_color *= vignette(uv, 0.3);
    

    // === BLUE (Water) ===
    vec3 water_color = screen_color.rgb * WATER_TINT;
    
	vec2 ps = SCREEN_PIXEL_SIZE;
	// Get blurred color from pixels considered glowing
	vec4 col0 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
	vec4 col1 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
	vec4 col2 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
	vec4 col3 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));
	
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 glowing_col = 0.25 * (col0 + col1 + col2 + col3);
	
	water_color = vec3(col.rgb + glowing_col.rgb);
    
    // === RED (Fire) ===
    vec3 fire_color = screen_color.rgb * FIRE_TINT;
    // Darker with smoke
    float smoke = noise(uv * 2.0 + vec2(time * 0.05, time * 0.08));
    fire_color = mix(fire_color, fire_color * 0.3, smoke * 0.4);
    // Add embers
    float ember_val = embers(uv, time);
    fire_color += vec3(1.0, 0.6, 0.2) * ember_val;
    fire_color *= vignette(uv, 0.6);
    
    // === BLACK (Night) ===
    vec3 night_color = screen_color.rgb * NIGHT_TINT * 0.5;
    // Desaturate
    float gray = dot(night_color, vec3(0.299, 0.587, 0.114));
    night_color = mix(vec3(gray), night_color, 0.6);
    // Moonlight vignette (lighter in center)
    night_color *= 0.7 + vignette(uv, -0.3) * 0.3;
    
    // Select based on mask state
    if (mask_state == 0) {
        final_color = jungle_color;
    } else if (mask_state == 1) {
        final_color = water_color;
    } else if (mask_state == 2) {
        final_color = fire_color;
    } else if (mask_state == 3) {
        final_color = night_color;
    }
    
    COLOR = vec4(final_color, 1.0);
}