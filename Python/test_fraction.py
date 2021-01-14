#!/usr/bin/python3
import test_harness
th = test_harness.TestHarness
import sys
import fraction

def test_gcd():
  th.TestCase("Greatest Common Divisor")
  gcd_test_data = ( ( 0,2,2),( 10,1,1),( 105,15,15),( 10,230,10),( 28,234,2), (872452914,78241452,6 ))
  for d in gcd_test_data:
    msg = "GCD({},{}) = {}".format(d[0],d[1],d[2])
    th.Test(msg,fraction.Fraction.gcd(d[0],d[1])==d[2])


def R(f,n,d):
  return f.numerator == n and f.denominator == d

def test_set_num():
  th.TestCase("Fraction set numerator")
  f = fraction.Fraction()
  set_num_data = ( ( 0,0,1 ), (1,1,1), (-2,-2,1), (-12,-12,1), (12,12,1) )
  for d in set_num_data:
    msg = "Set({}) = ({}/{})".format(d[0],d[1],d[2])
    f.set(d[0])
    th.Test(msg,R(f,d[1],d[2]))

def test_set_num_denom():
  th.TestCase("Fraction set numerator and denominator")
  f = fraction.Fraction()
  set_num_denom_data = ( ( 0,1,0,1 ), (1,1,1,1), (-2,3,-2,3),(2,-3,-2,3), (-2,-3,2,3) , (-12, 3, -4, 1), (100,200,1,2))
  for d in set_num_denom_data:
    msg = "Set({},{}) = ({}/{})".format(d[0],d[1],d[2],d[3])
    f.set(d[0],d[1])
    th.Test(msg,R(f,d[2],d[3]))

def test_set_mixed():
  th.TestCase("Fraction set mixed")
  f = fraction.Fraction()
  set_mixed_data = ( ( -10,2,3,-32,3 ), (0,-2,3,-2,3), (0,0,1,0,1), (0,2,3,2,3), (10,2,3,32,3))
  for d in set_mixed_data:
    msg = "Set({},{},{}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4])
    f.set(d[0],d[1],d[2])
    th.Test(msg,R(f,d[3],d[4]))

def test_set_float():
  th.TestCase("Fraction set numerator and denominator")
  f = fraction.Fraction()
  set_float_data = ((-12.25,-49,4), (-10.0,-10,1), (-1.0,-1,1), (-0.25,-1,4), (0.0,0,1), (0.25,1,4), (1.0,1,1),
        (10.0,10,1), ( 12.25,49,4),(0.3,3,10), (0.33,33,100), (0.33333333,1,3) )
  for d in set_float_data:
    msg = "Set({}) = ({}/{})".format(d[0],d[1],d[2])
    f.set(d[0])
    th.Test(msg,R(f,d[1],d[2]))

def test_set_string():
  th.TestCase("Fraction set numerator and denominator")
  f = fraction.Fraction()
  set_float_data = (("-12 1/4",-49,4), ("-10.0",-10,1), ("-1",-1,1), ("-1/4",-1,4), ("0.0",0,1), ("0.25",1,4), ("1.0",1,1),
        ("10/1",10,1), ( "12.25",49,4) )
  for d in set_float_data:
    msg = "Set(\"{}\") = ({}/{})".format(d[0],d[1],d[2])
    f.set(d[0])
    th.Test(msg,R(f,d[1],d[2]))

def test_addition():
  th.TestCase("Fraction addition")
  plus_data = ( (0,1,0,1,0,1) , (0,1,1,1,1,1),(3,5,-2,9,17,45),(-2,8,-6,8,-1,1), (7,3,10,7,79,21), (-5,7,25,35,0,1))
  for d in plus_data:
    msg = "({}/{}) + ({}/{}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4],d[5])
    f = fraction.Fraction(d[0],d[1]) + fraction.Fraction(d[2],d[3])
    th.Test(msg,R(f,d[4],d[5]))

