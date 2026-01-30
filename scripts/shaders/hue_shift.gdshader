// Benmo @ godotshaders.com
shader_type canvas_item;

uniform float hue_shift: hint_range(0.0, 1.0) = 0.0;

vec4 shift_hue(in vec4 color, in float shift) {
    vec3 gray = vec3(0.57735);
    vec3 projection = gray * dot(gray, color.rgb);
    vec3 U = color.rgb - projection;
    vec3 V = cross(gray, U);
    vec3 shifted = U * cos(shift * 2.0 * PI) + V * sin(shift * 2.0 * PI) + projection;
    return vec4(shifted, color.a);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 shifted = shift_hue(tex_color, hue_shift);
    COLOR = vec4(shifted.rgb, shifted.a * COLOR.a);  // Only apply alpha modulation
}