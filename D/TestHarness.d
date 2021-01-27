import std.stdio;
import std.string;

struct TestHarness {
  protected:
    static int nPass;
    static int nFail;
    static int nTotalPass;
    static int nTotalFail;
    static int nTestCases;

  public:
    static void Summary()
    {
      stdout.writeln("\n  Summary");
      stdout.writeln("    Passed: ",nPass);
      stdout.writeln("    Failed: ",nFail);
      stdout.writeln();
      nPass = 0;
      nFail = 0;
    }

    static void FinalSummary()
    {
      if(nPass > 0 || nFail > 0) {
        nTotalPass+=nPass;
        nTotalFail+=nFail;
        Summary();
        stdout.writeln("\n  Final Summary");
        stdout.writeln(format("    %5d Test Cases",nTestCases));
        stdout.writeln(format("    %5d Total Tests",(nTotalPass+nTotalFail)));
        stdout.writeln(format("    %5d Total Passed",nTotalPass));
        stdout.writeln(format("    %5d Total Failed",nTotalFail));
      }
    }

    static void TestCase(string msg)
    {
      if(nPass > 0 || nFail > 0) {
        nTotalPass+=nPass;
        nTotalFail+=nFail;
        Summary();
      }
      nTestCases++;
      stdout.writeln("\n",msg);
    }

    static void Test(string msg,bool condition)
    {
      if(condition)
        nPass++;
      else
        nFail++;
      stdout.writeln(msg," ... ",(condition ? "Pass" : "Fail"));
    }

    /*
      Boolean testing.  Expected result is true or false.
    */
    static void Test(string msg,bool condition,bool expected_result)
    {
      bool pf = condition == expected_result;
      if(pf)
        nPass++;
      else
        nFail++;
      stdout.writeln(msg," (", (expected_result ? "True" : "False"), ") ... ",(pf ? "Pass" : "Fail"));
    }

    void PassIncrement() { nPass++; }
    void FailIncrement() { nFail++; }
};
