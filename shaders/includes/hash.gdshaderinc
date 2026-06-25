#ifndef __HASH__
#define __HASH__

//From the Deliot and Heitz implementation (2019)
vec2 hash2(ivec2 ip)
{
	vec2 p = vec2(ip);
	return fract(sin((p) * mat2(vec2(127.1, 311.7), vec2(269.5, 183.3)))*43758.5453);
}

#endif