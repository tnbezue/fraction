
TestHarness = { nTestCases=0, nFail = 0, nPass = 0, nTotalPass=0,nTotalFail=0}
TestHarness.__index = TestHarness

function TestHarness:new()
  o = { }
  setmetatable(o,self)
  self.__index=self
  return o
end

function TestHarness:summary()
  print(string.format("Summary\n  Passed: %4d\n  Failed: %4d\n",self.nPass,self.nFail))
end

function TestHarness:testcase(s)
  self.nTestCases=self.nTestCases+1
  if(self.nPass > 0 or self.nFail > 0) then
    self:summary()
  end
  print(s)
  self.nTotalPass = self.nTotalPass + self.nPass
  self.nTotalFail = self.nTotalFail + self.nFail
  self.nPass = 0
  self.nFail = 0
end

function TestHarness:test(s,t)
  res=""
  if (t) then
    self.nPass= self.nPass + 1
    res="Pass"
  else
    self.nFail= self.nFail + 1
    res="Fail"
  end
  print(string.format("  %s .. %s",s,res))
end

function TestHarness:final_summary()
  if(self.nPass > 0 or self.nFail > 0) then
    self:summary()
  end
  self.nTotalPass = self.nTotalPass + self.nPass
  self.nTotalFail = self.nTotalFail + self.nFail
  print(string.format("\nFinal Summary\n %6d Test Cases\n %6d Total Tests\n %6d Total Passed\n %6d Total Failed",
      self.nTestCases,(self.nTotalPass+self.nTotalFail),self.nTotalPass,self.nTotalFail))
end
