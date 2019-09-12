import java.util.Arrays;
import java.util.Random;

class FractionPerformance
{
  public class Statistics {
    public double average;
    public double standard_deviation;
    public int sample_size;
    public int median;
    public int mode;

    public Fraction Average() { Fraction f=new Fraction(average); f.Round(100); return f; }
    public Fraction StandardDeviation()  { Fraction f=new Fraction(standard_deviation); f.Round(100); return f; }
    public int Size() { return sample_size; }
    public int Median() { return median; }
    public int Mode() { return mode; }
  }

  public class Frequency implements Comparable<Frequency>
  {
    public int value;
    public int frequency;

    public Frequency() { value=0; frequency=0; }
    public int compareTo(Frequency anotherFrequency)
    {
      return value - anotherFrequency.value;
    }
  }

  public class FrequencyArray
  {
    Frequency [] frequencies;
    private int capacity;
    private int size;
    private int maxFreq;
    public FrequencyArray()
    {
      capacity=16; size=0; maxFreq=0; frequencies=new Frequency[capacity];
    }

    public void Increment(int value)
    {
      int i;
      for(i=0;i<size;i++) {
        if(frequencies[i].value == value)
          break;
      }
      if(i== size) {
        if(i==capacity) {
          Frequency [] temp=frequencies;
          capacity <<=1;
          frequencies=new Frequency[capacity];
          System.arraycopy(temp,0,frequencies,0,size);
        }
        size++;
        frequencies[i] = new Frequency();
        frequencies[i].value=value;
        frequencies[i].frequency=0;
      }
      frequencies[i].frequency++;
    }

    public void Sort()
    {
      Arrays.sort(frequencies,0,size);
    }

    Statistics Statistics()
    {
      Statistics s = new Statistics();

      // Calculate sample size, sum, mode, and average
      int i,sum=0;
      s.sample_size=0;
      maxFreq=0;
      for(i=0;i<size;i++) {
        s.sample_size+=frequencies[i].frequency;
        sum+=frequencies[i].frequency*frequencies[i].value;
        if(frequencies[i].frequency>maxFreq) {
          maxFreq=frequencies[i].frequency;
          s.mode=frequencies[i].value;
        }
      }
      s.average = (double)sum/(double)s.sample_size;

      // Median and variance
      double var=0;
      int count=0;
      s.median=-1;
      for(i=0;i<size;i++) {
        var=(frequencies[i].value-s.average)*(frequencies[i].value-s.average)*frequencies[i].frequency;
        if(s.median == -1) {
          count += frequencies[i].frequency;
          if(count >= s.sample_size/2)
            s.median = frequencies[i].value;
        }
      }

      // Standard deviation
      s.standard_deviation=Math.sqrt(var/(double)(s.sample_size-1));

      return s;
    }

    void DisplayGraph(String xlabel,String ylabel)
    {
      System.out.println("\n"+xlabel+"              "+ylabel);
      System.out.println("-----------------------------------------------------------------");
      double scale=50.0/maxFreq;
      int i;
      for(i=0;i<size;i++) {
        int height=(int)((double)frequencies[i].frequency*scale);
        System.out.println(frequencies[i].value+"|"+"#".repeat(height)+" "+frequencies[i].frequency);
      }
      System.out.println();
    }


    public void ShowResults(String xlabel)
    {
      System.out.println("Max "+xlabel+": "+frequencies[size-1].value);
      Statistics s = Statistics();
      System.out.println("Sample size: "+s.sample_size);
      System.out.println("Average: "+s.Average().toMixedString());
      System.out.println("Median: "+s.Median());
      System.out.println("Mode: "+s.Mode());
      System.out.println("Standard deviation: "+s.StandardDeviation().toMixedString());
      DisplayGraph(xlabel,"Frequency");
    }

    public int Size() { return size; }
  }

  void DoTest(int denominator,FrequencyArray tick_freq,FrequencyArray loop_freq)
  {
    Fraction f = new Fraction();
    for(int i=0;i<denominator;i++) {
      long start = System.nanoTime();;
      f.set((double)i/(double)denominator);
      long elapsed = System.nanoTime() - start;
      if(i>0) {  // First one can skew results
        tick_freq.Increment((int)(elapsed/1000));
        loop_freq.Increment(Fraction.loops);
      }
    }
  }

