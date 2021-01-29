#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <sys/times.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <getopt.h>
#include "fraction.h"

#ifndef TERMINAL_COLUMNS
#define TERMINAL_COLUMNS 50     // Columns in terminal -- used for displaying histogram
#endif

#ifdef CALCULATE_LOOP_STATISTICS
  extern int nLoops;
#endif

/*
 * Dynamic array for POD type or structures made of POD types
 * Assignement done by copy
*/
typedef int(*cmp_method)(const void*,const void*);
typedef struct {
  char* array;
  cmp_method cmp_method;
  unsigned int type_size;
  unsigned int capacity;
  unsigned int size;
} dynamic_array_t;

dynamic_array_t* dynamic_array_newp(dynamic_array_t* this,int ts,cmp_method cmp_method)
{
  this->type_size=ts;
  this->capacity=16;
  this->size=0;
  this->array=malloc(this->capacity*this->type_size);
  this->cmp_method=cmp_method;
  return this;
}

void dynamic_array_deletep(dynamic_array_t* this)
{
  if(this->array)
    free(this->array);
}

#define dynamic_array_begin(da) ((da)->array)
#define dynamic_array_end(da) ((da)->array + (da)->type_size*(da)->size)

void dynamic_array_increase_capacity(dynamic_array_t* this)
{
  this->capacity<<=1;
  this->array=realloc(this->array,this->capacity*this->type_size);
}

void* dynamic_array_find(dynamic_array_t* this,void* data)
{
  char *i;
//  char* ptr=this->array;
  for(i=dynamic_array_begin(this);i!=dynamic_array_end(this);i+=this->type_size)
    if(this->cmp_method(data,i) == 0)
      break;
  return i;
}

void* dynamic_array_add(dynamic_array_t* this,void* data)
{
  char* pos=dynamic_array_find(this,data);
  if(pos == dynamic_array_end(this)) {
    if(this->size == this->capacity) {
      dynamic_array_increase_capacity(this);
      pos=this->array+this->size*this->type_size;
    }
    this->size++;
    memcpy(pos,data,this->type_size);
  }
  return pos;
}

void dynamic_array_sort(dynamic_array_t* this)
{
  qsort(this->array,this->size,this->type_size,this->cmp_method);
}

#define dynamic_array_size(da) (da->size)
#define dynamic_array_capacity(da) (da->capacity)

typedef struct {
  double average;
  double standard_deviation;
  int size;
  int median;
  int mode;
} statistics_t;


typedef struct {
  int value;
  int frequency;
} frequency_t;

int frequency_cmp(const void* freq1,const void* freq2)
{
  return ((const frequency_t*)freq1)->value - ((const frequency_t*)freq2)->value;
}

typedef struct {
  dynamic_array_t; //* array;
  int max_freq;
} frequency_array_t;

frequency_array_t* new_frequency_array()
{
  frequency_array_t* fa=malloc(sizeof(frequency_array_t));
  dynamic_array_newp((dynamic_array_t*)fa,sizeof(frequency_t),frequency_cmp);
  fa->max_freq=0;
  return fa;
}

void delete_frequency_array(frequency_array_t* fa)
{
  if(fa) {
    dynamic_array_deletep((dynamic_array_t*)fa);
    free(fa);
  }
}

#define frequency_array_add(fa,data) dynamic_array_add((dynamic_array_t*)fa,data)
#define frequency_array_size(fa) dynamic_array_size((dynamic_array_t*)fa)
#define frequency_array_capacity(fa) dynamic_array_capacity((dynamic_array_t*)fa)
#define frequency_array_begin(fa) ((frequency_t*)dynamic_array_begin((dynamic_array_t*)fa))
#define frequency_array_end(fa) ((frequency_t*)dynamic_array_end((dynamic_array_t*)fa))

void frequency_array_increment(frequency_array_t* this,int value)
{
//  frequency_t* fa_array=frequency_array_begin(this);
  frequency_t freq = { value, 0 };
  frequency_t* pos = frequency_array_add(this,&freq);
  pos->frequency++;
  if(pos->frequency > this->max_freq)
    this->max_freq = pos->frequency;
}

