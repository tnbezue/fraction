/*
		Copyright (C) 2019-2020  by Terry N Bezue

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*

  By default, the Continued Fraction Method (https://en.wikipedia.org/wiki/Continued_fraction)
  is used.  To use the original method:
    make clean
    CXXFLAGS=-DFRACTION_ORIGINAL_METHOD make
*/
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>
#include <cmath>
#include <getopt.h>
#include <sys/time.h>
#include <sys/resource.h>

using namespace std;
#include "fraction.hh"

#define TERMINAL_COLUMNS 50     // Columns in terminal -- used for displaying histogram

extern int nLoops;

struct statistics_t
{
  double average_;
  double standard_deviation_;
  int size_;
  int median_;
  int mode_;

  mixed_fraction_t average() const { mixed_fraction_t f(average_); f.round(100); return f; }
  mixed_fraction_t standard_deviation() const { mixed_fraction_t f(standard_deviation_); f.round(100); return f; }
  size_t size() const { return size_; }
  int median() const { return median_; }
  int mode() const { return mode_; }
};

struct frequency_t
{
  int value;
  int frequency;
  frequency_t() : value{0}, frequency(0) { }
  frequency_t(int v) : value(v),frequency(1) { }
};

bool operator<(const frequency_t& lhs,const frequency_t& rhs)
{
  return lhs.value < rhs.value;
}

bool operator==(const frequency_t& lhs,const frequency_t& rhs)
{
  return lhs.value == rhs.value;
}

class frequency_array_t : public vector<frequency_t>
{
    int max_freq_;
  public:
    frequency_array_t() : vector<frequency_t>(), max_freq_(0) { }
    void sort() { std::sort(this->begin(),this->end()); }
    void increment(int value);
    void display_graph(const string&,const string&) const;
    void show_results(const string&,const string&) const;
    statistics_t statistics() const;
};

void frequency_array_t::increment(int value)
{
  frequency_array_t::iterator i=find(this->begin(),this->end(),frequency_t(value));
  if(i == cend()) {
    frequency_t f(value);
    push_back(f);
  } else {
    i->frequency++;
    if(i->frequency > max_freq_)
      max_freq_=i->frequency;
  }
}

statistics_t frequency_array_t::statistics() const
{
  statistics_t s;

  // Calculate sample size, sum, mode, and average
  int sum=0;
  s.size_=0;
  const_iterator i;
  for(i=cbegin();i<cend();i++) {
    s.size_+=i->frequency;
    sum+=i->value*i->frequency;
    if(i->frequency == max_freq_) {
      s.mode_=i->value;
    }
  }
  s.average_=((double)sum)/((double)s.size_);

  // Get median and variance
  double var=0;
  int count=0;
  s.median_=-1;
  for(i=cbegin();i!=cend();i++) {
    var+=(i->value-s.average_)*(i->value-s.average_)*i->frequency;
    if(s.median_ == -1) {
      count += i->frequency;
      if(count >= s.size_/2)
        s.median_=i->value;
    }
  }

  // standard deviation
  s.standard_deviation_=sqrt(var/(s.size_-1));
  return s;
}

void frequency_array_t::display_graph(const string& xlabel,const string& ylabel) const
{
  string histogram;
  cout << endl << "  " << setw(5) << xlabel << "|           " << ylabel<<endl;
  cout << "  -----------------------------------------------------------------\n";
  double scale=((double)TERMINAL_COLUMNS)/max_freq_;
  const_iterator i;
  for(i=cbegin();i<cend();i++) {
    histogram = " ";
    int height=round(i->frequency*scale);
    if(height == 0)
      histogram.append(1,'|');
    else
      histogram.append(height,'#');
    cout << "  " << setw(4) << i->value << " |" << histogram << " " << i->frequency << endl;
  }
  cout << endl;
}

void frequency_array_t::show_results(const string& heading,const string& xlabel) const
{
  cout << endl << heading << endl;
  cout << "  Min " << xlabel << ": " << (*this)[0].value << endl;
  cout << "  Max " << xlabel << ": " << (*this)[size()-1].value << endl;
  statistics_t stats=statistics();
//  stats.calc(time_freq);
  cout << "  Sample size: " << stats.size() << endl;
  cout << "  Average: " << stats.average().to_s() << endl;
  cout << "  Median: " << stats.median() << endl;
  cout << "  Mode: " << stats.mode() << endl;
  cout << "  Standard Deviation: " << stats.standard_deviation().to_s() << endl;
  display_graph(xlabel,"Frequency");
}

#define total_time_in_ms(ru_struct) ((ru_struct.ru_utime.tv_sec + ru_struct.ru_stime.tv_sec)*1000000 \
        + ru_struct.ru_utime.tv_usec + ru_struct.ru_stime.tv_usec)

#define diff_in_tns(before,after) (total_time_in_ms(after) - total_time_in_ms(before))*100


void do_test(double value,frequency_array_t& time_freq,frequency_array_t& loop_freq)
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
    f=value;
  getrusage(RUSAGE_SELF,&ru_a);
//  printf("%ld %ld\n",total_time_in_ms(ru_b),total_time_in_ms(ru_a));
  time_freq.increment(diff_in_tns(ru_b,ru_a)/100);
#ifdef CALCULATE_LOOP_STATISTICS
  loop_freq.increment(nLoops);
#endif
}

/*
  Gather stats on fraction from 1/denominator to (denominator-1)/denominator
*/
void single_test(int denominator)
{
  frequency_array_t time_freq;
  frequency_array_t loop_freq;
  int i;
  for(i=1;i<denominator;i++)
    do_test((double)i/double(denominator),time_freq,loop_freq);
  time_freq.sort();
  time_freq.show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","time");
  loop_freq.sort();
  loop_freq.show_results("Number of iterations to convert floating point to fraction","Loops");
}

struct numerator_denominator_t {
  int numerator;
  int denominator;
};
bool operator==(const numerator_denominator_t& a,const numerator_denominator_t& b)
{
  return a.numerator==b.numerator && a.denominator==b.denominator;
}

void random_test(int nTests)
{
  frequency_array_t time_freq;
  frequency_array_t loop_freq;

  srand(time(NULL));

  int i;
  for(i=0;i<nTests;i++) {
    do_test(static_cast<double>(rand())/static_cast<double>(rand()),time_freq,loop_freq);
  }
  time_freq.sort();
  time_freq.show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","time");
  loop_freq.sort();
  loop_freq.show_results("Number of iterations to convert floating point to fraction","Loops");
}

void syntax(const string& pgm)
{
  cout << "Syntax: " << pgm << " [-h | --help ]\n";
  cout << "        " << pgm << " [ [-s | --single] N] [ [-r | --random] N ]\n";
  cout << "        " << pgm << endl << endl;
  cout << "Where:  -h | --help prints this help message\n";
  cout << "        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)\n";
  cout << "        -r | --random N -- gather statistics running N tests using random floating point numbers\n";
  cout << "        The default is to run a single test using 1000 as denominator and 1000 random tests\n\n";
  cout <<"Examples\n";
  cout <<"   1) To run default case\n";
  cout <<"      " << pgm << endl;
  cout <<"   2) To run single test using denominator of 100000\n";
  cout <<"      " << pgm << " -s 100000\n";
  cout <<"   3) To run a minimum of 30000 random test\n";
  cout <<"      " << pgm << " -r 30000\n";
  cout <<"   4) To run a single test using denominator of 100000 and 30000 random test\n";
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
      single_test(denominator);
    if(min_tests>0)
      random_test(min_tests);
  } else {
    single_test(1000);
    random_test(1000);
  }
  return 0;
}
