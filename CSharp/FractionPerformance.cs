using System;
using System.Collections;
using System.Diagnostics;
using System.Runtime.InteropServices;


public struct Frequency
{
  public int _value;
  public int _count;

  public int Value() { return _value; }
  public int Count() { return _count; }
}

public class FrequencyArray
{
  Frequency [] _frequencies;
  int _capacity;
  int _size;
  int _maxFreq;

  class FrequencyComparer : IComparer
  {
    int IComparer.Compare(Object a,Object b)
    {
      return ((Frequency)a)._value - ((Frequency)b)._value;
    }
  }
  public FrequencyArray() { _capacity=16; _size=0; _maxFreq=0; _frequencies = new Frequency[_capacity]; }

  private int find(int v)
  {
    int i=0;
    for(;i<_size;i++)
      if(v==_frequencies[i]._value)
        break;
    return i;
  }

  public void Increment(int v) {
    int pos = find(v);
    if(pos >= _size) {
      _size++;
      if(pos >= _capacity) {
        _capacity<<=1;
        System.Array.Resize(ref _frequencies,_capacity);
      }
      _frequencies[pos]._value=v;
      _frequencies[pos]._count=0;
    }
    _frequencies[pos]._count++;
    if(_frequencies[pos]._count > _maxFreq)
      _maxFreq = _frequencies[pos]._count;
  }

  public void Sort()
  {
    Array.Sort(_frequencies,0,_size,new FrequencyComparer());
  }

  public int Length { get { return _size; } }
  public int MaxFreq { get { return _maxFreq; } }

  public int Value(int i) { return _frequencies[i]._value; }
  public int Frequency(int i) { return _frequencies[i]._count; }
}


class Stats {
  private double _average;
  private double _standard_deviation;
  private int _size;
  private int _median;
  private int _mode;

  public void Calc(FrequencyArray freq_data)
  {
    // Average
    _size=0;
    int i,sum=0,max_freq=0;
    for(i=0;i<freq_data.Length;i++) {
      _size+=freq_data.Frequency(i);
      sum += i*freq_data.Frequency(i);
      if(freq_data.Frequency(i) > max_freq) {
        max_freq=freq_data.Frequency(i);
        _mode=i;
      }
    }
    _average = (double)sum/(double)_size;

    // median and variance
    double var=0;
    int count=0;
    _median=-1;
    for(i=0;i<freq_data.Length;i++) {
      var += (i - _average)*(i - _average)*freq_data.Frequency(i);
      count += freq_data.Frequency(i);
      if(_median == -1 && count >= _size/2) {
        _median = i;
      }
    }

    // standard deviation
    _standard_deviation=Math.Sqrt(var/(double)(_size-1));
  }

  public Fraction Average()
  {
    Fraction f=new Fraction(_average);
    f.Round(100);
    return f;
  }

  public Fraction StandardDeviation()
  {
    Fraction f = new Fraction(_standard_deviation);
    f.Round(100);
    return f;
  }

  public int Size() { return _size; }
  public int Median() { return _median; }
  public int Mode() { return _mode; }
}

class FractionPerformance
{
  const int MaxTicks = 20;  // The maximum clock ticke expected to calculate fraction from double
  const int MaxLoops = 10;  // The maximum number of loops to calculate fraction from double
  const int teminal_cols = 50;
  static void display_graph(FrequencyArray freq_data,string xlabel,string ylabel)
  {
    // Determine scale for graph
    int i;
    double scale = (double)teminal_cols/(double)freq_data.MaxFreq;
    Console.WriteLine("\n{0}|                 {1}",xlabel,ylabel);
    Console.WriteLine(new String('-',teminal_cols+6));
    for(i=0;i<freq_data.Length;i++) {
      string bar = new String('#',(int)Math.Round(freq_data.Frequency(i)*scale));
      Console.WriteLine("{0}|{1} {2}",freq_data.Value(i),bar,freq_data.Frequency(i));
    }
    Console.WriteLine();
  }

  static void ShowResults(FrequencyArray tick_freq,FrequencyArray loop_freq)
  {
    Console.WriteLine("Max time (in clock ticks): ",tick_freq.MaxFreq);
    Stats stats=new Stats();
    stats.Calc(tick_freq);
    Console.WriteLine("Sample size: "+stats.Size());
    Console.WriteLine("Average: "+stats.Average().ToStringMixed());
    Console.WriteLine("Median: "+stats.Median());
    Console.WriteLine("Mode: "+stats.Mode());
    Console.WriteLine("Standard Deviation: "+stats.StandardDeviation().ToStringMixed());
    display_graph(tick_freq,"Ticks","Frequency");
#if CALCULATE_LOOP_STATISTICS
      Console.WriteLine("Max loops: "+loop_freq.MaxFreq);
      stats.Calc(loop_freq);
      Console.WriteLine("Sample size: "+stats.Size());
      Console.WriteLine("Average: "+stats.Average().ToStringMixed());
      Console.WriteLine("Median: "+stats.Median());
      Console.WriteLine("Mode: "+stats.Mode());
      Console.WriteLine("Standard Deviation: "+stats.StandardDeviation().ToStringMixed());
      display_graph(loop_freq,"Loops","Frequency");
#else
      Console.WriteLine("\nStatistics for loop count not gathered. To enable loop statistics,\n");
      Console.WriteLine("recompile defining \"CALCULATE_LOOP_STATISTICS\"\n");
#endif
  }