#define frequency_array_sort(fa) dynamic_array_sort((dynamic_array_t*)fa);

statistics_t frequency_array_statistics(const frequency_array_t* freq_data)
{
  statistics_t s;

  // Calculate sample size, sum, mode, and average
  int sum=0,max_freq=0;
  s.size=0;
  const frequency_t* i;
  for(i=frequency_array_begin(freq_data);i!=frequency_array_end(freq_data);i++) {
    s.size+=i->frequency;
    sum+=i->frequency*i->value;
    if(i->frequency > max_freq) {
      max_freq = i->frequency;
      s.mode=i->value;
    }
  }
  s.average=((double)sum)/((double)s.size);

  // Get median and variance
  double var=0;
  int count=0;
  s.median=-1;
  for(i=frequency_array_begin(freq_data);i!=frequency_array_end(freq_data);i++) {
    var+=(i->value-s.average)*(i->value-s.average)*i->frequency;
    count += i->frequency;
    if(s.median == -1 && count >= s.size/2) {
      s.median=i->value;
    }
  }

  // standard deviation
  s.standard_deviation=sqrt(var/(s.size-1));
  return s;
}

void frequency_array_display_graph(const frequency_array_t* freq_data,const char* xlabel,const char* ylabel)
{
  char histogram[TERMINAL_COLUMNS+1];
  const frequency_t* i;

  printf("\n  %5s|           %s\n",xlabel,ylabel);
  printf("  -----------------------------------------------------------------\n");
  double scale=((double)TERMINAL_COLUMNS)/freq_data->max_freq;
  for(i=frequency_array_begin(freq_data);i!=frequency_array_end(freq_data);i++) {
    int height=round(i->frequency*scale);
    if(height==0) {
      strcpy(histogram,"|");
      height=1;
    } else
      memset(histogram,'#',height);
    histogram[height]=0;
    printf("  %4d |  %s %d\n",i->value,histogram,i->frequency);
  }
  printf("\n");
}

void frequency_array_show_results(const frequency_array_t* freq_data,const char* heading,const char* xlabel)
{
  printf("\n%s\n",heading);
  const char* f_str;
  frequency_t* ptr=(frequency_t*)frequency_array_begin(freq_data);
  printf("  Min %s : %d\n",xlabel,ptr->value);
  ptr=(frequency_t*)frequency_array_end(freq_data);
  ptr--;
  printf("  Max %s : %d\n",xlabel,ptr->value);
  statistics_t stats=frequency_array_statistics(freq_data);
  printf("  Sample size: %d\n",stats.size);
  // Of course this has to be printed as a fraction
  fraction_t f;
  fraction_set_double(&f,stats.average);
  fraction_round(&f,100);
  f_str = fraction_to_mixed_s(f);
  printf("  Average: %s\n",f_str);
  printf("  Median: %d\n",stats.median);
  printf("  Mode: %d\n",stats.mode);
  fraction_set_double(&f,stats.standard_deviation);
  fraction_round(&f,100);
  f_str = fraction_to_mixed_s(f);
  printf("  Standard Deviation: %s\n",f_str);
  frequency_array_display_graph(freq_data,xlabel,"Frequency");
}

#define total_time_in_ms(ru_struct) ((ru_struct.ru_utime.tv_sec + ru_struct.ru_stime.tv_sec)*1000000 \
        + ru_struct.ru_utime.tv_usec + ru_struct.ru_stime.tv_usec)

#define diff_in_tns(before,after) (total_time_in_ms(after) - total_time_in_ms(before))*100

void do_test(double value,frequency_array_t* time_freq,frequency_array_t* loop_freq)
{
  fraction_t f;
  struct rusage ru_b,ru_a;
  /*
    getrusage function does not have enough resolution to measure one cycle, so do 100 loops
    and take average.
  */
  int i;
  getrusage(RUSAGE_SELF,&ru_b);
  for(i=0;i<100;i++)
    fraction_set_double(&f,value);
  getrusage(RUSAGE_SELF,&ru_a);
//  printf("%ld %ld\n",total_time_in_ms(ru_b),total_time_in_ms(ru_a));
  frequency_array_increment(time_freq,diff_in_tns(ru_b,ru_a)/100);
#ifdef CALCULATE_LOOP_STATISTICS
  frequency_array_increment(loop_freq,nLoops);
#endif
}

