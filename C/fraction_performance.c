#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include "fraction.h"

#define TERMINAL_COLUMNS 50     // Columns in terminal -- used for displaying histogram
#define MAX_DENOMINATORS 1000   // Maximum number of randomly chosen denominators
#define MAX_TICK_COUNT  50     // Max number of clock ticks for conversion from double to fraction to take
#define MAX_LOOP_COUNT 10       // Maximum number of loops expected to calculate

#ifdef CALCULATE_LOOP_STATISTICS
  extern int loops;
#endif

typedef struct {
  double average;
  double standard_deviation;
  int size;
  int median;
  int mode;
} stats_t;

stats_t calc_stats(int* freq_data,int n)
{
  stats_t s;

  // Calculate sample size, sum, mode, and average
  int i,sum=0,max_freq=0;
  s.size=0;
  for(i=0;i<n;i++) {
    s.size+=freq_data[i];
    sum+=i*freq_data[i];
    if(freq_data[i] > max_freq) {
      max_freq = freq_data[i];
      s.mode=i;
    }
  }
  s.average=((double)sum)/((double)s.size);

  // Get median and variance
  double var=0;
  int count=0;
  s.median=-1;
  for(i=0;i<n;i++) {
    var+=(i-s.average)*(i-s.average)*freq_data[i];
    count += freq_data[i];
    if(s.median == -1 && count >= s.size/2) {
      s.median=i;
    }
  }

  // standard deviation
  s.standard_deviation=sqrt(var/(s.size-1));
  return s;
}

void display_graph(int *freq_data,int n,const char* xlabel,const char* ylabel)
{
  char histogram[TERMINAL_COLUMNS+1];
  int i,max=0;
  for(i=0;i<n;i++)
    if(freq_data[i]>max)
      max=freq_data[i];

  printf("\n%s |           %s\n",xlabel,ylabel);
  printf("-----------------------------------------------------------------\n");
  double scale=((double)TERMINAL_COLUMNS)/max;
  histogram[0]='|';
  for(i=0;i<n;i++) {
    int height=round(freq_data[i]*scale);
    memset(histogram+1,'#',height);
    histogram[height+1]=0;
    printf(" %2d   %s %d\n",i,histogram,freq_data[i]);
  }
  printf("\n");
}

void do_test(int denominator,int* tick_freq,int *max_ticks,int* loop_freq,int *max_loops)
{
  int i;
  for(i=1;i<denominator;i++) {
    clock_t start=clock();
    fraction_from_double(((double)i)/((double)denominator));
    int ticks=clock()-start;
    if(ticks < MAX_TICK_COUNT) {
      tick_freq[ticks]++;
      if(ticks > *max_ticks)
        *max_ticks=ticks;
    } else {
      printf("Clock ticks %d > expected max of %d -- value ignored\n",ticks,MAX_TICK_COUNT);
    }
#ifdef CALCULATE_LOOP_STATISTICS
    if(loops < MAX_LOOP_COUNT) {
      loop_freq[loops]++;
      if(loops > *max_loops)
        *max_loops=loops;
    } else {
      printf("Loops %d > expected max of %d -- value ignored\n",loops,MAX_LOOP_COUNT);
    }
#endif
  }
}

void show_results(int* tick_freq,int max_ticks,int *loop_freq,int max_loops)
{
//  fraction_t f;
  char f_str[32];
  printf("Max time (in clock ticks): %d\n",max_ticks);
  stats_t stats=calc_stats(tick_freq,max_ticks+1);
  printf("Sample size: %d\n",stats.size);
  // Of course this has to be printed as a fraction
  fraction_as_mixed_fraction_to_s(fraction_from_double(((int)(stats.average*10))/10.0),f_str,32);
  printf("Average: %s\n",f_str);
  printf("Median: %d\n",stats.median);
  printf("Mode: %d\n",stats.mode);
  fraction_as_mixed_fraction_to_s(fraction_from_double(((int)(stats.standard_deviation*100))/100.0),f_str,32);
  printf("Standard Deviation: %s\n",f_str);
  display_graph(tick_freq,max_ticks+1,"Ticks","Frequency");
#ifdef CALCULATE_LOOP_STATISTICS
  printf("Max loops: %d\n",max_loops);
  stats=calc_stats(loop_freq,max_loops+1);
  printf("Sample size: %d\n",stats.size);
  fraction_as_mixed_fraction_to_s(fraction_from_double(((int)(stats.average*10))/10.0),f_str,32);
  printf("Average: %s\n",f_str);
  printf("Median: %d\n",stats.median);
  printf("Mode: %d\n",stats.mode);
  fraction_as_mixed_fraction_to_s(fraction_from_double(((int)(stats.standard_deviation*100))/100.0),f_str,32);
  printf("Standard Deviation: %s\n",f_str);
  display_graph(loop_freq,max_loops+1,"Loops","Frequency");
#else
  printf("\nStatistics for loop count not gathered. To enable loop statistics:\n");
  printf("  make clean\n");
  printf("  CFLAGS=-DCALCULATE_LOOP_STATISTICS make\n");
#endif
}

/*
  Gather stats on fraction from 1/denominator to (denominator-1)/denominator
*/
void simple_test(int denominator)
{
  int max_ticks=0,tick_freq[MAX_TICK_COUNT];
  memset(tick_freq,0,MAX_TICK_COUNT*sizeof(int));
  int max_loops=0,loop_freq[MAX_LOOP_COUNT];
  memset(loop_freq,0,MAX_LOOP_COUNT*sizeof(int));
  do_test(denominator,tick_freq,&max_ticks,loop_freq,&max_loops);
  show_results(tick_freq,max_ticks,loop_freq,max_loops);
}

void random_test(int min_tests)
{
  int max_ticks=0,tick_freq[MAX_TICK_COUNT];
  memset(tick_freq,0,MAX_TICK_COUNT*sizeof(int));
  int max_loops=0,loop_freq[MAX_LOOP_COUNT];
  memset(loop_freq,0,MAX_LOOP_COUNT*sizeof(int));
  srand(time(NULL));
  int *denominators=malloc(MAX_DENOMINATORS*sizeof(int));
  int n_tests=0,n_denominators=0;
  while(n_tests < min_tests && n_denominators < MAX_DENOMINATORS) {
    int denominator=rand() % 100000;
    // make sure it's unique
    int i,found=0;
    for(i=0;i<n_denominators;i++) {
      if(denominators[i]==denominator) {
        found=1;
        break;
      }
    }
    if(!found) {
      denominators[n_denominators++]=denominator;
      n_tests+=denominator-1;
    }
  }
  int i;
  for(i=0;i<n_denominators;i++) {
    do_test(denominators[i],tick_freq,&max_ticks,loop_freq,&max_loops);
  }
  show_results(tick_freq,max_ticks,loop_freq,max_loops);
  free(denominators);
}

int main(int argc,char* argv[])
{
//  simple_test(1000);
  random_test(1000);
  return 0;
}
