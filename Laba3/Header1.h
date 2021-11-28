#pragma once


#ifndef __CUDACC__ 
#define __CUDACC__
#endif


#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <thrust/device_vector.h>
#include <device_functions.h>
#include <math.h>

#define EPSILON 0.01
#define COUNT_INTERVAl			100
#define START_INTERVAL_RESEARCH 0
#define STOP_INTERVAL_RESEARCH  10
#define THREADS_PER_BLOCK		2

#define INTERVAL (STOP_INTERVAL_RESEARCH - START_INTERVAL_RESEARCH)


typedef struct
{
	float val;
	bool indicator = false;
} Calculate_Struct;
