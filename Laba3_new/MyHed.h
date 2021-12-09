#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdlib.h>
#include <stdio.h>


#define CUDA_CHECK_ERROR(call)											  \
do																		  \
{																		  \
	cudaError_t err = call;												  \
		if (cudaSuccess != err)											  \
		{																  \
			fprintf(stderr, "Cuda error in file '%s' in line %i : %s.\n", \
				__FILE__, __LINE__, cudaGetErrorString(err));			  \
			exit(EXIT_FAILURE);                                           \
		}																  \
} while(0)																  \


class Global : IMemType
{
	// Óíàñëåäîâàíî ÷åðåç IMemType

public:
	virtual void Inverse() override;
	float* inputArr;
	float* outputArr;
	int size;
	Global(float* devInputArr, float* devOutputArr, int size, int block_size);
};





