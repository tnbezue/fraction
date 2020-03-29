import Fraction;
import core.time;
import core.stdc.time;
import std.stdio;
import std.math;
import core.sys.posix.unistd;
import std.array;
import std.random;
import std.getopt;
import std.algorithm.sorting;

struct Statistics {
    double average_;
    double standard_deviation_;
    int sampleSize_;
    int median_;
    int mode_;

    Fraction average() const
    {
      return new Fraction(cast(double)(cast(int)(average_*100))/100.0);
    }

    Fraction standardDeviation() const {
      return new Fraction(cast(double)(cast(int)(standard_deviation_*10))/10.0);
    }
    int sampleSize() const { return sampleSize_; }
    int median() const { return median_; }
    int mode() const { return mode_; }
}

struct Frequency {
  int value;
  int frequency;

  int opCmp(ref const Frequency oFrequency) const {
    return value - oFrequency.value;
  }
};

struct FrequencyArray {
  Frequency[] freq_;
  int maxFreq;

  void increment(int value)
  {
    int i;
    for(i=0;i<freq_.length;i++) {
      if (value == freq_[i].value)
        break;
    }
    if(i==freq_.length) {
      freq_.length+=1;
      freq_[i].value = value;
      freq_[i].frequency = 0;
    }
    freq_[i].frequency++;
  }

  void sort() {
    freq_.sort();
  }

  Statistics stats()
  {
    Statistics s;
    s.average_=0; s.sampleSize_=0;s.median_=-1;
    int i,sum;
    maxFreq=0;
    for(i=0;i<freq_.length;i++) {
      s.sampleSize_+=freq_[i].frequency;
      sum += freq_[i].frequency*freq_[i].value;
      if(freq_[i].frequency > maxFreq) {
        maxFreq=freq_[i].frequency;
        s.mode_=freq_[i].value;
      }
    }
    s.average_=(cast(double)sum)/(cast(double)s.sampleSize_);

    // median and variance
    double var=0;
    int count=0;
    s.median_=-1;
    for(i=0;i<freq_.length;i++) {
      var+=(freq_[i].value-s.average_)*(freq_[i].value-s.average_)*freq_[i].frequency;
      if(s.median_ == -1) {
        count+=freq_[i].frequency;
        if(count >= s.sampleSize_/2)
          s.median_=freq_[i].value;
      }
    }

    // Standard deviation
    s.standard_deviation_=sqrt(var/cast(double)(s.sampleSize_-1));
    return s;
  }

  void displayGraph(const string xlabel,const string ylabel)
  {
    // Get scale for graph
    int i; int max_freq=0;
    double scale=cast(double)terminal_cols/cast(double)maxFreq;
    stdout.writefln("\n  %5s|                 %s",xlabel,ylabel);
    stdout.writeln("  ",replicate("-",terminal_cols+6));
    for(i=0;i<freq_.length;i++) {
      stdout.writefln("  %3s  |%s %s",freq_[i].value,replicate("#",cast(int)round(freq_[i].frequency*scale)),freq_[i].frequency);
    }
    stdout.writeln();
  }

  void showResults(const string header,const string xlabel)
  {
    stdout.writeln("\n",header);
    stdout.writeln("  Max ",xlabel,": ",freq_[freq_.length-1].value);
    Statistics stats=stats();
    stdout.writeln("  Sample size: ",stats.sampleSize());
    stdout.writeln("  Average: ",stats.average().toStringMixed());
    stdout.writeln("  Median: ",stats.median());
    stdout.writeln("  Mode: ",stats.mode());
    stdout.writeln("  Standard Deviation: ",stats.standardDeviation().toStringMixed());
    displayGraph(xlabel,"Frequency");
  }

};

const int terminal_cols=50;

void doTest(int denominator,ref FrequencyArray timeFreq,ref FrequencyArray loopFreq)
{
  Fraction f=new Fraction;
  int i;
  for(i=0;i<denominator;i++) {
    double value=cast(double)i/cast(double)denominator;
    MonoTime before = MonoTime.currTime;
    f = value;
    MonoTime after = MonoTime.currTime;
    long timeElapsed = after.ticks - before.ticks;
    if(i>0) {
      timeFreq.increment(cast(int)timeElapsed/10);
      version (CALCULATE_LOOP_STATISTICS) {
        loopFreq.increment(f.nLoops);
      }
    }
  }
}

void singleTest(int denominator)
{
  FrequencyArray timeFreq;
  FrequencyArray loopFreq;
  doTest(denominator,timeFreq,loopFreq);
  timeFreq.sort();
  timeFreq.showResults("Time taken to convert floating point to faction (tims is in 10s of nanoseconds)","Time");
  version (CALCULATE_LOOP_STATISTICS) {
    loopFreq.sort();
    loopFreq.showResults("Number of interations to convert floating point to fraction","Loops");
  } else {
    stdout.writeln("\nStatistics for loop count not gathered. To enable loop statistics,\n");
    stdout.writeln("recompile enabing version \"CALCULATE_LOOP_STATISTICS\"\n");
  }
}

void randomTest(int min_tests)
{
  FrequencyArray timeFreq;
  FrequencyArray loopFreq;
  const int max_denominators=100;
  int[] denominators;
  auto rnd = Random(cast(int)time(null));
  int ntest=0,i;
  while(ntest < min_tests) {
    int denominator = uniform(min_tests, 214748364, rnd) % min_tests;
    bool found=false;
    for(i=0;i<denominators.length;i++) {
      if(denominator==denominators[i]) {
        found=true;
        break;
      }
    }
    if(!found) {
      denominators.length+=1;
      denominators[i]=denominator;
      ntest+=denominator-1;
    }
  }
  for(i=0;i<denominators.length;i++) {
    doTest(denominators[i],timeFreq,loopFreq);
  }
  timeFreq.sort();
  timeFreq.showResults("Time taken to convert floating point to faction (tims is in 10s of nanoseconds)","Time");
  version (CALCULATE_LOOP_STATISTICS) {
    loopFreq.sort();
    loopFreq.showResults("Number of interations to convert floating point to fraction","Loops");
  } else {
    stdout.writeln("\nStatistics for loop count not gathered. To enable loop statistics,\n");
    stdout.writeln("recompile enabing version \"CALCULATE_LOOP_STATISTICS\"\n");
  }
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
      singleTest(denominator);
    if(min_tests > 0)
      randomTest(min_tests);
  } else {
    singleTest(1000);
    randomTest(1000);
  }
}
