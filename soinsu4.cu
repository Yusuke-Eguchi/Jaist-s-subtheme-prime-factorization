#include <stdio.h>
#include <math.h>

#define target 2*3*5*10000
#define SIZE 100

__host__ int GCD(int a, int b)
{
	int c;
	if(a == 0){
		return b;
	} else {
		c = b % a;
		return GCD(c, a);
	}
}

__global__ void kernel(int *A, int *d_B, int *d_count)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int a = i - j;
	if(i >= __powf(*A,0.5) + 1 && j >= __powf(*A,0.5) + 1 && a > 1 && i < *A && j < *A){
		if(i^2 % *A == j^2 % *A){
			if(*d_count < SIZE){
				d_B[*d_count] = a;
				*d_count = *d_count + 1;
			}
		}
	}
}

int main(){
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
    int *d_target, A = target, count = 0, *d_count;
	int *d_B;
	int B[SIZE];
	int i, j, k;
	for(i=0;i<SIZE;i++){
		B[i] = 0;
	}
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMalloc((void**)&d_B,sizeof(int)*SIZE);
	cudaMalloc((void**)&d_count,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,&B,sizeof(int)*SIZE,cudaMemcpyHostToDevice);
	cudaMemcpy(d_count,&count,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32,(A+31)/32);
	cudaEventRecord(start);
	kernel<<<grid,block>>>(d_target,d_B,d_count);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float milliseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	cudaMemcpy(&B,d_B,sizeof(int)*SIZE,cudaMemcpyDeviceToHost);
	cudaMemcpy(&count,d_count,sizeof(int),cudaMemcpyDeviceToHost);
	cudaFree(d_target);
	cudaFree(d_B);	
	cudaFree(d_count);
	for(i=0;i<SIZE;i++){
		B[i] = GCD(B[i], A);
	}
	for(i=0;i<SIZE;i++){
		for(k=2;sqrtf(B[i])>=k;k++){
			if(B[i] % k == 0){
				B[i] = 0;
			}
		}
	}
	for(i=0;i<SIZE;i++){
		for(j=i+1;j<SIZE;j++){
			if(B[i] == B[j]){
				B[j] = 0;
			}
		}
	}
	for(i=0;i<SIZE;i++){
		if(B[i] != 0 && B[i] != 1){
			printf("%d ", B[i]);
		}
	}
	printf("\n");
	printf("%10.10f\n", milliseconds);
return 0;
}