#ifndef __PROBABILITY_FUNCTIONS__
#define __PROBABILITY_FUNCTIONS__

struct gaussian_distribution {
	float mean; // This stores the mean of the priority map S, and the interpolation field v over a footprint
	float variance; // This stores the variance of the priority map S, and the micropriority \lambda over a footprint
};


// Rough but good enough approximation for the CDF of a centered and normalized Gaussian distribution
float CDF(float x) {
	return 0.5 + 0.5 * tanh(0.85 * x);
}

// PDF of a centered and normalized Gaussian distribution
float PDF(float x) {
	return exp(-(x * x * 0.5)) / sqrt(2.0 * PI);
}


// Computes the probability that a random sample in A is greater than a random sample in B
// Equation 13
float proba_a_over_b(gaussian_distribution A, gaussian_distribution B) {
	float w = max(sqrt(A.variance + B.variance), 1e-5); // the max prevents a division by 0 
	return 1.0 - CDF((A.mean - B.mean) / w); 
}


// Computes the mean and the variance of the max of two gaussian distributions
gaussian_distribution distribution_max_ab(gaussian_distribution A, gaussian_distribution B) {
	gaussian_distribution G;
	
	float w = max(sqrt(A.variance + B.variance), 0.001);
	
	// Equation 15
	G.mean = A.mean * CDF((A.mean - B.mean) / w)
	         + B.mean * CDF((B.mean - A.mean) / w)
	         + w * PDF((A.mean - B.mean) / w);
	
	// Equation 16
	G.variance = (A.variance + A.mean * A.mean) * CDF((A.mean - B.mean) / w)
	        + (B.variance + B.mean * B.mean) * CDF((B.mean - A.mean) / w)
	        + (A.mean + B.mean) * w * PDF((A.mean - B.mean) / w)
	        - (G.mean * G.mean);
	
	return G;
}

#endif