  void SingleTest(int denominator)
  {
    FrequencyArray tick_freq = new FrequencyArray();
    FrequencyArray loop_freq = new FrequencyArray();
    DoTest(denominator,tick_freq,loop_freq);
    tick_freq.Sort();
    tick_freq.ShowResults("Ticks");
    if(loop_freq.Size() > 1) {
      loop_freq.Sort();
      loop_freq.ShowResults("Loops");
    } else {
      System.out.println("\nStatistics for loop count not gathered. To enable loop statistics,");
      System.out.println("edit Fraction.java and set \"calculate_loop_statistics\" to true.");
    }
  }

  void RandomTest(int minTests)
  {
    int denominators[]=new int[100];
    int nDenominators=0;
    int nTests=0;
    Random ran = new Random();
    while(nTests < minTests && nDenominators < 100) {
      int denominator=ran.nextInt(minTests) + 1000;
      // avoid duplicate denominators
      boolean found=false;
      for(int i=0;i<nDenominators && !found;i++) {
        if(denominator == denominators[i])
          found=true;
      }
      if(!found) {
        denominators[nDenominators++]=denominator;
        nTests += denominator-1;
      }
    }

    FrequencyArray tick_freq = new FrequencyArray();
    FrequencyArray loop_freq = new FrequencyArray();
    for(int i=0;i<nDenominators;i++)
      DoTest(denominators[i],tick_freq,loop_freq);
    tick_freq.Sort();
    tick_freq.ShowResults("Ticks");
    if(loop_freq.Size() > 1) {
      loop_freq.Sort();
      loop_freq.ShowResults("Loops");
    } else {
      System.out.println("\nStatistics for loop count not gathered. To enable loop statistics,");
      System.out.println("edit Fraction.java and set \"calculate_loop_statistics\" to true");
    }
  }

  static void Syntax(String pgm)
  {
//    string pgm = System.Process.GetCurrentProcess().ProcessName;
    System.out.format("Syntax: %s [-h | --help ]\n",pgm);
    System.out.format("        %s [ [-s | --single] N] [ [-r | --random] N ]\n",pgm);
    System.out.format("        %s\n\n",pgm);
    System.out.format("Where:  -h | --help prints this help message\n");
    System.out.format("        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)\n");
    System.out.format("        -r | --random N -- gather statistics running a minimum of N tests using random denominators\n");
    System.out.format("        The default is to run a single test using 1000 as denominator and 1000 minimum random tests\n\n");
    System.out.format("Examples\n");
    System.out.format("   1) To run default case\n");
    System.out.format("      %s\n\n",pgm);
    System.out.format("   2) To run single test using denominator of 100000\n");
    System.out.format("      %s -s 100000\n\n",pgm);
    System.out.format("   3) To run a minimum of 30000 random test\n");
    System.out.format("      %s -r 30000\n\n",pgm);
    System.out.format("   4) To run a single test using denominator of 100000 and a minimum of 30000 random test\n");
    System.out.format("      %s --single 100000 --random 30000\n\n",pgm);
  }

  public static void main(String[] args) {
    FractionPerformance fp= new FractionPerformance();
    if(args.length > 0) {
      int minTest=-1;
      int denominator=-1;
      for(int i=0;i<args.length;i++) {
        if(args[i].equals("-h") || args[i].equals("--help")) {
          Syntax("FractionPerformance");
          return;
        } else if(args[i].equals("-s") || args[i].equals("--single")) {
          if(i == (args.length-1)) {
            System.out.format("Value needs to be supplied for \"%s\" option. ",args[i]);
            Syntax("FractionPerformance");
            return;
          }
          i++;
          try {
            denominator=Integer.parseInt(args[i]);
          } catch(NumberFormatException ne1) {
            System.out.format("Invalid value \"%s\" for \"%s\" option. ",args[i],args[i-1]);
            Syntax("FractionPerformance");
            return;
          }
        } else if(args[i].equals("-r") || args[i].equals("--random")) {
          if(i == (args.length-1)) {
            System.out.format("Value needs to be supplied for \"%s\" option. ",args[i]);
            Syntax("FractionPerformance");
            return;
          }
          i++;
          try {
            minTest=Integer.parseInt(args[i]);
          } catch(NumberFormatException ne2) {
            System.out.format("Invalid value \"%s\" for \"%s\" option. ",args[i],args[i-1]);
            Syntax("FractionPerformance");
            return;
          }
        } else {
          System.out.format("Invalid options specified %s\n",args[i]);
          Syntax("FractionPerformance");
          return;
        }
      }
      if(denominator > 0)
        fp.SingleTest(denominator);
      if(minTest > 0)
        fp.RandomTest(minTest);
    } else {
      fp.SingleTest(1000);
      fp.RandomTest(1000);
    }
  }
}
