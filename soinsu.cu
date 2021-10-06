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

__global__ void kernel(long long *A)
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
	clock_t t1, t2;
    t1 = times_clock();
    int *d_target;
	long long A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(long long),cudaMemcpyHostToDevice);
	dim3 block(1024);
	dim3 grid((A+1023)/1024);
	kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
    t2 = times_clock();
    printf("%10.100f\n", (double)(t2 - t1) / sysconf(_SC_CLK_TCK));
return 0;
}