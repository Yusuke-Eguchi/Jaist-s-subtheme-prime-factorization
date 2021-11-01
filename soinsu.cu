#include <stdio.h>
#include <math.h>

#define target 2*3*5*10000000
#define SIZE 100

double get_cputime(void)
{ 
 struct timespec t;
 clock_gettime(CLOCK_REALTIME,&t);
 //clock_gettime(CLOCK_THREAD_CPUTIME_ID,&t);
 return t.tv_sec + (double)t.tv_nsec*1e-9;
}
double get_realtime(void)
{
 struct timespec t;
 clock_gettime(CLOCK_REALTIME,&t);
 return t.tv_sec + (double)t.tv_nsec*1e-9;
}
double get_tick(void){ return (double)1e-9; }

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
			printf("%lld ", i);
		}
	}
}

int main(){
	double t1, t2;
	t1 = get_realtime();
    int *d_target, A = target;
    cudaMalloc((void**)&d_target,sizeof(int));
	cudaMemcpy(d_target,&A,sizeof(int),cudaMemcpyHostToDevice);
	dim3 block(1024);
	dim3 grid((A+1023)/1024);
	kernel<<<grid,block>>>(d_target);
	cudaFree(d_target);
	printf("\n");
	t2 = get_realtime();
    printf("%10.100f\n", (double)(t2 - t1));
return 0;
}