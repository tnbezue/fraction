#pragma once

Type TestHarness
    Declare Constructor()
    Declare Sub Summary()
    Declare Sub TestCase(ByRef txt as String)
    Declare Sub Test(ByRef txt as String,result as Boolean)
    Declare Sub FinalSummary()
  private:
    nPass as Integer
    nFail as Integer
    nTotalPass as Integer
    nTotalFail as Integer
    nTestCases as Integer
end Type
