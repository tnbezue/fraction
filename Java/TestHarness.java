
public class TestHarness
{
  static int nPass;
  static int nFail;
  static int nTotalPass=0;
  static int nTotalFail=0;

  interface TestMethod {
    public void test();
  }

  static void Summary()
  {
    System.out.println("  Passed: "+nPass);
    System.out.println("  Failed: "+nFail);
    System.out.println();
  }

  static void FinalSummary()
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      System.out.println("Total pass: "+nTotalPass);
      System.out.println("Total fail: "+nTotalFail);
    }
  }

  static void TestCase(String msg)
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      nPass=0;
      nFail=0;
    }
    System.out.println(msg);
  }

  static void Test(String msg,boolean condition)
  {
    if(condition)
      nPass++;
    else
      nFail++;
    System.out.println(msg+" ... "+(condition ? "Pass" : "Fail"));
  }
}
