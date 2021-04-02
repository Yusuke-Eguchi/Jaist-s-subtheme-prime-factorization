#include <stdio.h>
#include <math.h>

#define target 2*2*2*3*3*3*5*5*5

__device__ int GCD(int a, int b)
{
	int c;	
	if(a == 0){
		return b;
	} else if(a> b){
		return GCD(b, a);
	}else{
		c = b % a;
		return GCD(c, a);
	}
}

__global__ void kernel(int A)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	if(i >= 1 && j >= 1 && i > j){
		if((i+__sqrt(A))^2 % A == (j + __sqrt(A))^2 % A){
			printf("%d ", GCD(i - j, A));
		}
	}
}

int main(){
    int *d_target, A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32, (A+31)/32);
	kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
return 0;
}