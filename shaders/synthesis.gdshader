shader_type spatial;

#include "includes/tiling_and_blending.gdshaderinc"
#include "includes/mix_max.gdshaderinc"

uniform sampler2D color 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D priority_bm 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal 		: filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;
uniform sampler2D roughness 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform float micro_priority	: hint_range(0.0, 0.1, 0.001) = 0.002;

uniform float uv_scale : hint_range(0.5, 64.0, 0.1) = 32.0;

void vertex() {
	UV *= uv_scale; // Scales the UV to get a larger synthesis surface
}

void fragment() {
	mixmaxdata M = tiling_and_blending(color, priority_bm, normal, roughness, micro_priority, UV);
	
	ALBEDO = pow(M.color, vec3(2.2)); // color^2.2 is purely visual, to add contrast
	NORMAL_MAP = M.normal;
	ROUGHNESS = M.roughness;
}
