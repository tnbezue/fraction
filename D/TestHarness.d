import std.stdio;

struct TestHarness {
  protected:
    static int nPass;
    static int nFail;
    static int nTotalPass;
    static int nTotalFail;

  public:
    static void Summary()
    {
      stdout.writeln("  Passed: ",nPass);
      stdout.writeln("  Failed: ",nFail);
      stdout.writeln();

    }
  static void FinalSummary()
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      stdout.writeln("Total pass: ",nTotalPass);
      stdout.writeln("Total fail: ",nTotalFail);
    }
  }

  static void TestCase(string msg)
  {
    if(nPass > 0 || nFail > 0) {
      Summary();
      nTotalPass+=nPass;
      nTotalFail+=nFail;
      nPass=0;
      nFail=0;
    }
    stdout.writeln(msg);
  }

   void Test(string msg,bool condition)
  {
    if(condition)
      nPass++;
    else
      nFail++;
    stdout.writeln(msg," ... ",(condition ? "Pass" : "Fail"));
  }
};
