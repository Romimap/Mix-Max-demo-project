shader_type spatial;

#include "includes/tiling_and_blending.gdshaderinc"
#include "includes/mix_max.gdshaderinc"



uniform sampler2D color 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D priority 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal 		: filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;
uniform sampler2D roughness 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform float micro_priority	: hint_range(0.0, 0.1, 0.001) = 0.002;



void vertex() {
	UV *= 32.0;
}

void fragment() {
	mixmaxdata M = tiling_and_blending(color, priority, normal, roughness, micro_priority, UV);
	
	ALBEDO = pow(M.color, vec3(2.2));
	NORMAL_MAP = M.normal;
	ROUGHNESS = M.roughness;
}
