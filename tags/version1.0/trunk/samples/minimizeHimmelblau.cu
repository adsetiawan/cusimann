/* Copyright (c) 2011-2012 University of A Coru�a
 *
 * CUSIMANN: An optimized simulated annealing software for GPUs
 *
 * Authors: A.M. Ferreiro, J.A. Garc�a, J.G. L�pez-Salas, C. V�zquez 
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 * This sample minimizes the Himmelblau's function (
 * http://en.wikipedia.org/wiki/Himmelblau%27s_function ).
 * See supplied whitepaper for more explanations.
 */


#include "cusimann.cuh"
#include "nelderMead.h"

template <class T>
class Himmelblau {
public:
	__host__ __device__ T operator() (const T *x, unsigned int n, void *f_data) const
	{
		T f_x = pow(pow(x[0],2) + x[1] - 11.0f,2) + pow(x[0] + pow(x[1],2) - 7.0f,2);
	
		return f_x;
	}
};

double f_nelderMead(unsigned int n, const double *x, double *grad, void *f_data){
	return Himmelblau<double>()(x,n,f_data);
}

int main() {
	real T_0 = 1000, T_min = 0.1;
	const unsigned int n = 2, N = 100;
	const real rho = 0.99;
	size_t sizeFD = n * sizeof(real);
	real *lb, *ub, *cusimann_minimum = (real*)malloc(sizeFD), f_cusimann_minimum;
	lb = (real*)malloc(sizeFD);
	unsigned int i;
	for(i=0;i<n;i++)
		lb[i] = -6; 
	ub = (real*)malloc(sizeFD);
	for(i=0;i<n;i++)
		ub[i] = 6;

	unsigned int n_threads_per_block = 256;
	unsigned int n_blocks = 64;

	cusimann_optimize(n_threads_per_block, n_blocks, T_0, T_min, N, rho, n, lb, ub, Himmelblau<real>(), NULL, cusimann_minimum, &f_cusimann_minimum);

	printf("cusimann_minimum = [");
	for(i=0;i<n;i++)
		printf(" %f", cusimann_minimum[i]);
	printf(" ]\n");
	printf("f(cusimann_minimum) = %lf\n", f_cusimann_minimum);

	double *nelderMead_minimum = (double*)malloc(n*sizeof(double)), f_nelderMead_minimum;
	nelderMead_optimize(n, lb, ub, cusimann_minimum, f_nelderMead, NULL, nelderMead_minimum, &f_nelderMead_minimum);

	printf("nelderMead_minimum = [");
	for(i=0;i<n;i++)
		printf(" %f", nelderMead_minimum[i]);
	printf(" ]\n");
	printf("f(nelderMead_minimum) = %lf\n", f_nelderMead_minimum);

	free(lb);
	free(ub);
	free(cusimann_minimum);
	free(nelderMead_minimum);
	
	return EXIT_SUCCESS;
}
