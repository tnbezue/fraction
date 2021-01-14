#include "TestHarness.bi"
#include "Fraction.bi"

Dim Shared th as TestHarness

function R (ByRef f as Fraction, ByVal n as LongInt, ByVal d as LongInt ) as Boolean
  return f.numerator = n and f.denominator = d
end Function

sub TestGCD()
  th.TestCase("Greatest common denominator")
  dim as LongInt test_data(...,...) = {_
      { 10,2,2},_
      { 10,1,1},_
      { 105,15,15},_
      { 10,230,10},_
      { 28,234,2},_
      {872452914,78241452,6 }_
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("GCD("+str(test_data(i,0))+","+str(test_data(i,1))+")="+str(test_data(i,2)),_
        Fraction.GCD(test_data(i,0),test_data(i,1)) = test_data(i,2))
  next i
end sub

sub testConstrutorZero()
  th.TestCase("Constructor with no arguments")
  Dim as Fraction f
  th.Test("Fraction() = (0/1)",R(f,0,1))
end sub


sub TestConstructorOne()
  th.TestCase("Constructor with one argument")
  dim as LongInt test_data(...,...) = {_
      { 10,10,1},_
      { -5,-5,1},_
      { 105,105,1}_
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("Fraction("+str(test_data(i,0))+")=("+str(test_data(i,1))+"/"+str(test_data(i,2))+")", _
        R(Fraction(test_data(i,0)),test_data(i,1),test_data(i,2)))
  next i
end sub

sub TestConstructorTwo()
  th.TestCase("Constructor with two arguments")
  dim as LongInt test_data(...,...) = {_
      { 10,3,10,3},_
      { -5,15, -1,3},_
      { 105,-7,-15,1}, _
      { -105,-7,15,1}, _
      { -10,-7,10,7}, _
      { 23,25,23,25}_
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("Fraction("+str(test_data(i,0))+","+str(test_data(i,1))+")=("+str(test_data(i,2))+"/"+str(test_data(i,3))+")", _
        R(Fraction(test_data(i,0),test_data(i,1)),test_data(i,2),test_data(i,3)))
  next i
end sub

sub TestConstructorThree()
  th.TestCase("Constructor with three arguments")
  dim as LongInt test_data(...,...) = { _
      { -10,2,3,-32,3 }, _
      {0,-2,3,-2,3}, _
      {0,0,1,0,1}, _
      {0,2,3,2,3}, _
      {10,2,3,32,3} _
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("Fraction("+str(test_data(i,0))+","+str(test_data(i,1))+","+str(test_data(i,2))+ _
        ")=("+str(test_data(i,3))+"/"+str(test_data(i,4))+")", _
        R(Fraction(test_data(i,0),test_data(i,1),test_data(i,2)),test_data(i,3),test_data(i,4)))
  next i
end sub

sub TestConstructorDouble()
  th.TestCase("Constructor with floating point argument")
  dim as Double test_data(...) = {  0.0, 1.0, 12.25, -2.5, -0.06, 0.3, 0.33, 0.33333333 }
  dim as LongInt result(...,...) = { {0,1}, {1,1}, {49,4}, {-5,2}, {-3,50}, {3,10}, {33,100}, {1,3}}
  for i as integer = 0 to UBound(test_data)
    th.Test("Fraction("+str(test_data(i))+")=("+str(result(i,0))+"/"+str(result(i,1))+")", _
        R(Fraction(test_data(i)),result(i,0),result(i,1)))
  next i
end sub

sub TestCastDouble()
  th.TestCase("Cast Fraction to double")
  dim as Double test_data(...) = {  12.25, -2.5, -0.06, 0.3, 0.33, 0.33333333 }
  dim as LongInt result(...,...) = { {49,4}, {-5,2}, {-3,50}, {3,10}, {33,100}, {1,3}}
  for i as integer = 0 to UBound(test_data)
    th.Test("Fraction("+str(test_data(i))+")=("+str(result(i,0))+"/"+str(result(i,1))+")", _
        R(Fraction(test_data(i)),result(i,0),result(i,1)))
  next i
end sub

sub TestCastString()
  th.TestCase("Cast Fraction to String")
  dim as LongInt test_data(...,...) = { _
      { 0, 1}, _
      { 2, 1}, _
      { 3, 4 }, _
      { -3, 4}, _
      { 22, 7}, _
      { 22, -7}, _
      { -9, -15}, _
      { 105, 2} _
  }
  dim as String result(...) = { _
      "0", _
      "2", _
      "3/4", _
      "-3/4", _
      "22/7", _
      "-22/7", _
      "3/5", _
      "105/2" _
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("str(Fraction("+str(test_data(i,0))+","+str(test_data(i,1))+!"))=\""+result(i)+!"\"", _
        str(Fraction(test_data(i,0),test_data(i,1))) = result(i))
  next i
end sub

sub TestMixedCastString()
  th.TestCase("Cast MixedFraction to String")
  dim as Fraction test_data(...,...) = { _
      { 0, 0, 1}, _
      { 0, 2, 1}, _
      { 2, 3, 4 }, _
      { 2 ,-3, 4}, _
      { 0, 22, 7}, _
      { 0, 22, -7}, _
      { -1, -9, -15}, _
      { 0, 105, 2} _
  }
  dim as String result(...) = { _
      "0", _
      "2", _
      "2 3/4", _
      "-2 3/4", _
      "3 1/7", _
      "-3 1/7", _
      "-1 3/5", _
      "52 1/2" _
  }
  for i as integer = 0 to UBound(test_data)
    th.Test("str(MixedFraction("+str(test_data(i,0))+","+str(test_data(i,1))+","+str(test_data(i,2))+!"))=\""+result(i)+!"\"", _
        str(MixedFraction(test_data(i,0),test_data(i,1),test_data(i,2))) = result(i))
  next i
end sub

sub TestFractionPlusFraction()
  th.TestCase("Fraction plus fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1,0,1}, _
      {0,1,1,1,1,1}, _
      {3,5,-2,9,17,45}, _
      {-2,8,-6,8,-1,1}, _
      {7,3,10,7,79,21}, _
      {-5,7,25,35,0,1} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2 = Fraction(test_data(i,2),test_data(i,3))
    dim as Fraction f3
    f3 = f1 + f2
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")+("+str(test_data(i,2))+"/"+str(test_data(i,3))+ _
      ")=("+str(test_data(i,4))+"/"+str(test_data(i,5))+")", _
        R(f3,test_data(i,4),test_data(i,5)))
  next i
end sub

sub TestFractionMinusFraction()
  th.TestCase("Fraction minus fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1,0,1}, _
      {0,1,1,1,-1,1}, _
      {3,5,-2,9,37,45}, _
      {-2,8,-6,8,1,2}, _
      {7,3,10,7,19,21}, _
      {-5,7,25,35,-10,7} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2 = Fraction(test_data(i,2),test_data(i,3))
    dim as Fraction f3
    f3 = f1 - f2
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")-("+str(test_data(i,2))+"/"+str(test_data(i,3))+ _
      ")=("+str(test_data(i,4))+"/"+str(test_data(i,5))+")", _
        R(f3,test_data(i,4),test_data(i,5)))
  next i
end sub

sub TestFractionTimesFraction()
  th.TestCase("Fraction times fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1,0,1}, _
      {0,1,1,1,0,1}, _
      {3,5,-2,9,-2,15}, _
      {-2,8,-6,8,3,16}, _
      {7,3,10,7,10,3}, _
      {-5,7,25,35,-25,49} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2 = Fraction(test_data(i,2),test_data(i,3))
    dim as Fraction f3
    f3 = f1 * f2
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")*("+str(test_data(i,2))+"/"+str(test_data(i,3))+ _
      ")=("+str(test_data(i,4))+"/"+str(test_data(i,5))+")", _
        R(f3,test_data(i,4),test_data(i,5)))
  next i
end sub

sub TestFractionDividedByFraction()
  th.TestCase("Fraction Divided By fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1,1,1,0,1}, _
      {3,5,-2,9,-27,10}, _
      {-2,8,-6,8,1,3}, _
      {7,3,10,7,49,30}, _
      {-5,7,25,35,-1,1} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2 = Fraction(test_data(i,2),test_data(i,3))
    dim as Fraction f3
    f3 = f1 / f2
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")/("+str(test_data(i,2))+"/"+str(test_data(i,3))+ _
      ")=("+str(test_data(i,4))+"/"+str(test_data(i,5))+")", _
        R(f3,test_data(i,4),test_data(i,5)))
  next i
end sub

sub TestFractionPlusDouble()
  th.TestCase("Fraction plus double")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1}, _
      {0,1,1,1}, _
      {3,5,17,45}, _
      {-2,8,-1,1}, _
      {7,3,79,21}, _
      {-5,7,0,1} _
  }
  dim as Double flt_data(...) = {_
      0.0, _
      1.0, _
      -2.0/9.0, _
      -6.0/8.0, _
      10.0/7.0, _
      25.0/35.0 _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2
    f2 = f1 + flt_data(i)
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")+("+str(flt_data(i))+ _
      ")=("+str(test_data(i,2))+"/"+str(test_data(i,3))+")", _
        R(f2,test_data(i,2),test_data(i,3)))
  next i
end sub

sub TestFractionMinusDouble()
  th.TestCase("Fraction minus double")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1}, _
      {0,1,-1,1}, _
      {3,5,37,45}, _
      {-2,8,1,2}, _
      {7,3,19,21}, _
      {-5,7,-10,7} _
  }
  dim as Double flt_data(...) = {_
      0.0, _
      1.0, _
      -2.0/9.0, _
      -6.0/8.0, _
      10.0/7.0, _
      25.0/35.0 _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2
    f2 = f1 - flt_data(i)
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")-("+str(flt_data(i))+ _
      ")=("+str(test_data(i,2))+"/"+str(test_data(i,3))+")", _
        R(f2,test_data(i,2),test_data(i,3)))
  next i
end sub

sub TestFractionTimesDouble()
  th.TestCase("Fraction times double")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1}, _
      {0,1,0,1}, _
      {3,5,-2,15}, _
      {-2,8,3,16}, _
      {7,3,10,3}, _
      {-5,7,-25,49} _
  }
  dim as Double flt_data(...) = {_
      0.0, _
      1.0, _
      -2.0/9.0, _
      -6.0/8.0, _
      10.0/7.0, _
      25.0/35.0 _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2
    f2 = f1 * flt_data(i)
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")*("+str(flt_data(i))+ _
      ")=("+str(test_data(i,2))+"/"+str(test_data(i,3))+")", _
        R(f2,test_data(i,2),test_data(i,3)))
  next i
