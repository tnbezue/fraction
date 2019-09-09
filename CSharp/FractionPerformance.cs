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


/*
  LowValueFrequencyArray
  The frequency is not low, it is the value for which the frequency is counted that is low.
  Expected values are so low that the values are used as indexes.
*/
/*
struct LowValueFrequencyArray {
  // Increase size of array if an exception is thrown
  int [] _frequencies; // = new int[] { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  int _maxFreq;
  public LowValueFrequencyArray(int n)
  {
    _maxFreq=0;
    _frequencies = new int[n];
    for(int i=0;i<n;i++) _frequencies[i]=0;
  }
  public void Increment(int i)
  {
    if(i>_frequencies.Length)
      Console.WriteLine(String.Format("I ({0}) > length ({1})",i,_frequencies.Length));
    _frequencies[i]++;
    if(_frequencies[i]>MaxFreq)
      _maxFreq=_frequencies[i];
  }

  public int Frequency(int i) { return _frequencies[i]; }
  public int MaxFreq { get { return _maxFreq; }}
  public int Length { get { return _maxFreq+1; }}
}
*/
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
  public static void Main(string[] args)
  {
/*    Fraction f = new Fraction();
    long start=DateTime.Now.Millisecond;;
    f.Set(.123456);
    long elapsed = DateTime.Now.Millisecond - start;
    Console.WriteLine(elapsed);*/
    SingleTest(1000);
  }
}
