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

int main(){
    int target = 2*3*5;
    int i, j, flag = 0;
    clock_t t1, t2;
    t1 = times_clock();
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
    t2 = times_clock();
    printf("%f\n", (double)(t2 - t1) / sysconf(_SC_CLK_TCK));
    return 0;
}
