#ifndef __MIX_MAX__
#define __MIX_MAX__

#include "probability_functions.gdshaderinc"

struct mixmaxdata {
	vec3 color; // Mean value of the texture over the footprint
	gaussian_distribution priorities; // Gaussian distribution of the priorities over the footprint   
	vec3 normal;
	float roughness;
};


mixmaxdata make_mixmaxdata(vec2 uv, sampler2D color, sampler2D priority, sampler2D normal, sampler2D roughness, float base) {
	float B = texture(priority, uv).r; //mean of the priorities
	float M = texture(priority, uv).g; //mean of the priorities squared (see LEAN-mapping)
	
	mixmaxdata m;
	m.color = texture(color, uv).rgb;
	m.normal = texture(normal, uv).rgb;
	m.roughness = texture(roughness, uv).r;
	m.priorities.mean = B;
	m.priorities.variance = M - B * B + base;
	return m;
}

void bias(inout mixmaxdata M, float v) {
	M.priorities.mean += v;
}


mixmaxdata MixMax(mixmaxdata A, mixmaxdata B) {
	mixmaxdata result;
	float t = proba_a_over_b(A.priorities, B.priorities);
	result.color = mix(A.color, B.color, t);
	result.normal = mix(A.normal, B.normal, t);
	result.roughness = mix(A.roughness, B.roughness, t);
	result.priorities = distribution_max_ab(A.priorities, B.priorities);
	return result;
}

#endif