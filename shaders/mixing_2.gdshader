shader_type spatial;

#include "includes/mix_max.gdshaderinc"



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



varying float v;

void vertex() {
	v = (UV.x - 0.5) * 0.5;
}

void fragment() {
	mixmaxdata A = make_mixmaxdata(UV, colorA, priorityA, normalA, roughnessA, micro_priorityA);
	mixmaxdata B = make_mixmaxdata(UV, colorB, priorityB, normalB, roughnessB, micro_priorityB);
	
	bias(A, v);
	bias(B, -v);
	
	mixmaxdata M = MixMax(A, B);
	
	ALBEDO = pow(M.color, vec3(2.2));
	NORMAL_MAP = M.normal;
	ROUGHNESS = M.roughness;
}
