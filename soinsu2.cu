#include <stdio.h>
#include <math.h>

#define target 2*2*2*3*3*3*5*5*5

__device__ void kernel2(int *A){
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int x;
	if(i <= __sqrt(*A)){
		x = __sqrt(*A) + i;
	}
}

__global__ void kernel(int *A)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	float w;
	if(i <= __sqrt(*A)){
		for(j = 2; j <= __sqrt(*A); j++) {
			kernel2(*A);
            printf("%d ",i);
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