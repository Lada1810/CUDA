
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>
#include <locale.h>

__global__ void expon(double *a, double val)
{
	*a = exp(val);
		
}

void expon_cpu(double *a, double val)
{
	*a = exp(val);
	
}


int main()
{
	setlocale(LC_ALL, "ru");
	printf("В какую степень возвести экспоненту?\n");
	double val;
	scanf("%lf", &val);

	double* a;
	
	double a_cpu;

	cudaMalloc((void**)&a, sizeof(double));

	cudaEvent_t start, stop;
	float gpu_time = 0.0;
		cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	//expon_cpu(&a_cpu, val);												//CPU
	expon <<< 1, 1024 >>> (a, val);											// GPU

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&gpu_time, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	printf("\nВремя равно: %f", gpu_time);

	
	cudaMemcpy(&a_cpu, a, sizeof(double), cudaMemcpyDeviceToHost);		//GPU
	printf("\na= %lf", a_cpu);


	cudaFree(a);
	
}

