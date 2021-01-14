#include once "TestHarness.bi"

Constructor TestHarness()
  nPass = 0
  nFail = 0
  nTotalPass = 0
  nTotalFail = 0
  nTestCases = 0
End Constructor

Sub TestHarness.Summary
  print "Summary"
  print using "  Passed: &";nPass
  print using "  Failed: &";nFail
End Sub

Sub TestHarness.TestCase(ByRef txt as String)
  nTestCases+=1
  if nPass > 0 or nFail > 0 then
    Summary()
  end if
  nTotalPass += nPass
  nTotalFail += nFail
  nPass=0
  nFail=0
  print using !"\n&";txt
End Sub

Sub TestHarness.Test(ByRef txt as String,result as Boolean)
  Dim result_str as String
  if result then
    nPass+=1
    result_str = "Pass"
  else
    nFail+=1
    result_str = "Fail"
  end if
  Print using "  & .. &";txt;result_str
End Sub

Sub TestHarness.FinalSummary()
  if nPass > 0 or nFail > 0 then
    Summary()
    nTotalPass += nPass
    nTotalFail += nFail
  End if
  print !"\nFinal Summary"
  print using "  #### Test cases";nTestCases
  print using "  #### Total tests";(nTotalPass+nTotalFail)
  print using "  #### Total Passed";nTotalPass
  print using "  #### Total Failed";nTotalFail
End Sub
