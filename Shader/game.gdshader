shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 7.0;
const float vignette_multiplier = 2.0;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.002;
uniform float noise_intensity : hint_range(0.0, 0.3) = 0.1;
uniform float flicker_intensity : hint_range(0.0, 0.2) = 0.05;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float warp_intensity : hint_range(0.0, 0.1) = 0.03; // Intenzitet CRT zakrivljenja piksela

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 warp_uv(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    uv += uv * pow(length(uv), 2.0) * warp_intensity;
    return uv * 0.5 + 0.5;
}

void fragment() {
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    vec2 uv_offset = centered_uv.yx / curvature;
    vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
    vec2 final_uv = warp_uv((warped_uv + 1.0) / 2.0); // Dodaj CRT warp

    // RGB aberacija - pomeranje crvenog i plavog kanala
    float ca_offset = chromatic_aberration * length(centered_uv);
    vec3 screen_color;
    screen_color.r = textureLod(screen_texture, final_uv + vec2(ca_offset, 0.0), 0.2).r;
    screen_color.g = textureLod(screen_texture, final_uv, 0.2).g;
    screen_color.b = textureLod(screen_texture, final_uv - vec2(ca_offset, 0.0), 0.2).b;

    // Scanline efekat
    vec3 scanlines = vec3(sin(2.0 * warped_uv.y * 180.0) * 0.1 + 0.9);
    
    // Vignette efekat
    vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));
    
    // Statički šum
    float noise = (random(SCREEN_UV + vec2(TIME, TIME * 0.5)) - 0.5) * noise_intensity;

    // Flickering efekat
    float flicker = (sin(TIME * 50.0) * 0.5 + 0.5) * flicker_intensity;
    
    // Glow efekat
    vec3 glow = screen_color * glow_intensity;

    // Kombinovanje efekata
    screen_color *= scanlines;
    screen_color -= vignette * vignette_multiplier;
    screen_color += noise + flicker;
    screen_color += glow;

    COLOR = vec4(screen_color, 1.0);
}
