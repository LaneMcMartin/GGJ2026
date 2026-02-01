shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	// Calculate distance from center
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	// Create vignette effect
	float vignette = smoothstep(0.8, 0.2, dist);
	
	// Mix with red color based on intensity
	COLOR = mix(vignette_color, vec4(0.0), vignette);
	COLOR.a = intensity * (1.0 - vignette);
}
