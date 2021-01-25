#!/usr/bin/env -S ruby -I.

require 'getoptlong'

opts = GetoptLong.new(
  [ '--native', '-n', GetoptLong::NO_ARGUMENT],
  [ '--mixed', '-m',  GetoptLong::NO_ARGUMENT]
)

native = false
mixed = false
opts.each do |opt,arg|
  if opt == '--native'
    native = true
  elsif opt == '--mixed'
    mixed = true
  end
end

if native
  require_relative "FractionNative"
else
  require_relative 'fraction'
end
require_relative 'test_harness'

if mixed
  FractionType = MixedFraction
else
  FractionType = Fraction
end

$tester = TestHarness.new

def S(f,n,d)
  f.numerator=n
  f.denominator=d
end

def SM(f,w,n,d)
  f.numerator=w*d + (w<0?-1:1)*n
  f.denominator=d
end

def R(f,n,d)
  f.numerator==n && f.denominator==d
end

def test_gcd
  test_data = [
    [ 0,2,2],
    [ 10,1,1],
    [ 105,15,15],
    [ 10,230,10],
    [ 28,234,2],
    [872452914,78241452,6 ],
    [17179869183,68719476736,1]
  ]

  $tester.TestCase("Greatest common denominator")
  test_data.each do |n,d,rn|
    $tester.Test("GCD(#{n},#{d}) = #{rn}",FractionType.gcd(n,d)==rn)
  end
end

def test_set_int
  $tester.TestCase("#{FractionType}.new(int)")
  test_data = [ [ 10, 10] , [-12, -12], [0,0] ]
  test_data.each do |n,rn|
    $tester.Test("#{FractionType}.new(#{n}) = (#{rn},1)",R(FractionType.new(n),rn,1))
  end
end

def test_set_int_int
  $tester.TestCase("#{FractionType}.new(int,int)")
  test_data = [
    [ 0,1,0,1 ],
    [1,1,1,1],
    [-2,3,-2,3],
    [2,-3,-2,3],
    [-2,-3,2,3],
    [17179869183,68719476736,17179869183 ,68719476736],
    [68719476736,17179869183, 68719476736,17179869183] ,
    [-17179869183,68719476736,-17179869183 ,68719476736],
    [-68719476736,17179869183, -68719476736,17179869183]
  ]
  test_data.each do |n,d,rn,rd|
    $tester.Test("#{FractionType}(#{n},#{d}) = (#{rn},#{rd})",R(FractionType.new(n,d),rn,rd))
  end
end

def test_set_int_int_int
  $tester.TestCase("#{FractionType}.new(int,int,int)")
  test_data=[
    [ -10,2,3,-32,3 ],
    [0,-2,3,-2,3],
    [0,0,1,0,1],
    [0,2,3,2,3],
    [10,2,3,32,3]
  ]
  test_data.each do |w,n,d,rn,rd|
    $tester.Test("Fraction(#{w},#{n},#{d}) = (#{rn},#{rd})",R(FractionType.new(w,n,d),rn,rd))
  end
end

def tst_set_double
  $tester.TestCase("Fraction.new(double)")
  test_data=[
    [ -10.66666667,-32,3 ],
    [-0.66666667,-2,3],
    [0.0,0,1],
    [0.66666667,2,3],
    [10.66666667,32,3]
  ]
  test_data.each do |d,rn,rd|
    $tester.Test("Fraction(#{d}) = (#{rn},#{rd})",R(FractionType.new(d),rn,rd))
  end
end

def test_set_string
  $tester.TestCase("Fraction.new(string)")
  test_data=[
    [ "-10.66666667",-32,3 ],
    ["-0.66666667",-2,3],
    ["0.0",0,1],
    ["0.66666667",2,3],
    ["10.66666667",32,3],
    [ "-10 2/3" , -32, 3 ]
  ]
  test_data.each do |d,rn,rd|
    $tester.Test("Fraction(\"#{d}\") = (#{rn},#{rd})",R(FractionType.new(d),rn,rd))
  end
end

