#include <stdio.h>
#include <math.h>

#define target 2*2*2*3*3*3*5*5*5

__device__ int GCD(int *a, int *b)
{
	int c;
	if(*a == 0){
		return *b;
	} else {
		c = *b % *a;
		return GCD(&c, a);
	}
}

__global__ void kernel(int *A)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int k;
	int a = i - j, b, flag = 0;
	if(i >= __powf(*A,0.5) && j >= __powf(*A,0.5) && a > 1 && i < *A && j < *A){
		if(i^2 % *A == j^2 % *A){
			b = GCD(&a, A);
			for(k=2;b>k;k++){
				if(b % k == 0){
					flag = 1;
				}
			}
			if(flag == 0 && b != 1){
				printf("%d ", b);
			}
		}
	}
}

int main(){
    int *d_target, A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32,(A+31)/32);
	kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
return 0;
}