  static void DoTest(int denominator,FrequencyArray tick_freq,FrequencyArray loop_freq)
  {
    Stopwatch stopWatch; // = Stopwatch.StartNew();
    Fraction f = new Fraction(0.0);
/*    stopWatch.Stop();
    stopWatch = Stopwatch.StartNew();
    f.Set(00.2);
    stopWatch.Stop();*/
    int i;
    for(i=0;i<denominator;i++) {
      stopWatch = Stopwatch.StartNew();
      f.Set(((double)i)/((double)denominator));
      stopWatch.Stop();
      // According to Microsoft docs, when using Stopwatch, the first execution should be ignored
      if(i>0) {
        tick_freq.Increment((int)stopWatch.Elapsed.Ticks);
#if CALCULATE_LOOP_STATISTICS
        loop_freq.Increment(Fraction.loops);
#endif
      }
    }
  }

  static void SingleTest(int denominator)
  {
    FrequencyArray tick_freq = new FrequencyArray();
    FrequencyArray loop_freq = new FrequencyArray();
    DoTest(denominator,tick_freq,loop_freq);
    tick_freq.Sort();
    loop_freq.Sort();
    ShowResults(tick_freq,loop_freq);
  }

  static void RandomTest(int minTests)
  {
    Random rnd = new Random();
    ArrayList denominators = new ArrayList();
    int nTests=0;
    while(nTests < minTests) {
      int denominator=rnd.Next(minTests,214748364) % minTests;
      // Make sure it's a unique denominator
      bool found=false;
      foreach ( int dem in denominators )
        if(dem == denominator) {
          found=true;
          break;
        }
      if(!found) {
        denominators.Add(denominator);
        nTests += denominator-1;
      }
    }

    FrequencyArray tick_freq = new FrequencyArray();
    FrequencyArray loop_freq = new FrequencyArray();
    foreach (int denominator in denominators) {
      DoTest(denominator,tick_freq,loop_freq);
    }
    tick_freq.Sort();
    loop_freq.Sort();
    ShowResults(tick_freq,loop_freq);
  }

  static void Syntax()
  {
    string pgm = System.Diagnostics.Process.GetCurrentProcess().ProcessName;
    Console.WriteLine("Syntax: {0} [-h | --help ]",pgm);
    Console.WriteLine("        {0} [ [-s | --single] N] [ [-r | --random] N ]",pgm);
    Console.WriteLine("        {0}\n",pgm);
    Console.WriteLine("Where:  -h | --help prints this help message");
    Console.WriteLine("        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)");
    Console.WriteLine("        -r | --random N -- gather statistics running a minimum of N tests using random denominators");
    Console.WriteLine("        The default is to run a single test using 1000 as denominator and 1000 minimum random tests\n");
    Console.WriteLine("Examples");
    Console.WriteLine("   1) To run default case");
    Console.WriteLine("      {0}\n",pgm);
    Console.WriteLine("   2) To run single test using denominator of 100000");
    Console.WriteLine("      {0} -s 100000\n",pgm);
    Console.WriteLine("   3) To run a minimum of 30000 random test");
    Console.WriteLine("      {0} -r 30000\n",pgm);
    Console.WriteLine("   4) To run a single test using denominator of 100000 and a minimum of 30000 random test");
    Console.WriteLine("      {0} --single 100000 --random 30000\n",pgm);
  }
  public static void Main(string[] args)
  {

//    Syntax();
    if(args.Length > 0) {
      int minTest=-1;
      int denominator=-1;
      for(int i=0;i<args.Length;i++) {
        if(args[i] == "-h" || args[i] == "--help") {
          Syntax();
          return;
        } else if(args[i] == "-s" || args[i] == "--single") {
          if(i == (args.Length-1)) {
            Console.WriteLine("Value needs to be supplied for \"{0}\" option. ",args[i]);
            Syntax();
            return;
          }
          i++;
          try {
            denominator=int.Parse(args[i]);
          } catch(System.FormatException) {
            Console.WriteLine("Invalid value \"{0}\" for \"{1}\" option. ",args[i],args[i-1]);
            Syntax();
            return;
          }
        } else if(args[i] == "-r" || args[i] == "--random") {
          if(i == (args.Length-1)) {
            Console.WriteLine("Value needs to be supplied for \"{0}\" option. ",args[i]);
            Syntax();
            return;
          }
          i++;
          try {
            minTest=int.Parse(args[i]);
          } catch(System.FormatException) {
            Console.WriteLine("Invalid value \"{0}\" for \"{1}\" option. ",args[i],args[i-1]);
            Syntax();
            return;
          }
        } else {
          Console.WriteLine("Invalid options specified {0}\n",args[i]);
          Syntax();
          return;
        }
      }
      if(denominator > 0)
        SingleTest(denominator);
      if(minTest > 0)
        RandomTest(minTest);
    } else {
      SingleTest(1000);
      RandomTest(1000);
    }
  }
}