/*
  Perform test using a single denominator --- 1/denomnator to (denominator-1)/denominator
*/
void single_test(int denominator)
{
  frequency_array_t* time_freq=new_frequency_array();
  frequency_array_t* loop_freq=new_frequency_array();
  int i;
  for(i=1;i<denominator;i++)
    do_test((double)i/(double)denominator,time_freq,loop_freq);
  frequency_array_sort(time_freq);
  frequency_array_show_results(time_freq,"Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time");
  delete_frequency_array(time_freq);
#ifdef CALCULATE_LOOP_STATISTICS
  frequency_array_sort(loop_freq);
  frequency_array_show_results(loop_freq,"Number of iterations to convert floating point to fraction","Loops");
  delete_frequency_array(loop_freq);
#else
  printf("\nStatistics for loop count not gathered. To enable loop statistics:\n");
  printf("  make clean\n");
  printf("  CFLAGS=-DCALCULATE_LOOP_STATISTICS make\n");
#endif
}

/*
  Perform test using random numerator and denominators
*/
void random_test(int ntests)
{
  srand(time(NULL));

  int i;
  frequency_array_t* time_freq=new_frequency_array();
  frequency_array_t* loop_freq=new_frequency_array();
  for(i=0;i<ntests;i++) {
    do_test((double)rand()/(double)rand(),time_freq,loop_freq);
  }
  frequency_array_sort(time_freq);
  frequency_array_show_results(time_freq,"Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time");
  delete_frequency_array(time_freq);
#ifdef CALCULATE_LOOP_STATISTICS
  frequency_array_sort(loop_freq);
  frequency_array_show_results(loop_freq,"Number of iterations to convert floating point to fraction","Loops");
  delete_frequency_array(loop_freq);
#else
  printf("\nStatistics for loop count not gathered. To enable loop statistics:\n");
  printf("  make clean\n");
  printf("  CFLAGS=-DCALCULATE_LOOP_STATISTICS make\n");
#endif
}

void syntax(const char* pgm)
{
  printf("Syntax: %s [-h | --help ]\n",pgm);
  printf("        %s [ [-s | --single] N] [ [-r | --random] N ]\n",pgm);
  printf("        %s\n\n",pgm);
  printf("Where:  -h | --help prints this help message\n");
  printf("        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)\n");
  printf("        -r | --random N -- gather statistics running N tests using random floating pont numbers\n");
  printf("        The default is to run a single test using 1000 as denominator and 1000 random tests\n\n");
  printf("Examples\n");
  printf("   1) To run default case\n");
  printf("      %s\n",pgm);
  printf("   2) To run single test using denominator of 100000\n");
  printf("      %s -s 100000\n",pgm);
  printf("   3) To run a minimum of 30000 random test\n");
  printf("      %s -r 30000\n",pgm);
  printf("   4) To run a single test using denominator of 100000 and 30000 random test\n");
  printf("      %s --single 100000 --random 30000\n",pgm);

  printf("\n");
  exit(0);
}

static struct option long_options[] =
    {
    {"help",     no_argument,      0, 'h'},
    {"single",  required_argument, 0, 's'},
    {"random",  required_argument, 0, 'r'},
    {0, 0, 0, 0}
    };
extern int max_loops_to_find_gcd;
int main(int argc,char* argv[])
{
  int denominator=-1;
  int min_tests=-1;
  int c,option_index;
  if(argc > 1) {
    while ((c = getopt_long(argc, argv, "hs:r:",long_options,&option_index)) != -1) {
      switch(c) {
        case 'h':
        case '?':
          syntax(argv[0]);
          break;

        case 's':
          denominator=atoi(optarg);
          break;

        case 'r':
          min_tests=atoi(optarg);
          break;

        default:
          syntax(argv[0]);
          break;
      }
    }
    if(denominator > 0)
      single_test(denominator);
    if(min_tests>0)
      random_test(min_tests);
  } else {
    single_test(1000);
    random_test(1000);
  }

  return 0;
}
