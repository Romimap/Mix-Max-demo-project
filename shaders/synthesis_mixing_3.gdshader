shader_type spatial;

#include "includes/mix_max.gdshaderinc"
#include "includes/tiling_and_blending.gdshaderinc"



uniform sampler2D colorA 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D priorityA 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normalA 		: filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;
uniform sampler2D roughnessA 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform float micro_priorityA	: hint_range(0.0, 0.1, 0.001) = 0.002;

uniform sampler2D colorB 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D priorityB 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normalB 		: filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;
uniform sampler2D roughnessB 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform float micro_priorityB	: hint_range(0.0, 0.1, 0.001) = 0.002;

uniform sampler2D colorC 		: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D priorityC 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normalC 		: filter_linear_mipmap_anisotropic, repeat_enable, hint_normal;
uniform sampler2D roughnessC 	: filter_linear_mipmap_anisotropic, repeat_enable;
uniform float micro_priorityC	: hint_range(0.0, 0.1, 0.001) = 0.002;

uniform sampler2D mask : filter_linear, repeat_disable;


varying vec2 UV_MASK;

void vertex() {
	UV_MASK = UV;
	UV *= 32.0;
}

void fragment() {
	mixmaxdata A = tiling_and_blending(colorA, priorityA, normalA, roughnessA, micro_priorityA, UV);
	mixmaxdata B = tiling_and_blending(colorB, priorityB, normalB, roughnessB, micro_priorityB, UV);
	mixmaxdata C = tiling_and_blending(colorC, priorityC, normalC, roughnessC, micro_priorityC, UV);
	
	bias(A, texture(mask, UV_MASK).r);
	bias(B, texture(mask, UV_MASK).g);
	bias(C, texture(mask, UV_MASK).b);
	
	mixmaxdata M = MixMax(MixMax(A, B), C);
	
	ALBEDO = pow(M.color, vec3(2.2));
	NORMAL_MAP = M.normal;
	ROUGHNESS = M.roughness;
}
