require_relative 'fraction'
require_relative "test_harness"

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
  gcd_data = [ [ 0,2,2],[ 10,1,1],[ 105,15,15],[ 10,230,10],[ 28,234,2], [872452914,78241452,6 ],
      [17179869183,68719476736,1] ]

  $tester.TestCase("Greatest common denominator")
  gcd_data.each do |n,d,rn|
    $tester.Test("GCD(#{n},#{d}) = #{rn}",Fraction.gcd(n,d)==rn)
  end
end

def test_set_int
  $tester.TestCase("Fraction.new(int)")
  set_int_data = [ [ 10, 10] , [-12, -12], [0,0] ]
  set_int_data.each do |n,rn|
    $tester.Test("Fraction(#{n}) = (#{rn},1)",R(Fraction.new(n),rn,1))
  end
end

def test_set_int_int
  $tester.TestCase("Fraction.new(int,int)")
  set_int_int_data = [ [ 0,1,0,1 ], [1,1,1,1], [-2,3,-2,3], [2,-3,-2,3], [-2,-3,2,3],
    [17179869183,68719476736,17179869183 ,68719476736],[68719476736,17179869183, 68719476736,17179869183] ,
    [-17179869183,68719476736,-17179869183 ,68719476736],[-68719476736,17179869183, -68719476736,17179869183]
  ]
  set_int_int_data.each do |n,d,rn,rd|
    $tester.Test("Fraction(#{n},#{d}) = (#{rn},#{rd})",R(Fraction.new(n,d),rn,rd))
  end
end

def test_set_int_int_int
  $tester.TestCase("Fraction.new(int,int,int)")
  set_int_int_int_data=[ [ -10,2,3,-32,3 ], [0,-2,3,-2,3], [0,0,1,0,1], [0,2,3,2,3], [10,2,3,32,3]]
  set_int_int_int_data.each do |w,n,d,rn,rd|
    $tester.Test("Fraction(#{w},#{n},#{d}) = (#{rn},#{rd})",R(Fraction.new(w,n,d),rn,rd))
  end
end

def tst_set_double
  $tester.TestCase("Fraction.new(double)")
  set_double_data=[ [ -10.66666667,-32,3 ], [-0.66666667,-2,3], [0.0,0,1], [0.66666667,2,3], [10.66666667,32,3]]
  set_double_data.each do |d,rn,rd|
    $tester.Test("Fraction(#{d}) = (#{rn},#{rd})",R(Fraction.new(d),rn,rd))
  end
end

def test_set_string
  $tester.TestCase("Fraction.new(string)")
  set_double_data=[ [ "-10.66666667",-32,3 ], ["-0.66666667",-2,3], ["0.0",0,1],
                      ["0.66666667",2,3], ["10.66666667",32,3],
                    [ "-10 2/3" , -32, 3 ] ]
  set_double_data.each do |d,rn,rd|
    $tester.Test("Fraction(#{d}) = (#{rn},#{rd})",R(Fraction.new(d),rn,rd))
  end
end

$tester.tests = [
  method(:test_gcd),
  method(:test_set_int),
  method(:test_set_int_int),
  method(:test_set_int_int_int),
  method(:tst_set_double),
  method(:test_set_string),
#  method(:),
#  method(:),
]
$tester.do_test(ARGV)