def test_subtraction():
  th.TestCase("Fraction subtraction")
  minus_data = ( (0,1,0,1,0,1) , (0,1,1,1,-1,1),(3,5,-2,9,37,45),(-2,8,-6,8,1,2), (7,3,10,7,19,21), (-5,7,25,35,-10,7))
  for d in minus_data:
    msg = "({}/{}) - ({}/{}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4],d[5])
    f = fraction.Fraction(d[0],d[1]) - fraction.Fraction(d[2],d[3])
    th.Test(msg,R(f,d[4],d[5]))

def test_multiplication():
  th.TestCase("Fraction multiplication")
  mul_data = ( (0,1,0,1,0,1) , (0,1,1,1,0,1),(3,5,-2,9,-2,15),(-2,8,-6,8,3,16), (7,3,10,7,10,3), (-5,7,25,35,-25,49))
  for d in mul_data:
    msg = "({}/{}) * ({}/{}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4],d[5])
    f = fraction.Fraction(d[0],d[1]) * fraction.Fraction(d[2],d[3])
    th.Test(msg,R(f,d[4],d[5]))

def test_division():
  th.TestCase("Fraction division")
  div_data = ( (0,1,1,1,0,1),(3,5,-2,9,-27,10),(-2,8,-6,8,1,3), (7,3,10,7,49,30), (-5,7,25,35,-1,1))
  for d in div_data:
    msg = "({}/{}) / ({}/{}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4],d[5])
    f = fraction.Fraction(d[0],d[1]) / fraction.Fraction(d[2],d[3])
    th.Test(msg,R(f,d[4],d[5]))

true_or_false = ("false","true")
def test_equality():
  th.TestCase("Fraction equality")
  equal_data = ( ( 0,1,0,1,1), (0,1,1,2,0), (2,3,-2,4,0), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,0))
  for d in equal_data:
    msg = "({}/{}) == ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) == fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_inequality():
  th.TestCase("Fraction inequality")
  not_equal_data = ( ( 0,1,0,1,0), (0,1,1,2,1), (2,3,-2,4,1), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,1))
  for d in not_equal_data:
    msg = "({}/{}) != ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) != fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_less_than():
  th.TestCase("Fraction less than")
  less_than_data = ( ( 0,1,0,1,0), (0,1,1,2,1), (2,3,-2,4,0), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,1))
  for d in less_than_data:
    msg = "({}/{}) < ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) < fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_less_than_equal():
  th.TestCase("Fraction less than or equal")
  less_than_equal_data = ( ( 0,1,0,1,1), (0,1,1,2,1), (2,3,-2,4,0), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,1))
  for d in less_than_equal_data:
    msg = "({}/{}) == ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) <= fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_greater_than():
  th.TestCase("Fraction greater than")
  greater_than_data = ( ( 0,1,0,1,0), (0,1,1,2,0), (2,3,-2,4,1), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,0))
  for d in greater_than_data:
    msg = "({}/{}) > ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) > fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_greater_than_equal():
  th.TestCase("Fraction greater than or equal")
  greater_than_equal_data = ( ( 0,1,0,1,1), (0,1,1,2,0), (2,3,-2,4,1), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,0))
  for d in greater_than_equal_data:
    msg = "({}/{}) >= ({}/{}) -- {}".format(d[0],d[1],d[2],d[3],true_or_false[d[4]])
    rc = (fraction.Fraction(d[0],d[1]) >= fraction.Fraction(d[2],d[3])) == ( d[4] == 1)
    th.Test(msg,rc)

def test_round():
  th.TestCase("Fraction round")
  round_data = ( (3333,10000,10,3,10), (3333,10000,100,33,100),(639,5176,100,3,25), ( 2147483647,106197, 1000, 10110849,500))
  for d in round_data:
    msg = "({}/{}).round({}) = ({}/{})".format(d[0],d[1],d[2],d[3],d[4])
    f = fraction.Fraction(d[0],d[1]).round(d[2])
    th.Test(msg,R(f,d[3],d[4]))

tests = (
    test_gcd,
    test_set_num,
    test_set_num_denom,
    test_set_mixed,
    test_set_float,
    test_set_string,
    test_addition,
    test_subtraction,
    test_multiplication,
    test_division,
    test_equality,
    test_inequality,
    test_less_than,
    test_less_than_equal,
    test_greater_than,
    test_greater_than_equal,
    test_round
  )

th.RunTests(tests)

