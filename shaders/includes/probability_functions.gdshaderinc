#ifndef __PROBABILITY_FUNCTIONS__
#define __PROBABILITY_FUNCTIONS__

struct gaussian_distribution {
	float mean;
	float variance;
};

// Rough but good enough approximation for the CDF of a centered and normalized Gaussian distribution
float CDF(float x) {
	return 0.5 + 0.5 * tanh(0.85 * x);
}

float PDF(float x) {
	return exp(-(x * x * 0.5)) / sqrt(2.0 * PI);
}

//See equation (13) in the paper.
float proba_a_over_b(gaussian_distribution A, gaussian_distribution B) {
	float w = max(sqrt(A.variance + B.variance), 0.001);

	return 1.0 - CDF((A.mean - B.mean) / w); 
}


//See equation (15) and (16) in the paper.
gaussian_distribution distribution_max_ab(gaussian_distribution A, gaussian_distribution B) {
	gaussian_distribution G;
	
	float w = max(sqrt(A.variance + B.variance), 0.001);
	G.mean = A.mean * CDF((A.mean - B.mean) / w)
	         + B.mean * CDF((B.mean - A.mean) / w)
	         + w * PDF((A.mean - B.mean) / w);
	
	G.variance = (A.variance + A.mean * A.mean) * CDF((A.mean - B.mean) / w)
	        + (B.variance + B.mean * B.mean) * CDF((B.mean - A.mean) / w)
	        + (A.mean + B.mean) * w * PDF((A.mean - B.mean) / w)
	        - (G.mean * G.mean);
	return G;
}

#endif