def test_to_s
  test_data = nil
  if FractionType == Fraction
    test_data = [
      [ 0,1, "0"],
      [ 2,10, "1/5"],
      [ -16,3, "-16/3"],
      [ 9,150, "3/50"],
      [ -2,3, "-2/3"],
      [ -2,-3, "2/3"],
    ]
  else
    test_data = [
      [ 0,1, "0"],
      [ 2,10, "1/5"],
      [ -16,3, "-5 1/3"],
      [ 150,9, "16 2/3"],
      [ -2,3, "-2/3"],
      [ -2,-3, "2/3"],
    ]
  end
  test_data.each do |n,d,s|
    f=FractionType.new(n,d)
    fs=f.to_s
    $tester.Test("#{FractionType}.new(#{n},#{d}).to_s = #{s}",fs==s)
  end
end

def test_fraction_eq_fraction
  $tester.TestCase("Fraction == fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), true ],
    [ FractionType.new(0,1), FractionType.new(1,2), false ],
    [ FractionType.new(2,3), FractionType.new(-2,4), false ],
    [ FractionType.new(2,3), FractionType.new(16,24), true ],
    [ FractionType.new(1,3), FractionType.new(1,3), true ],
    [ FractionType.new(-5,7), FractionType.new(25,35), false ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})==(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 == f2) == tf)
  end
end

def test_fraction_ne_fraction
  $tester.TestCase("Fraction != fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), false ],
    [ FractionType.new(0,1), FractionType.new(1,2), true ],
    [ FractionType.new(2,3), FractionType.new(-2,4), true ],
    [ FractionType.new(2,3), FractionType.new(16,24), false ],
    [ FractionType.new(1,3), FractionType.new(1,3), false ],
    [ FractionType.new(-5,7), FractionType.new(25,35), true ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})!=(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 != f2) == tf)
  end
end

def test_fraction_lt_fraction
  $tester.TestCase("Fraction < fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), false ],
    [ FractionType.new(0,1), FractionType.new(1,2), true ],
    [ FractionType.new(2,3), FractionType.new(-2,4), false ],
    [ FractionType.new(2,3), FractionType.new(16,24), false ],
    [ FractionType.new(1,3), FractionType.new(1,3), false ],
    [ FractionType.new(-5,7), FractionType.new(25,35), true ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})<(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 < f2) == tf)
  end
end

def test_fraction_le_fraction
  $tester.TestCase("Fraction <= fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), true ],
    [ FractionType.new(0,1), FractionType.new(1,2), true ],
    [ FractionType.new(2,3), FractionType.new(-2,4), false ],
    [ FractionType.new(2,3), FractionType.new(16,24), true ],
    [ FractionType.new(1,3), FractionType.new(1,3), true ],
    [ FractionType.new(-5,7), FractionType.new(25,35), true ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})<=(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 <= f2) == tf)
  end
end

def test_fraction_gt_fraction
  $tester.TestCase("Fraction > fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), false ],
    [ FractionType.new(0,1), FractionType.new(1,2), false ],
    [ FractionType.new(2,3), FractionType.new(-2,4), true ],
    [ FractionType.new(2,3), FractionType.new(16,24), false ],
    [ FractionType.new(1,3), FractionType.new(1,3), false ],
    [ FractionType.new(-5,7), FractionType.new(25,35), false ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})>(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 > f2) == tf)
  end
end

def test_fraction_ge_fraction
  $tester.TestCase("Fraction == fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), true ],
    [ FractionType.new(0,1), FractionType.new(1,2), false ],
    [ FractionType.new(2,3), FractionType.new(-2,4), true ],
    [ FractionType.new(2,3), FractionType.new(16,24), true ],
    [ FractionType.new(1,3), FractionType.new(1,3), true ],
    [ FractionType.new(-5,7), FractionType.new(25,35), false ],
  ]
  test_data.each do |f1,f2,tf|
    $tester.Test("(#{f1.to_s})>=(#{f2.to_s}) - " + (tf ? "true" : "false"),(f1 >= f2) == tf)
  end
end

