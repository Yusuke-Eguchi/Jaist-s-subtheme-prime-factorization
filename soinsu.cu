#include <stdio.h>
#include <math.h>

#define target 2*2*2*3*3*3*5*5*5

__global__ void kernel(int *A)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j;
	int flag = 0;
	if(i < *A && i > 1){
		for(j=2;sqrtf(i)>=j;j++){
			if(i % j == 0){
				flag = 1;
			}
		}
		if(*A % i == 0 && flag == 0){
			printf("%d ", i);
		}
	}
}

int main(){
    int *d_target, A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(1024);
	dim3 grid((A+1023)/1024);
	kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
return 0;
}