/***********************LABA3*************************/
//Атор: Русина Лада
//Группа М80-114-М-21
//Дата 11.11.2021
//Вариат 9 
/*-----------------------------------------------------*/



#include <stdio.h>

#include "Header1.h"



/* функция корни которой необходимо найти */
__device__ double CalculateFancshion(double x)
{
	return 0.89 * pow(x,3) - 2.8 * pow(x,2) - 3.7 * x + 11.2;
}



/*функция реализующая метод половинного деления*/
__global__ void kernel_(Calculate_Struct* r_structure, double dx, double start)
{
	__shared__ double temp[3];	__shared__ double val[3];	__shared__ bool stop;	//объявляем 2 промежуточных буфера и флаг конца итераций


	val[threadIdx.x] = (blockIdx.x * dx + threadIdx.x * dx * 0.5) + start;

	if (CalculateFancshion(val[threadIdx.x]) == 0)
	{
		r_structure[blockIdx.x].val = 0.;
		r_structure[blockIdx.x].indicator = true;
		stop = true;
	}
	__syncthreads();//синхронизируем вычисление на нитях

	while (!stop) //запускаем цикл вычисления пока флаг не станет ложным 
	{

		if (CalculateFancshion(val[threadIdx.x]) < 0)
			temp[threadIdx.x] = 0;
		else
			temp[threadIdx.x] = 1;

		__syncthreads();

		if(threadIdx.x == 1)
		{
			if (abs(val[threadIdx.x + 1] - val[threadIdx.x - 1]) < EPSILON)
			{
				r_structure[blockIdx.x].val = val[threadIdx.x];
				r_structure[blockIdx.x].indicator = 1;//true

				stop = 1; //true
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
				stop = false;
				
			}
		}
	}
}


int main()
{
	setlocale(LC_ALL, "ru");
	thrust::device_vector<Calculate_Struct> vec(COUNT_INTERVAl);
	double dx = INTERVAL / COUNT_INTERVAl;

	cudaEvent_t start, stop;
	float gpu_time = 0.0;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	kernel_ << <COUNT_INTERVAl, THREADS_PER_BLOCK >> > (thrust::raw_pointer_cast(&vec[0]), dx, START_INTERVAL_RESEARCH);

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&gpu_time, start, stop);

	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	printf("\ntime = %2fmiliseconds;", gpu_time);


	int index = 0;
	printf("Корни уравнения ровняются:\n")
	for (int i = 0; i < vec.size(); i++)
	{
		Calculate_Struct r = vec[i];
		if (r.indicator)
		{
			index++;
			printf("x %d = %f\n", index, r.val);
		}
	}
	
	


	
	

	return 0;
}