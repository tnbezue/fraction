import Fraction;
import core.stdc.time;
import std.stdio;
import std.math;
import core.sys.posix.unistd;
import std.array;
import std.random;
import std.getopt;

struct AutoArray {
  int[] freq_;

  int size() const { return cast(int)freq_.length; }
  ref opIndex(int i) { if(freq_.length <= i) freq_.length=i+1; return freq_[i]; }
  int opIndex(int i) const { return freq_[i]; }
};

class Stats {
  protected:
    double average_;
    double standard_deviation_;
    int size_;
    int median_;
    int mode_;
  public:
    this() { average_=0;standard_deviation_=0;size_=0;median_=0;mode_=0; }

    void calc(const AutoArray freq_data)
    {
      average_=0;standard_deviation_=0;size_=0;
      int i,sum,max_freq=0;
      for(i=0;i<freq_data.size();i++) {
        size_+=freq_data[i];
        sum += i*freq_data[i];
        if(freq_data[i] > max_freq) {
          max_freq=freq_data[i];
          mode_=i;
        }
      }
      average_=(cast(double)sum)/(cast(double)size_);

      // median and variance
      double var=0;
      int count=0;
      median_=-1;
      for(i=0;i<freq_data.size();i++) {
        var+=(i-average_)*(i-average_)*freq_data[i];
        count+=freq_data[i];
        if(median_ == -1 && count >= size_/2)
          median_=i;
      }

      // Standard deviation
      standard_deviation_=sqrt(var/cast(double)(size_-1));
    }

    Fraction average() const
    {
      return new Fraction(cast(double)(cast(int)(average_*100))/100.0);
    }

    Fraction standard_deviation() const {
      return new Fraction(cast(double)(cast(int)(standard_deviation_*10))/10.0);
    }
    int size() const { return size_; }
    int median() const { return median_; }
    int mode() const { return mode_; }
}

const int terminal_cols=50;
void display_graph(const AutoArray freq_data,const string xlabel,const string ylabel)
{
  // Get scale for graph
  int i; int max_freq=0;
  for(i=0;i<freq_data.size();i++) {
    if(freq_data[i]>max_freq)
      max_freq=freq_data[i];
  }
  double scale=cast(double)terminal_cols/cast(double)max_freq;
  stdout.writeln("\n",xlabel,"|                 ",ylabel);
  stdout.writeln(replicate("-",terminal_cols+6));
  for(i=0;i<freq_data.size();i++) {
    stdout.writefln("%3s  |%s %s",i,replicate("#",cast(int)round(freq_data[i]*scale)),freq_data[i]);
  }
  stdout.writeln();
}

void show_results(const AutoArray tick_freq,const AutoArray loop_freq)
{
  stdout.writeln("Max time (in clock ticks): ",tick_freq.size()-1);
  Stats stats=new Stats;
  stats.calc(tick_freq);
  stdout.writeln("Sample size: ",stats.size());
  stdout.writeln("Average: ",stats.average().toStringMixed());
  stdout.writeln("Median: ",stats.median());
  stdout.writeln("Mode: ",stats.mode());
  stdout.writeln("Standard Deviation: ",stats.standard_deviation().toStringMixed());
  display_graph(tick_freq,"Ticks","Frequency");
  version (CALCULATE_LOOP_STATISTICS) {
    stdout.writeln("Max loops: ",loop_freq.size()-1);
    stats.calc(loop_freq);
    stdout.writeln("Sample size: ",stats.size());
    stdout.writeln("Average: ",stats.average().toStringMixed());
    stdout.writeln("Median: ",stats.median());
    stdout.writeln("Mode: ",stats.mode());
    stdout.writeln("Standard Deviation: ",stats.standard_deviation().toStringMixed());
    display_graph(loop_freq,"Loops","Frequency");
  } else {
    stdout.writeln("\nStatistics for loop count not gathered. To enable loop statistics,\n");
    stdout.writeln("recompile enabing version \"CALCULATE_LOOP_STATISTICS\"\n");
  }
}

void do_test(int denominator,ref AutoArray tick_freq,ref AutoArray loop_freq)
{
  Fraction f=new Fraction;
  int i;
  for(i=1;i<denominator;i++) {
    double value=cast(double)i/cast(double)denominator;
    long start=clock();
    f = value;
    int ticks=cast(int)(clock()-start);
    tick_freq[ticks]++;
    version (CALCULATE_LOOP_STATISTICS) {
      loop_freq[f.loops]++;
    }
  }
}

void single_test(int denominator)
{
  AutoArray tick_freq;
  AutoArray loop_freq;
  do_test(denominator,tick_freq,loop_freq);
  show_results(tick_freq,loop_freq);
}

void random_test(int min_tests)
{
  AutoArray tick_freq;
  AutoArray loop_freq;
  const int max_denominators=100;
  AutoArray denominators;
  auto rnd = Random(cast(int)time(null));
  int ntest=0,i;
  while(ntest < min_tests) {
    int denominator = uniform(min_tests, 214748364, rnd) % min_tests;
    bool found=false;
    for(i=0;i<denominators.size();i++) {
      if(denominator==denominators[i]) {
        found=true;
        break;
      }
    }
    if(!found) {
      denominators[i]=denominator;
      ntest+=denominator;
    }
  }
  for(i=0;i<denominators.size();i++) {
    do_test(denominators[i],tick_freq,loop_freq);
  }
  show_results(tick_freq,loop_freq);
}

void syntax(string pgm)
{
  stdout.writeln("Syntax: " , pgm , " [-h | --help ]");
  stdout.writeln("        " , pgm , " [ [-s | --single] N] [ [-r | --random] N ]");
  stdout.writeln("        " , pgm ,"\n");
  stdout.writeln("Where:  -h | --help prints this help message");
  stdout.writeln("        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)");
  stdout.writeln("        -r | --random N -- gather statistics running a minimum of N tests using random denominators");
  stdout.writeln("        The default is to run a single test using 1000 as denominator and 1000 minimum random tests\n");
  stdout.writeln("Examples");
  stdout.writeln("   1) To run default case");
  stdout.writeln("      " , pgm , "\n");
  stdout.writeln("   2) To run single test using denominator of 100000");
  stdout.writeln("      " , pgm , " -s 100000\n");
  stdout.writeln("   3) To run a minimum of 30000 random test");
  stdout.writeln("      " , pgm , " -r 30000\n");
  stdout.writeln("   4) To run a single test using denominator of 100000 and a minimum of 30000 random test");
  stdout.writeln("      " , pgm , " --single 100000 --random 30000\n");
}

void main(string[] args)
{
  if(args.length > 1) {
    int denominator=-1,min_tests=-1;
    try {
      auto helpInformation = getopt(
          args,
          "single|s",&denominator,
          "random|r",&min_tests
      );
    if(helpInformation.helpWanted)
    {
      syntax(args[0]);
      return;
    }
    } catch(std.getopt.GetOptException e) {
      stdout.writeln("Invalid option ");
      syntax(args[0]);
      return;
    }
    if(denominator>0)
      single_test(denominator);
    if(min_tests > 0)
      random_test(min_tests);
  } else {
    single_test(1000);
    random_test(1000);
  }
}
