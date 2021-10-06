#include <stdio.h>
#include <math.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/times.h>

clock_t times_clock()
{
    struct tms t;
    return times(&t);
}

#define target 2*3*5*1000000000000
#define SIZE 1000

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

__global__ void kernel(long long *A, int *d_B)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	int a = i - j;
	if(i >= __powf(*A,0.5) + 1 && j >= __powf(*A,0.5) + 1 && a > 1 && i < *A && j < *A){
		if(i^2 % *A == j^2 % *A){
			if(sizeof(d_B) / sizeof(long long) < SIZE ){
				d_B[sizeof(d_B) / sizeof(long long)] = a;
			}
		}
	}
}

int main(){
	clock_t t1, t2;
	t1 = times_clock();
    int *d_target；
	long long A = target;
	int *d_B;
	int B[SIZE];
	int i, j, k;
    cudaMalloc((void**)&d_target,sizeof(long long));
	cudaMalloc((void**)&d_B,sizeof(int)*SIZE);
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,&B,sizeof(int)*SIZE,cudaMemcpyHostToDevice);
	dim3 block(32,32);
	dim3 grid((A+31)/32,(A+31)/32);
	kernel<<<grid,block>>>(d_target,d_B);
	float milliseconds = 0;
	cudaMemcpy(&B,d_B,sizeof(int)*SIZE,cudaMemcpyDeviceToHost);
	cudaFree(d_target);
	cudaFree(d_B);	
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
		if(B[i] > 1){
			printf("%d ", B[i]);
		}
	}
	printf("\n");
	t2 = times_clock();
    printf("%10.100f\n", (double)(t2 - t1) / sysconf(_SC_CLK_TCK));
return 0;
}