#include <stdio.h>
#include <math.h>

#define target 2*2*2*3*3*3*5*5*5

__device__ void GCD(int *a, int *b)
{
	if(*a = 0){
		return *b;
	}
	else{
		return GCD(b%a, a)
	}
}

__global__ void kernel(int *A)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int a;
	if(i >= 1 && j >= 1 && i > j){
		if((i+__sqrt(*A))^2 % *A == (j + __sqrt(*A))^2 % *A &&){
			a = GCD(i + __sqrt(*A), j + __sqrt(*A));
		}
	}
retuen 0;
}

int main(){
    int *d_target, A = target, a, b, i, j;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32, (A+31)/32);
	(i, j, a, b) = kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
return 0;
}