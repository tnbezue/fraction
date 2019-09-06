#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>
#include <cmath>
#include <getopt.h>

using namespace std;
#include "fraction.hh"

#define TERMINAL_COLUMNS 50     // Columns in terminal -- used for displaying histogram
#define MAX_DENOMINATORS 1000   // Maximum number of randomly chosen denominators
#define MAX_TICK_COUNT  50     // Max number of clock ticks for conversion from double to fraction to take
#define MAX_LOOP_COUNT 10       // Maximum number of loops expected to calculate

#ifdef CALCULATE_LOOP_STATISTICS
  extern int loops;
#endif

class freq_t : public vector<int>
{
  public:
    int& operator[](int i);
    const int& operator[](int i) const { return vector<int>::operator[](i); }
};

int& freq_t::operator[](int i)
{
  while(i>=size()) {
    push_back(0);
  }
  return vector<int>::operator[](i);
}

class stats_t {
  protected:
    double average_;
    double standard_deviation_;
    int size_;
    int median_;
    int mode_;
  public:
    stats_t() : average_(0),standard_deviation_(0),size_(0),median_(0),mode_(0) { }
    void calc(const freq_t&);
    fraction_t average() const { return fraction_t(((int)(average_*10))/10.0); }
    fraction_t standard_deviation() const { return fraction_t(((int)(standard_deviation_*100))/100.0); }
    int size() const { return size_; }
    int median() const { return median_; }
    int mode() const { return mode_; }
};

void stats_t::calc(const freq_t& freq_data)
{
  stats_t s;

  // Calculate sample size, sum, mode, and average
  int i,sum=0,max_freq=0;
  size_=0;
  for(i=0;i<freq_data.size();i++) {
    size_+=freq_data[i];
    sum+=i*freq_data[i];
    if(freq_data[i] > max_freq) {
      max_freq = freq_data[i];
      mode_=i;
    }
  }
  average_=((double)sum)/((double)size_);

  // Get median and variance
  double var=0;
  int count=0;
  median_=-1;
  for(i=0;i<freq_data.size();i++) {
    var+=(i-average_)*(i-average_)*freq_data[i];
    count += freq_data[i];
    if(median_ == -1 && count >= size_/2) {
      median_=i;
    }
  }

  // standard deviation
  standard_deviation_=sqrt(var/(size_-1));
}

void display_graph(const freq_t &freq_data,const string& xlabel,const string& ylabel)
{
  string histogram;
  int i,max=0;
  for(i=0;i<freq_data.size();i++)
    if(freq_data[i]>max)
      max=freq_data[i];

  cout << endl << xlabel << "|           " << ylabel<<endl;
  cout << "-----------------------------------------------------------------\n";
  double scale=((double)TERMINAL_COLUMNS)/max;
  for(i=0;i<freq_data.size();i++) {
    histogram.clear();
    int height=round(freq_data[i]*scale);
    histogram.append(height,'#');
    cout << setw(3) << i << "  |" << histogram << " " << freq_data[i] << endl;
  }
  cout << endl;
}

void show_results(const freq_t& tick_freq,const freq_t& loop_freq)
{
//  fraction_t f;
  cout << "Max time (in clock ticks): " << tick_freq.size()-1 << endl;
  stats_t stats;
  stats.calc(tick_freq);
  cout << "Sample size: " << stats.size() << endl;
  cout << "Average: " << stats.average().to_mixed_s() << endl;
  cout << "Median: " << stats.median() << endl;
  cout << "Mode: " << stats.mode() << endl;
  cout << "Standard Deviation: " << stats.standard_deviation().to_mixed_s() << endl;
  display_graph(tick_freq,"Ticks","Frequency");
#ifdef CALCULATE_LOOP_STATISTICS
  cout << "Max loops: " << loop_freq.size()-1 << endl;
  stats.calc(loop_freq);
  cout << "Sample size: " << stats.size() << endl;
  cout << "Average: " << stats.average().to_mixed_s() << endl;
  cout << "Median: " << stats.median() << endl;
  cout << "Mode: " << stats.mode() << endl;
  cout << "Standard Deviation: " << stats.standard_deviation().to_mixed_s() << endl;
  display_graph(loop_freq,"Ticks","Frequency");
#else
  printf("\nStatistics for loop count not gathered. To enable loop statistics:\n");
  printf("  make clean\n");
  printf("  CXXFLAGS=-DCALCULATE_LOOP_STATISTICS make\n");
#endif
}

void do_test(int denominator,freq_t& tick_freq,freq_t& loop_freq)
{
  int i;
  for(i=1;i<denominator;i++) {
    clock_t start=clock();
    fraction_t(((double)i)/((double)denominator));
    int ticks=clock()-start;
    tick_freq[ticks]++;
#ifdef CALCULATE_LOOP_STATISTICS
    loop_freq[loops]++;
#endif
  }
}

/*
  Gather stats on fraction from 1/denominator to (denominator-1)/denominator
*/
void simple_test(int denominator)
{
  freq_t tick_freq;
  freq_t loop_freq;
  do_test(denominator,tick_freq,loop_freq);
  show_results(tick_freq,loop_freq);
}

void random_test(int min_tests)
{
  freq_t tick_freq;
  freq_t loop_freq;

  srand(time(NULL));
  vector<int> denominators;
  int n_tests=0;
  while(n_tests < min_tests && denominators.size() < MAX_DENOMINATORS) {
    int denominator=rand() % min_tests + 100;
    // make sure it's unique
    if(find(denominators.cbegin(),denominators.cend(),denominator) == denominators.cend()) {
      denominators.push_back(denominator);
      n_tests+=denominator-1;
    }
  }
  vector<int>::const_iterator i;
  for(i=denominators.cbegin();i!=denominators.cend();i++) {
    do_test(*i,tick_freq,loop_freq);
  }
  show_results(tick_freq,loop_freq);
}

void syntax(const string& pgm)
{
  cout << "Syntax: " << pgm << " [-h | --help ]\n";
  cout << "        " << pgm << " [ [-s | --single] N] [ [-r | --random] N ]\n";
  cout << "        " << pgm << endl << endl;
  cout << "Where:  -h | --help prints this help message\n";
  cout << "        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)\n";
  cout << "        -r | --random N -- gather statistics running a minimum of N tests using random denominators\n";
  cout << "        The default is to run a single test using 1000 as denominator and 1000 minimum random tests\n\n";
  cout <<"Examples\n";
  cout <<"   1) To run default case\n";
  cout <<"      " << pgm << endl;
  cout <<"   2) To run single test using denominator of 100000\n";
  cout <<"      " << pgm << " -s 100000\n";
  cout <<"   3) To run a minimum of 30000 random test\n";
  cout <<"      " << pgm << " -r 30000\n";
  cout <<"   4) To run a single test using denominator of 100000 and a minimum of 30000 random test\n";
  cout <<"      " << pgm << " --single 100000 --random 30000\n";
exit(0);
}
static struct option long_options[] =
    {
    {"help",     no_argument,      0, 'h'},
    {"single",  required_argument, 0, 's'},
    {"random",  required_argument, 0, 'r'},
    {0, 0, 0, 0}
    };
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
      simple_test(denominator);
    if(min_tests>0)
      random_test(min_tests);
  } else {
    simple_test(1000);
    random_test(1000);
  }
  return 0;
}
