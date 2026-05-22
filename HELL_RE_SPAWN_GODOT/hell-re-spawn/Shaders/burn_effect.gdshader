shader_type canvas_item;

// ADDED repeat_enable so the random offset doesn't stretch the edges
uniform sampler2D dissolve_texture : source_color, repeat_enable; 
uniform float dissolve_value : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 ash_color: source_color = vec4(0,0,0,1.0);
uniform vec4 burn_color: source_color = vec4(0.882, 0.777, 0.169 , 1.0);
uniform vec4 proburn_color: source_color = vec4(0.804, 0.2, 0.093 , 1.0);

// --- NEW: Randomization Uniforms ---
uniform vec2 noise_offset = vec2(0.0, 0.0);
uniform vec2 noise_scale = vec2(1.0, 1.0);

void fragment(){
    vec4 main_texture = texture(TEXTURE, UV);
    
    // --- NEW: Apply random flip and offset to the noise ---
    vec2 randomized_uv = (UV * noise_scale) + noise_offset;
    vec4 noise_texture = texture(dissolve_texture, randomized_uv);
    
    // Your exact math below:
    float burn_size_step = burn_size * step(0.0005, dissolve_value) * step(dissolve_value, 0.999);
    float threshold = smoothstep(noise_texture.x-burn_size_step, noise_texture.x, dissolve_value);
    float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);
    
    COLOR.a *= threshold;
    vec3 new_burn_color1 = mix(proburn_color.rgb , burn_color.rgb , 1.0-pow(1.0-border , 5));
    vec3 new_burn_color2 = mix(ash_color.rgb , new_burn_color1 , 1.0-pow(1.0-border , 1000));
    COLOR.rgb = mix(new_burn_color2, main_texture.rgb, border);
}