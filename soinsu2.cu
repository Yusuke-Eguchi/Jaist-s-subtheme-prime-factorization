#include <stdio.h>
#include <math.h>

#define target 2*3*5

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

__global__ void kernel(int *A, int *d_B, int *d_count)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int k;
	int a = i - j, b, flag = 0;
	if(i >= __powf(*A,0.5) + 1 && j >= __powf(*A,0.5) + 1 && a > 1 && i < *A && j < *A){
		if(i^2 % *A == j^2 % *A){
			b = GCD(&a, A);
			for(k=2;b>k;k++){
				if(b % k == 0){
					flag = 1;
				}
			}
			if(flag == 0 && b != 1){
				d_B[*d_count] = b;
				*d_count++;
			}
		}
	}
}

int main(){
    int *d_target, A = target, count, *d_count;
	int *d_B;
	int B[target];
	int i, j;
	for(i=0;i<A;i++){
		B[i] = 0;
	}
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMalloc((void**)&d_B,sizeof(int)*A);
	cudaMalloc((void**)&d_count,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,&B,sizeof(int)*A,cudaMemcpyHostToDevice);
	cudaMemcpy(d_count,&count,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32,(A+31)/32);
	kernel<<<grid,block>>>(d_target,d_B,d_count);
	cudaMemcpy(&B,d_B,sizeof(int)*A,cudaMemcpyDeviceToHost);
	cudaMemcpy(&count,d_count,sizeof(int),cudaMemcpyDeviceToHost);
	cudaFree(d_target);
	cudaFree(d_B);	
	cudaFree(d_count);
	printf("%d\n", count);
	for(i=0;i<count;i++){
		if(B[i] != 0){
			printf("%d ", B[i]);
		}
	}
	for(i=0;i<count;i++){
		for(j=i+1;j<count;j++){
			if(B[i] == B[j]){
				B[j] = 0;
			}
		}
	}
	for(i=0;i<count;i++){
		if(B[i] != 0){
			printf("%d ", B[i]);
		}
	}
	printf("\n");
return 0;
}