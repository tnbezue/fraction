import sys

class TestHarness:
  'Basic (very basic) testing framework'
  nPass = 0
  nFail = 0
  nTotalPass = 0
  nTotalFail = 0
  nTestCases = 0

  @classmethod
  def Summary(self):
    print("Summary")
    print("  Passed: %d" % self.nPass)
    print("  Failed: %d\n" % self.nFail)

  @classmethod
  def FinalSummary(self):
    if self.nPass > 0 or self.nFail > 0:
      self.Summary()
    self.nTotalPass += self.nPass
    self.nTotalFail += self.nFail
    print("\nFinal Summary")
    print("  %5d Total Cases: " % self.nTestCases)
    print("  %5d Total Tests" % (self.nTotalPass + self.nTotalFail))
    print("  %5d Total Passed" % self.nTotalPass)
    print("  %5d Total Failed" % self.nTotalFail)

  @classmethod
  def TestCase(self,msg):
    if self.nPass > 0 or self.nFail > 0:
      self.Summary()
    self.nTotalPass += self.nPass
    self.nTotalFail += self.nFail
    self.nPass = 0
    self.nFail = 0
    self.nTestCases += 1
    print(msg)

  @classmethod
  def Test(self,msg,result):
    if result:
      self.nPass+=1
      print(" ",msg,"... pass")
    else:
      self.nFail+=1
      print(" ",msg,"... fail")

  @classmethod
  def RunTests(self,tests,test_numbers):
    nTests = len(tests)
    if len(test_numbers) > 0:
      for itest in test_numbers:
        i = int(itest)
        if i < nTests:
          tests[i]()
        else:
          print("No test for ",itest)
    else:
      for test in tests:
        test()
    self.FinalSummary()
