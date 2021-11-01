#include <stdio.h>
#include <math.h>
#include <time.h>

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

int main(){
	double t1, t2;
	t1 = get_realtime();
    int target = 2*3*5*10000;
    int i, j, flag = 0;
    for(i=2;target>i;i++){
        flag = 0;
		for(j=2;i>j;j++){
			if(i % j == 0){
				flag = 1;
			}
		}
		if(target % i == 0 && flag == 0){
			printf("%d ", i);
		}
	}
    printf("\n");
	t2 = get_realtime();
    printf("%10.100f\n", (double)(t2 - t1));
    return 0;
}
