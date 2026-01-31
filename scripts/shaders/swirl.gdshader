shader_type canvas_item;

uniform sampler2D noise_texture;
uniform vec3 void_color_1 : source_color = vec3(0.4, 0.1, 0.6);
uniform vec3 void_color_2 : source_color = vec3(0.4, 0.1, 0.6);
uniform float swirl_speed : hint_range(0.1, 2.0) = 0.5;
uniform float swirl_amount : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec2 uv = UV;
    
    // Create the swirl offset.
    float angle = TIME * swirl_speed;
    vec2 swirl_offset = vec2(sin(angle + uv.y * 6.0), cos(angle + uv.x * 6.0)) * swirl_amount;
    
    // Sample noise with distorted UVs.
    float noise = texture(noise_texture, uv + swirl_offset).r;
    
    // Mix between dark and the void color based on noise.
    vec3 final_color = mix(void_color_1, void_color_2, noise);
    
    COLOR = vec4(final_color, 1.0);
}