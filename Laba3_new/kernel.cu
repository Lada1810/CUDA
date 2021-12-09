/***********************LABA3*************************/
//Атор: Русина Лада
//Группа М80-114-М-21
//Дата 11.11.2021
//Вариат 9 
/*-----------------------------------------------------*/


#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "MyHed.h"
#include <thrust/device_vector.h>

#ifndef __CUDACC__ 
#define __CUDACC__
#endif

#include <device_functions.h>


using namespace std;

typedef struct
{
	float val;
	bool indicator = false;
} root;

__global__ void kernel_(root* r, double dx, double start)
{
	__shared__ double temp[3];
	__shared__ double val[3];
	__shared__ bool stop;


	val[threadIdx.x] = (blockIdx.x * dx + threadIdx.x * dx * 0.5) + start;

	if(0.89 * pow(val[threadIdx.x],3) - 2.8 * pow(val[threadIdx.x],2) - 3.7 * val[threadIdx.x] +11.2 == 0)
	{
		r[blockIdx.x].val = 0.;
		r[blockIdx.x].indicator = true;
		stop = true;
	}
	__syncthreads();

	while (!stop)
	{

		if ((log(8 * val[threadIdx.x]) - 9 * val[threadIdx.x] + 3) < 0)
			temp[threadIdx.x] = 0;
		else
			temp[threadIdx.x] = 1;

		__syncthreads();

		if (threadIdx.x == 1)
		{
			if (abs(val[threadIdx.x + 1] - val[threadIdx.x - 1]) < 0.001)
			{
				r[blockIdx.x].val = val[threadIdx.x];
				r[blockIdx.x].indicator = true;

				stop = true;
				break;
			}

			if (temp[threadIdx.x - 1] != temp[threadIdx.x])
			{
				val[threadIdx.x + 1] = val[threadIdx.x];
				val[threadIdx.x] = (val[threadIdx.x - 1] + val[threadIdx.x + 1]) / 2;

			}
			else if (temp[threadIdx.x + 1] != temp[threadIdx.x])
			{
				val[threadIdx.x - 1] = val[threadIdx.x];
				val[threadIdx.x] = (val[threadIdx.x - 1] + val[threadIdx.x + 1]) / 2;
			}
			else
			{
				stop = true;
				break;
			}
		}
	}
}

int main()
{
	double start = 0.0;
	double stop = 10.0;

	int sub_intervals = 100.0;

	double interval_size = stop - start;

	double dx = interval_size / sub_intervals;

	cudaEvent_t s;
	cudaEvent_t e;

	thrust::device_vector<root> vec(sub_intervals);

	CUDA_CHECK_ERROR(cudaEventCreate(&s));
	CUDA_CHECK_ERROR(cudaEventCreate(&e));

	CUDA_CHECK_ERROR(cudaEventRecord(s, 0));

	cudaEvent_t start, stop;
	float gpu_time = 0.0;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);


	kernel_ << <sub_intervals, 3 >> > (thrust::raw_pointer_cast(&vec[0]), dx, start);


	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&gpu_time, start, stop);

	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	printf("\ntime = %2fmiliseconds;\n", gpu_time);

	printf("Корни уравнения ровняются:\n")
	int roots = 0;
	for (int i = 0; i < vec.size(); i++)
	{
		root r = vec[i];
		if (r.indicator)
		{
			roots++;
			printf("x%d = %f\n", roots, r.val);
		}
	}
	
	CUDA_CHECK_ERROR(cudaEventRecord(e, 0));


	CUDA_CHECK_ERROR(cudaEventSynchronize(e));

	float time_elapsed = 0;
	CUDA_CHECK_ERROR(cudaEventElapsedTime(&time_elapsed, s, e));
	printf("\n");
	printf("done in %f milliseconds\n", time_elapsed);

	return 0;
}