def test_fraction_eq_number
  $tester.TestCase("Fraction == number")
  test_data = [
    [ FractionType.new(0,1), 0, true ],
    [ FractionType.new(0,1), 1.0/2.0, false ],
    [ FractionType.new(2,3), -2.0/4.0, false ],
    [ FractionType.new(2,3), 16.0/24.0, true ],
    [ FractionType.new(1,3), 1.0/3.0, true ],
    [ FractionType.new(-5,7), 25.0/35.0, false ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s})==(#{d}) - " + (tf ? "true" : "false"),(f == d) == tf)
  end
end

def test_fraction_ne_number
  $tester.TestCase("Fraction != number")
  test_data = [
    [ FractionType.new(0,1), 0, false ],
    [ FractionType.new(0,1), 1.0/2.0, true ],
    [ FractionType.new(2,3), -2.0/4.0, true ],
    [ FractionType.new(2,3), 16.0/24.0, false ],
    [ FractionType.new(1,3), 1.0/3.0, false ],
    [ FractionType.new(-5,7), 25.0/35.0, true ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s})!=(#{d}) - " + (tf ? "true" : "false"),(f != d) == tf)
  end
end

def test_fraction_lt_number
  $tester.TestCase("Fraction < number")
  test_data = [
    [ FractionType.new(0,1), 0, false ],
    [ FractionType.new(0,1), 1.0/2.0, true ],
    [ FractionType.new(2,3), -2.0/4.0, false ],
    [ FractionType.new(2,3), 16.0/24.0, false ],
    [ FractionType.new(1,3), 1.0/3.0, false ],
    [ FractionType.new(-5,7), 25.0/35.0, true ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s})<(#{d}) - " + (tf ? "true" : "false"),(f < d) == tf)
  end
end

def test_fraction_le_number
  $tester.TestCase("Fraction <= number")
  test_data = [
    [ FractionType.new(0,1), 0, true ],
    [ FractionType.new(0,1), 1.0/2.0, true ],
    [ FractionType.new(2,3), -2.0/4.0, false ],
    [ FractionType.new(2,3), 16.0/24.0, true ],
    [ FractionType.new(1,3), 1.0/3.0, true ],
    [ FractionType.new(-5,7), 25.0/35.0, true ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s})<=(#{d}) - " + (tf ? "true" : "false"),(f <= d) == tf)
  end
end

def test_fraction_gt_number
  $tester.TestCase("Fraction > number")
  test_data = [
    [ FractionType.new(0,1), 0, false ],
    [ FractionType.new(0,1), 1.0/2.0, false ],
    [ FractionType.new(2,3), -2.0/4.0, true ],
    [ FractionType.new(2,3), 16.0/24.0, false ],
    [ FractionType.new(1,3), 1.0/3.0, false ],
    [ FractionType.new(-5,7), 25.0/35.0, false ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s}) > (#{d}) - " + (tf ? "true" : "false"),(f > d) == tf)
  end
end

def test_fraction_ge_number
  $tester.TestCase("Fraction >= number")
  test_data = [
    [ FractionType.new(0,1), 0, true ],
    [ FractionType.new(0,1), 1.0/2.0, false ],
    [ FractionType.new(2,3), -2.0/4.0, true ],
    [ FractionType.new(2,3), 16.0/24.0, true ],
    [ FractionType.new(1,3), 1.0/3.0, true ],
    [ FractionType.new(-5,7), 25.0/35.0, false ],
  ]
  test_data.each do |f,d,tf|
    $tester.Test("(#{f.to_s}) >= (#{d}) - " + (tf ? "true" : "false"),(f>= d) == tf)
  end
end

def test_number_eq_fraction
  $tester.TestCase("Number == fraction")
  test_data = [
    [ 0, FractionType.new(0,1), true ],
    [ 0, FractionType.new(1,2), false ],
    [ 2.0/3.0, FractionType.new(-2,4), false ],
    [ 2.0/3.0, FractionType.new(16,24), true ],
    [ 1.0/3.0, FractionType.new(1,3), true ],
    [ -5.0/7.0, FractionType.new(25,35), false ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d})==(#{f.to_s}) - " + (tf ? "true" : "false"),(d == f) == tf)
  end
end

def test_number_ne_fraction
  $tester.TestCase("Number !== fraction")
  test_data = [
    [ 0, FractionType.new(0,1), false ],
    [ 0, FractionType.new(1,2), true ],
    [ 2.0/3.0, FractionType.new(-2,4), true ],
    [ 2.0/3.0, FractionType.new(16,24), false ],
    [ 1.0/3.0, FractionType.new(1,3), false ],
    [ -5.0/7.0, FractionType.new(25,35), true ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d}) != (#{f.to_s}) - " + (tf ? "true" : "false"),(d != f) == tf)
  end
end

def test_number_lt_fraction
  $tester.TestCase("Number < fraction")
  test_data = [
    [ 0, FractionType.new(0,1), false ],
    [ 0, FractionType.new(1,2), true ],
    [ 2.0/3.0, FractionType.new(-2,4), false ],
    [ 2.0/3.0, FractionType.new(16,24), false ],
    [ 1.0/3.0, FractionType.new(1,3), false ],
    [ -5.0/7.0, FractionType.new(25,35), true ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d}) < (#{f.to_s}) - " + (tf ? "true" : "false"),(d < f) == tf)
  end
end

def test_number_le_fraction
  $tester.TestCase("Number <= fraction")
  test_data = [
    [ 0, FractionType.new(0,1), true ],
    [ 0, FractionType.new(1,2), true ],
    [ 2.0/3.0, FractionType.new(-2,4), false ],
    [ 2.0/3.0, FractionType.new(16,24), true ],
    [ 1.0/3.0, FractionType.new(1,3), true ],
    [ -5.0/7.0, FractionType.new(25,35), true ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d}) <= (#{f.to_s}) - " + (tf ? "true" : "false"),(d <= f) == tf)
  end
end

def test_number_gt_fraction
  $tester.TestCase("Number > fraction")
  test_data = [
    [ 0, FractionType.new(0,1), false ],
    [ 0, FractionType.new(1,2), false ],
    [ 2.0/3.0, FractionType.new(-2,4), true ],
    [ 2.0/3.0, FractionType.new(16,24), false ],
    [ 1.0/3.0, FractionType.new(1,3), false ],
    [ -5.0/7.0, FractionType.new(25,35), false ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d}) > (#{f.to_s}) - " + (tf ? "true" : "false"),(d > f) == tf)
  end
end

def test_number_ge_fraction
  $tester.TestCase("Number >= fraction")
  test_data = [
    [ 0, FractionType.new(0,1), true ],
    [ 0, FractionType.new(1,2), false ],
    [ 2.0/3.0, FractionType.new(-2,4), true ],
    [ 2.0/3.0, FractionType.new(16,24), true ],
    [ 1.0/3.0, FractionType.new(1,3), true ],
    [ -5.0/7.0, FractionType.new(25,35), false ],
  ]
  test_data.each do |d,f,tf|
    $tester.Test("(#{d}) >= (#{f.to_s}) - " + (tf ? "true" : "false"),(d >= f) == tf)
  end
end

def test_fraction_plus_fraction
  $tester.TestCase("Fraction plus fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), FractionType.new(0,1) ],
    [ FractionType.new(0,1), FractionType.new(1,1), FractionType.new(1,1) ],
    [ FractionType.new(3,5), FractionType.new(-2,9), FractionType.new(17,45) ],
    [ FractionType.new(-2,8), FractionType.new(-6,8), FractionType.new(-1,1) ],
    [ FractionType.new(7,3), FractionType.new(10,7), FractionType.new(79,21) ],
  ];
  test_data.each do |f1,f2,result|
    f3 = f1 + f2
    $tester.Test("(#{f1.to_s}) + (#{f2.to_s})=(#{result.to_s})",f3.class == FractionType && f3 == result)
  end
end

def test_fraction_minus_fraction
  $tester.TestCase("Fraction minus fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), FractionType.new(0,1) ],
    [ FractionType.new(0,1), FractionType.new(1,1), FractionType.new(-1,1) ],
    [ FractionType.new(3,5), FractionType.new(-2,9), FractionType.new(37,45) ],
    [ FractionType.new(-2,8), FractionType.new(-6,8), FractionType.new(1,2) ],
    [ FractionType.new(7,3), FractionType.new(10,7), FractionType.new(19,21) ],
  ];
  test_data.each do |f1,f2,result|
    f3 = f1 - f2
    $tester.Test("(#{f1.to_s}) - (#{f2.to_s})=(#{result.to_s})",f3.class == FractionType && f3 == result)
  end
end

def test_fraction_times_fraction
  $tester.TestCase("Fraction times fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(0,1), FractionType.new(0,1) ],
    [ FractionType.new(0,1), FractionType.new(1,1), FractionType.new(0,1) ],
    [ FractionType.new(3,5), FractionType.new(-2,9), FractionType.new(-2,15) ],
    [ FractionType.new(-2,8), FractionType.new(-6,8), FractionType.new(3,16) ],
    [ FractionType.new(7,3), FractionType.new(10,7), FractionType.new(10,3) ],
  ];
  test_data.each do |f1,f2,result|
    f3 = f1 * f2
    $tester.Test("(#{f1.to_s}) * (#{f2.to_s})=(#{result.to_s})",f3.class == FractionType && f3 == result)
  end
end

def test_fraction_divided_by_fraction
  $tester.TestCase("Fraction divided by fraction")
  test_data = [
    [ FractionType.new(0,1), FractionType.new(1,1), FractionType.new(0,1) ],
    [ FractionType.new(3,5), FractionType.new(-2,9), FractionType.new(-27,10) ],
    [ FractionType.new(-2,8), FractionType.new(-6,8), FractionType.new(1,3) ],
    [ FractionType.new(7,3), FractionType.new(10,7), FractionType.new(49,30) ],
  ]
  test_data.each do |f1,f2,result|
    f3 = f1 / f2
    $tester.Test("(#{f1.to_s}) / (#{f2.to_s})=(#{result.to_s})",f3.class == FractionType && f3 == result)
  end
end

def test_fraction_power_fraction
  $tester.TestCase("Fraction to power of fraction")
  test_data = [
    [ FractionType.new(1,2), FractionType.new(1,2), FractionType.new(408,577) ],
    [ FractionType.new(5,2), FractionType.new(-2,5), FractionType.new(192,277) ],
    [ FractionType.new(2,3), FractionType.new(2,3), FractionType.new(1321,1731) ],
    [ FractionType.new(2,3), FractionType.new(-2,3), FractionType.new(1731,1321) ],
  ]
  test_data.each do |f1,f2,result|
    f3 = f1 ** f2
    $tester.Test("(#{f1.to_s}) ** (#{f2.to_s})=(#{result.to_s})",f3.class == FractionType && f3 == result)
  end
end

def test_fraction_plus_number
  $tester.TestCase("Fraction plus number")
  test_data = [
    [ FractionType.new(0,1), 0.0/1.0, FractionType.new(0,1) ],
    [ FractionType.new(0,1), 1.0/1.0, FractionType.new(1,1) ],
    [ FractionType.new(3,5), -2.0/9.0, FractionType.new(17,45) ],
    [ FractionType.new(-2,8), -6.0/8.0, FractionType.new(-1,1) ],
    [ FractionType.new(7,3), 10.0/7.0, FractionType.new(79,21) ],
  ];
  test_data.each do |f1,d,result|
    f2 = f1 + d
    $tester.Test("(#{f1.to_s}) + (#{d})=(#{result.to_s})",f2.class == FractionType && f2 == result)
  end
end

def test_fraction_minus_number
  $tester.TestCase("Fraction minus number")
  test_data = [
    [ FractionType.new(0,1), 0.0/1.0, FractionType.new(0,1) ],
    [ FractionType.new(0,1), 1.0/1.0, FractionType.new(-1,1) ],
    [ FractionType.new(3,5), -2.0/9.0, FractionType.new(37,45) ],
    [ FractionType.new(-2,8), -6.0/8.0, FractionType.new(1,2) ],
    [ FractionType.new(7,3), 10.0/7.0, FractionType.new(19,21) ],
  ]
  test_data.each do |f1,d,result|
    f2 = f1 - d
    $tester.Test("(#{f1.to_s}) - (#{d})=(#{result.to_s})",f2.class == FractionType && f2 == result)
  end
end

def test_fraction_times_number
  $tester.TestCase("Fraction times number")
  test_data = [
    [ FractionType.new(0,1), 0.0/1.0, FractionType.new(0,1) ],
    [ FractionType.new(0,1), 1.0/1.0, FractionType.new(0,1) ],
    [ FractionType.new(3,5), -2.0/9.0, FractionType.new(-2,15) ],
    [ FractionType.new(-2,8), -6.0/8.0, FractionType.new(3,16) ],
    [ FractionType.new(7,3), 10.0/7.0, FractionType.new(10,3) ],
  ]
  test_data.each do |f1,d,result|
    f2 = f1 * d
    $tester.Test("(#{f1.to_s}) * (#{d})=(#{result.to_s})",f2.class == FractionType && f2 == result)
  end
end

def test_fraction_divided_by_number
  $tester.TestCase("Fraction divided by number")
  test_data = [
    [ FractionType.new(0,1), 1.0/1.0, FractionType.new(0,1) ],
    [ FractionType.new(3,5), -2.0/9.0, FractionType.new(-27,10) ],
    [ FractionType.new(-2,8), -6.0/8.0, FractionType.new(1,3) ],
    [ FractionType.new(7,3), 10.0/7.0, FractionType.new(49,30) ],
  ]
  test_data.each do |f1,d,result|
    f2 = f1 / d
    $tester.Test("(#{f1.to_s}) / (#{d})=(#{result.to_s})",f2.class == FractionType && f2 == result)
  end
end

def test_fraction_power_number
  $tester.TestCase("Fraction to power of number")
  test_data = [
    [ FractionType.new(1,2), 1.0/2.0, FractionType.new(408,577) ],
    [ FractionType.new(5,2), -2.0/5.0, FractionType.new(192,277) ],
    [ FractionType.new(2,3), 2.0/3.0, FractionType.new(1321,1731) ],
    [ FractionType.new(2,3), -2.0/3.0, FractionType.new(1731,1321) ],
  ]
  test_data.each do |f1,d,result|
    f2 = f1 ** d
    $tester.Test("(#{f1.to_s}) ** (#{d})=(#{result.to_s})",f2.class == FractionType && f2 == result)
  end
end

def test_number_plus_fraction
  $tester.TestCase("Number plus fraction")
  test_data = [
    [  0.0/1.0, FractionType.new(0,1), 0.0/1.0 ],
    [  0.0/1.0, FractionType.new(1,1), 1.0/1.0 ],
    [  3.0/5.0, FractionType.new(-2,9), 17.0/45.0 ],
    [  -2.0/8.0, FractionType.new(-6,8), -1.0/1.0 ],
    [  7.0/3.0, FractionType.new(10,7), 79.0/21.0 ],
  ];
  test_data.each do |d,f,result|
    d2 = d + f
    $tester.Test("(#{d}) + (#{f})=(#{result})",d.class == Float && (d2 - result).abs() < Fraction.epsilon)
  end
end

def test_number_minus_fraction
  $tester.TestCase("Number minus fraction")
  test_data = [
    [  0.0/1.0, FractionType.new(0,1), 0.0/1.0 ],
    [  0.0/1.0, FractionType.new(1,1), -1.0/1.0 ],
    [  3.0/5.0, FractionType.new(-2,9), 37.0/45.0 ],
    [  -2.0/8.0, FractionType.new(-6,8), 1.0/2.0 ],
    [  7.0/3.0, FractionType.new(10,7), 19.0/21.0 ],
  ];
  test_data.each do |d,f,result|
    d2 = d - f
    $tester.Test("(#{d}) - (#{f})=(#{result})",d.class == Float && (d2 - result).abs() < Fraction.epsilon)
  end
end

def test_number_times_fraction
  $tester.TestCase("Number time fraction")
  test_data = [
    [  0.0/1.0, FractionType.new(0,1), 0.0/1.0 ],
    [  0.0/1.0, FractionType.new(1,1), 0.0/1.0 ],
    [  3.0/5.0, FractionType.new(-2,9), -2.0/15.0 ],
    [  -2.0/8.0, FractionType.new(-6,8), 3.0/16.0 ],
    [  7.0/3.0, FractionType.new(10,7), 10.0/3.0 ],
  ];
  test_data.each do |d,f,result|
    d2 = d * f
    $tester.Test("(#{d}) * (#{f})=(#{result})",d.class == Float && (d2 - result).abs() < Fraction.epsilon)
  end
end

def test_number_divided_by_fraction
  $tester.TestCase("Number times fraction")
  test_data = [
    [  0.0/1.0, FractionType.new(1,1), 0.0/1.0 ],
    [  3.0/5.0, FractionType.new(-2,9), -27.0/10.0 ],
    [  -2.0/8.0, FractionType.new(-6,8), 1.0/3.0 ],
    [  7.0/3.0, FractionType.new(10,7), 49.0/30.0 ],
  ];
  test_data.each do |d,f,result|
    d2 = d / f
    $tester.Test("(#{d}) / (#{f})=(#{result})",d.class == Float && (d2 - result).abs() < Fraction.epsilon)
  end
end

def test_number_power_fraction
  $tester.TestCase("Number to power of fraction")
  test_data = [
    [  1.0/2.0, FractionType.new(1,2), 408.0/577.0 ],
    [  5.0/2.0, FractionType.new(-2,5), 192.0/277.0 ],
    [  2.0/3.0, FractionType.new(2,3), 1321.0/1731.0 ],
    [  2.0/3.0, FractionType.new(-2,3), 1731.0/1321.0 ],
  ];
  test_data.each do |d,f,result|
    d2 = d ** f
    $tester.Test("(#{d}) ** (#{f})=(#{result})",d.class == Float && (d2 - result).abs() < Fraction.epsilon)
  end
end

def test_fraction_unm
  $tester.TestCase("Unary minus")
  test_data = [
      [ 0,1,0,1],
      [-2,3,2,3],
      [2,3,-2,3],
      [1,3,-1,3],
      [-5,7,5,7],
  ]
    test_data.each do |td|
      f1 = Fraction.new(td[0],td[1])
      $tester.Test("-(#{td[0]},#{td[1]}) = (#{td[2]},#{td[3]})",R(-f1,td[2],td[3]))
    end
end

def test_fraction_uplus
  $tester.TestCase("Unary plus")
  test_data = [
      [ 0,1],
      [-2,3],
      [2,3],
      [1,3],
      [-5,7],
  ]
    test_data.each do |td|
      f1 = Fraction.new(td[0],td[1])
      $tester.Test("+(#{td[0]},#{td[1]}) = (#{td[0]},#{td[1]})",R(+f1,td[0],td[1]))
    end
end

def test_fraction_random
  $tester.TestCase("Test Random floating point conversion")
  r=Random.new
  sign=1
  f=Fraction.new()
  1000.times do |i|
    value = sign*rand(1000)*r.rand
    f.set(value)
    $tester.Test("  %12.7f - (%20s)" % [value,f.to_s],(value - f.to_f).abs()<Fraction.epsilon)
    sign = -sign
  end
end

$tester.tests = [
  method(:test_gcd),
  method(:test_set_int),
  method(:test_set_int_int),
  method(:test_set_int_int_int),
  method(:tst_set_double),
  method(:test_set_string),
  method(:test_to_s),
  method(:test_fraction_eq_fraction),
  method(:test_fraction_ne_fraction),
  method(:test_fraction_lt_fraction),
  method(:test_fraction_le_fraction),
  method(:test_fraction_gt_fraction),
  method(:test_fraction_ge_fraction),
  method(:test_fraction_eq_number),
  method(:test_fraction_ne_number),
  method(:test_fraction_lt_number),
  method(:test_fraction_le_number),
  method(:test_fraction_gt_number),
  method(:test_fraction_ge_number),
  method(:test_number_eq_fraction),
  method(:test_number_ne_fraction),
  method(:test_number_lt_fraction),
  method(:test_number_le_fraction),
  method(:test_number_gt_fraction),
  method(:test_number_ge_fraction),
  method(:test_fraction_plus_fraction),
  method(:test_fraction_minus_fraction),
  method(:test_fraction_times_fraction),
  method(:test_fraction_divided_by_fraction),
  method(:test_fraction_power_fraction),
  method(:test_fraction_plus_number),
  method(:test_fraction_minus_number),
  method(:test_fraction_times_number),
  method(:test_fraction_divided_by_number),
  method(:test_fraction_power_number),
  method(:test_number_plus_fraction),
  method(:test_number_minus_fraction),
  method(:test_number_times_fraction),
  method(:test_number_divided_by_fraction),
  method(:test_number_power_fraction),
  method(:test_fraction_unm),
  method(:test_fraction_uplus),
  method(:test_fraction_random),
#  method(:),
#  method(:),
#  method(:),
#  method(:),
#  method(:),
#  method(:),
]
$tester.do_test(ARGV)
