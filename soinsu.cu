#include <stdio.h>
#include <math.h>

#define target 2*3*5*10000

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
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
    int *d_target, A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(1024);
	dim3 grid((A+1023)/1024);
	cudaEventRecord(start);
	kernel<<<grid,block>>>(d_target);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float milliseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	cudaFree(d_target);
	printf("\n");
	printf("%10.10f\n", milliseconds);
return 0;
}