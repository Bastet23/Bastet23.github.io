shader_type canvas_item;

// --- SETTINGS ---
uniform float fov : hint_range(1, 179) = 90;
uniform float border_scale = 1.0; // Keep at 1.0 since we fixed the scaling issue
uniform float inset : hint_range(0, 1) = 0.0;

// --- ROTATION FIX ---
// Set this to 45.0 (or -45.0) to match your object's rotation
uniform float correction_angle : hint_range(-180, 180) = 45.0; 

// --- MOVEMENT ---
// UPDATED: Increased default sensitivity so you can actually see the tilt on small items!
uniform float sensitivity : hint_range(0.0, 5.0) = 3.0; 
uniform float max_tilt : hint_range(0.0, 0.5, 0.00001) = 0.2; 
uniform float auto_wobble_speed = 1.0;
uniform float auto_wobble_amp = 0.05;

// --- INPUTS ---
// These match your hovering.gd script perfectly
uniform float hovering : hint_range(0, 1) = 0.0;
uniform vec2 mouse_pos; 

// --- INTERNAL ---
varying flat mat3 inv_rot_mat;
varying vec3 p;
varying flat vec2 o;

// Helper: Rotates a 2D vector by an angle (in radians)
vec2 rotate_vector(vec2 v, float angle_rad) {
	float c = cos(angle_rad);
	float s = sin(angle_rad);
	return vec2(
		v.x * c - v.y * s,
		v.x * s + v.y * c
	);
}

void vertex(){
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 centered_vertex = VERTEX - (size / 2.0);
	
	// 1. Calculate Raw Tilt
	// We normalize pixel distance to a generic -1 to 1 range for better control
	vec2 tilt = (mouse_pos / size) * sensitivity * hovering;
	
	float wobble = sin(TIME * auto_wobble_speed) * auto_wobble_amp * hovering;
	tilt += vec2(wobble, wobble * 0.5);

	// 2. COUNTER-ROTATE (The Fix for Diamond Shape)
	tilt = rotate_vector(tilt, radians(-correction_angle));

	// 3. Clamp Tilt
	tilt.x = clamp(tilt.x, -max_tilt, max_tilt);
	tilt.y = clamp(tilt.y, -max_tilt, max_tilt);

	// 4. Rotation Matrix
	float sin_b = sin(tilt.x);
	float cos_b = cos(tilt.x);
	float sin_c = sin(-tilt.y);
	float cos_c = cos(-tilt.y);
	
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;
	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;
	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;
	
	// 5. Perspective
	float t = tan(fov / 360.0 * PI);
	vec2 uv_centered = UV - 0.5;
	vec2 pos = centered_vertex;
	pos += uv_centered * size * t * (1.0 - inset);
	
	VERTEX = (pos + (size / 2.0)) * border_scale;
}

void fragment(){
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 uv_centered = (UV - 0.5);

	float t = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3(uv_centered * size, 0.5 / t);
	float v = (0.5 / t) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;
	vec2 final_uv = (p.xy / p.z).xy - o;
	final_uv = (final_uv / size) + 0.5;

	if (final_uv.x >= 0.0 && final_uv.x <= 1.0 && final_uv.y >= 0.0 && final_uv.y <= 1.0) {
		COLOR = texture(TEXTURE, final_uv) * COLOR;
	} else {
		COLOR = vec4(0.0);
	}
}