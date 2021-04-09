#include <stdio.h>
#include <math.h>

#define target 2*3*5*10^50

__device__ int GCD(long int *a, long int *b)
{
	long int c;
	if(*a == 0){
		return *b;
	} else {
		c = *b % *a;
		return GCD(&c, a);
	}
}

__global__ void kernel(long int *A, int *d_B)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int k;
	int flag = 0;
	long int a = i - j, b;
	if(i >= __powf(*A,0.5) + 1 && j >= __powf(*A,0.5) + 1 && a > 1 && i < *A && j < *A){
		if(i^2 % *A == j^2 % *A){
			b = GCD(&a, A);
			for(k=2;b>k;k++){
				if(b % k == 0){
					flag = 1;
				}
			}
			if(flag == 0 && b != 1){
				d_B[i*j+j] = b;
			}
		}
	}
}

int main(){
    long int *d_target, A = target;
	long int *d_B, B[target*target];
	int i, j;
	for(i=0;i<A*A;i++){
		B[i] = 0;
	}
    cudaMalloc((void**)&d_target,sizeof(long int));
	cudaMalloc((void**)&d_B,sizeof(long int)*A*A);
	cudaMemcpy(d_target,&A,sizeof(long int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,&B,sizeof(long int)*A*A,cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32,(A+31)/32);
	kernel<<<grid,block>>>(d_target,d_B);
	cudaMemcpy(&B,d_B,sizeof(long int)*A*A,cudaMemcpyDeviceToHost);
	cudaFree(d_target);
	cudaFree(d_B);	
	for(i=0;i<A*A;i++){
		for(j=i+1;j<A*A;j++){
			if(B[i] == B[j]){
				B[j] = 0;
			}
		}
	}
	for(i=0;i<A*A;i++){
		if(B[i] != 0){
			printf("%d ", B[i]);
		}
	}
	printf("\n");
return 0;
}