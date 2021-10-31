#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>
#include <locale.h>

#define BLOCK_SIZE 2

__constant__ int Numbers[1024];

void CPU_realisation(int* n)
{
    printf("число %d раскладывается на следующие простые множители\n", *n);
    int a = *n;
    int v = a;
    for (int i = 2; i < a; i++)
    {
        a = v;
        if (a % i == 0)
        {
            //do
            //{
            //	a = a / i;
            printf("i = %d \n ,", i);
            //	if (a / i == 1) { printf("%d",i); }
            //} while (a / i != 1 && a%i == 0);

        }

    }
}
using namespace std;

__global__ void GPU_realization(int* gpu_value)
{
   
    int a = *gpu_value;
    int val = a;
    int i = 2 + threadIdx.x + blockIdx.x * blockDim.x;
    if (i == 2) { printf("the number %d  can be expanded into the following prime factors:\n", *gpu_value); }

    //printf("%d\n", i);
    if (i < a)
    {
        a = val;
        if (a % i == 0)
        {

            do
            {
                a = a / i;
                //printf("%d ,", i);
                Numbers[i-2] = i;
                printf("%d, ", Numbers[i - 2]);
                if (a / i == 1) { Numbers[i] = i; printf("%d ", Numbers[i - 2]); }
            } while (a / i != 1 && a % i == 0);
        }
    }
}

int main()
{
  
   
    
    setlocale(LC_ALL, "ru");
   /* int* value = (int*)malloc(sizeof(int));

    *value = 35;*/
    //CPU_realisation(value);

    int cpu_value = 9;
    int* gpu_value;
    cudaMalloc((void**)&gpu_value, sizeof(int));
    cudaMemcpy(gpu_value, &cpu_value, sizeof(int), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    float gpu_time = 0.0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    GPU_realization << <(cpu_value + 1023) / 1024, 1024 >> > (gpu_value);
    //CPU_realisation(value);
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&gpu_time, start, stop);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    printf("\ntime = %2fmiliseconds;", gpu_time);

    

    cudaFree(gpu_value);
    return 0;

}