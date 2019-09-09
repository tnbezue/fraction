using System;

class TestHarness
{
  protected static int nPass=0;
  protected static int nFail=0;
  protected static int nTotalPass=0;
  protected static int nTotalFail=0;

  public delegate void TestMethod();

  public static void Summary()
  {
    Console.WriteLine("  Passed: "+nPass);
    Console.WriteLine("  Failed: "+nFail);
    Console.WriteLine();
  }

  public static void FinalSummary()
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      Console.WriteLine("Total pass: "+nTotalPass);
      Console.WriteLine("Total fail: "+nTotalFail);
    }
  }

  public static void TestCase(String msg)
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      nPass=0;
      nFail=0;
    }
    Console.WriteLine(msg);
  }

  public static void Test(String msg,bool condition)
  {
    if(condition)
      nPass++;
    else
      nFail++;
    Console.WriteLine("  "+msg+" ... "+(condition ? "Pass" : "Fail"));
  }
}
