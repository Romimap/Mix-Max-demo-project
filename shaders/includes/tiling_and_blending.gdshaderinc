/*
This is a tiling and blending algorithm, first proposed by Heitz and Neyret (2018).
We blend tiles using our Mix-Max operator (Fournier and Sauvage, 2025), 
and use the dual blending (Lutz et al., 2023) to save a texture fetch.

Note that because the Mix-Max handles non-Gaussian input and is binary,
we can be creative while defining the blending weights without causing stationarity artifacts.
*/

#ifndef __TILING_AND_BLENDING__
#define __TILING_AND_BLENDING__

#include "mix_max.gdshaderinc"
#include "hash.gdshaderinc"

uniform float tiling_and_blending_grid_scale : hint_range(1.0, 4.0, 0.01) = 2.5;

void dual_grid(vec2 uv, out float v1, out float v2, out ivec2 id1, out ivec2 id2) {
	vec2 uv_a = (uv * tiling_and_blending_grid_scale);
	vec2 uv_b = (uv * tiling_and_blending_grid_scale) + 0.5;
	
	id1 = ivec2(uv_a);
	id2 = ivec2(uv_b);
	
	//"Manhattan distance" hats over each cell
	v1 = 1.0 - max(abs(fract(uv_a.x) * 2.0 - 1.0), abs(fract(uv_a.y) * 2.0 - 1.0));
	v2 = 1.0 - max(abs(fract(uv_b.x) * 2.0 - 1.0), abs(fract(uv_b.y) * 2.0 - 1.0));
	
	//This is to tweak the transition length, similar to Burley (2019) 
	v1 = pow(v1, 0.4);
	v2 = pow(v2, 0.4);
}

mixmaxdata tiling_and_blending(sampler2D color, sampler2D priority, sampler2D normal, sampler2D roughness, float micro_priority, vec2 uv) {
	float v1, v2;
	ivec2 id1, id2;
	dual_grid(uv, v1, v2, id1, id2);
	
	vec2 uvA = uv + hash2(id1);
	vec2 uvB = uv + hash2(id2);
	
	mixmaxdata A = make_mixmaxdata(uvA, color, priority, normal, roughness, micro_priority);
	mixmaxdata B = make_mixmaxdata(uvB, color, priority, normal, roughness, micro_priority);
	
	B.priorities.mean *= -1.0; // See section 4 in the paper.
	//B.color *= 0.1; //Uncomment this line to visualize the grid !
	
	bias(A, v1);
	bias(B, v2);
	
	return MixMax(A, B);
}

#endif