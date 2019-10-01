import sys

class TestHarness:
  'Basic (very basic) testing framework'
  nPass = 0
  nFail = 0
  nTotalPass = 0
  nTotalFail = 0

  @classmethod
  def Summary(self):
    print("  Passed: %d" % self.nPass)
    print("  Failed: %d\n" % self.nFail)

  @classmethod
  def FinalSummary(self):
    if self.nPass > 0 or self.nFail > 0:
      self.Summary()
    self.nTotalPass += self.nPass
    self.nTotalFail += self.nFail
    print("Total Passed: %d" % self.nTotalPass)
    print("Total Failed: %d" % self.nTotalFail)

  @classmethod
  def TestCase(self,msg):
    if self.nPass > 0 or self.nFail > 0:
      self.Summary()
    self.nTotalPass += self.nPass
    self.nTotalFail += self.nFail
    self.nPass = 0
    self.nFail = 0
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
  def RunTests(self,tests):
    nTests = len(tests)
    if len(sys.argv) > 1:
      for itest in sys.argv[1:]:
        i = int(itest)
        if i < nTests:
          tests[i]()
        else:
          print("No test for ",itest)
    else:
      for test in tests:
        test()
    self.FinalSummary()