end sub

sub TestFractionDividedByDouble()
  th.TestCase("Fraction divided by double")
  dim as LongInt test_data(...,...) ={ _
      {0,1,0,1}, _
      {3,5,-27,10}, _
      {-2,8,1,3}, _
      {7,3,49,30}, _
      {-5,7,-1,1} _
  }
  dim as Double flt_data(...) = {_
      1.0, _
      -2.0/9.0, _
      -6.0/8.0, _
      10.0/7.0, _
      25.0/35.0 _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f1 = Fraction(test_data(i,0),test_data(i,1))
    dim as Fraction f2
    f2 = f1 / flt_data(i)
    th.Test("("+str(test_data(i,0))+"/"+str(test_data(i,1))+")/("+str(flt_data(i))+ _
      ")=("+str(test_data(i,2))+"/"+str(test_data(i,3))+")", _
        R(f2,test_data(i,2),test_data(i,3)))
  next i
end sub

sub TestDoublePlusFraction()
  th.TestCase("Double plus fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1}, _
      {1,1}, _
      {-2,9}, _
      {-6,8}, _
      {10,7}, _
      {25,35} _
  }
  dim as Double flt_data(...,...) = {_
      { 0.0,0.0}, _
      { 0.0,1.0}, _
      { 0.6, 17.0/45.0}, _
      { -2.0/8.0, -1.0 }, _
      { 7.0/3.0, 79.0/21.0 }, _
      { -5.0/7.0, 0.0} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f = Fraction(test_data(i,0),test_data(i,1))
    dim as Double d
    d = flt_data(i,0) + f
    th.Test("("+str(flt_data(i,0))+")+("+str(test_data(i,0))+"/"+str(test_data(i,1))+ _
      ")=("+str(flt_data(i,1))+")", _
        abs(d-flt_data(i,1)) < Fraction.Epsilon)
  next i
end sub

sub TestDoubleMinusFraction()
  th.TestCase("Double minux fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1}, _
      {1,1}, _
      {-2,9}, _
      {-6,8}, _
      {10,7}, _
      {25,35} _
  }
  dim as Double flt_data(...,...) = {_
      { 0.0,0.0}, _
      { 0.0,-1.0}, _
      { 0.6, 37.0/45.0}, _
      { -2.0/8.0, 1.0/2.0 }, _
      { 7.0/3.0, 19.0/21.0 }, _
      { -5.0/7.0, -10.0/7.0 } _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f = Fraction(test_data(i,0),test_data(i,1))
    dim as Double d
    d = flt_data(i,0) - f
    th.Test("("+str(flt_data(i,0))+")-("+str(test_data(i,0))+"/"+str(test_data(i,1))+ _
      ")=("+str(flt_data(i,1))+")", _
        abs(d-flt_data(i,1)) < Fraction.Epsilon)
  next i
end sub

sub TestDoubleTimesFraction()
  th.TestCase("Double times fraction")
  dim as LongInt test_data(...,...) ={ _
      {0,1}, _
      {1,1}, _
      {-2,9}, _
      {-6,8}, _
      {10,7}, _
      {25,35} _
  }
  dim as Double flt_data(...,...) = {_
      { 0.0,0.0}, _
      { 0.0,0.0}, _
      { 0.6, -2.0/15.0}, _
      { -2.0/8.0, 3.0/16.0 }, _
      { 7.0/3.0, 10.0/3.0 }, _
      { -5.0/7.0, -25.0/49 } _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f = Fraction(test_data(i,0),test_data(i,1))
    dim as Double d
    d = flt_data(i,0) * f
    th.Test("("+str(flt_data(i,0))+")*("+str(test_data(i,0))+"/"+str(test_data(i,1))+ _
      ")=("+str(flt_data(i,1))+")", _
        abs(d-flt_data(i,1)) < Fraction.Epsilon)
  next i
end sub

sub TestDoubleDividedByFraction()
  th.TestCase("Double divided by fraction")
  dim as LongInt test_data(...,...) ={ _
      {1,1}, _
      {-2,9}, _
      {-6,8}, _
      {10,7}, _
      {25,35} _
  }
  dim as Double flt_data(...,...) = {_
      { 0.0,0.0}, _
      { 0.6, -27.0/10.0}, _
      { -2.0/8.0, 1.0/3.0 }, _
      { 7.0/3.0, 49.0/30.0 }, _
      { -5.0/7.0, -1.0} _
  }
  for i as integer = 0 to UBound(test_data)
    dim as Fraction f = Fraction(test_data(i,0),test_data(i,1))
    dim as Double d
    d = flt_data(i,0) / f
    th.Test("("+str(flt_data(i,0))+")/("+str(test_data(i,0))+"/"+str(test_data(i,1))+ _
      ")=("+str(flt_data(i,1))+")", _
        abs(d-flt_data(i,1)) < Fraction.Epsilon)
  next i
end sub

Dim as Sub() tests(...) = {_
  @TestGCD, _
  @testConstrutorZero, _
  @TestConstructorOne, _
  @TestConstructorTwo, _
  @TestConstructorThree, _
  @TestConstructorDouble, _
  @TestCastDouble , _
  @TestCastString ,  _
  @TestMixedCastString, _
  @TestFractionPlusFraction, _
  @TestFractionMinusFraction, _
  @TestFractionTimesFraction, _
  @TestFractionDividedByFraction, _
  @TestFractionPlusDouble, _
  @TestFractionMinusDouble, _
  @TestFractionTimesDouble, _
  @TestFractionDividedByDouble, _
  @TestDoublePlusFraction, _
  @TestDoubleMinusFraction, _
  @TestDoubleTimesFraction, _
  @TestDoubleDividedByFraction _
}

for i as integer = 0 to ubound(tests)
  tests(i)()
next i
th.FinalSummary()
