#!/usr/bin/python3
import sys
import getopt


try:
  opts,test_numbers = getopt.getopt(sys.argv[1:],"hmn",["help","mixed","native"])
except getopt.GetoptError as err:
  print(err)
  usage()
  sys.exit(3)

use_mixed = False
use_native = False

for opt, value in opts:
  if opt in ["-h","--help"]:
    usage()
  elif opt in ["-m","--mixed"]:
    use_mixed = True
  elif opt in ["-n","--native"]:
    use_native = True

import test_harness
th = test_harness.TestHarness
if use_native:
  from fraction_native import Fraction,MixedFraction
else:
  from fraction import Fraction,MixedFraction

if use_mixed:
  FractionType = MixedFraction
else:
  FractionType = Fraction

ft = FractionType().__class__.__name__

def R(f,n,d):
  rc = f.numerator == n and f.denominator == d
  return rc

def test_gcd():
  th.TestCase("Greatest Common Divisor")
  test_data = ( ( 0,2,2),( 10,1,1),( 105,15,15),( 10,230,10),( 28,234,2), (872452914,78241452,6 ))
  for d in test_data:
    msg = "{}.GCD({},{}) = {}".format(ft,*d)
    th.Test(msg,FractionType.GCD(d[0],d[1])==d[2])


def test_new_zero_args():
  th.TestCase(ft+" new/new with zero arguemtns")
  f=FractionType()
  th.Test(ft+"() = (0/1)",R(f,0,1));

def test_new_int():
  th.TestCase(ft+" new/set with one integer argument")
  test_data = ( 0 , 1, -2, -12, 12 )
  for d in test_data:
    msg = "{}({}) = ({}/1)".format(ft,d,d)
    f = FractionType(d)
    th.Test(msg,R(f,d,1) and type(f) == FractionType)

def test_new_float():
  th.TestCase(ft+" new/set with one floating point argument")
  test_data = (
        (0.0,0,1),
        (-10.0,-10,1),
        (-0.25,-1,4),
        (0.25,1,4),
        (0.3,3,10),
        (0.33,33,100),
        (0.33333333333,1,3)
  )
  for d in test_data:
    msg = "{}({}) = ({}/{})".format(ft,*d)
    f = FractionType(d[0])
    th.Test(msg,R(f,d[1],d[2]) and type(f) == FractionType)

def test_new_string():
  th.TestCase(ft+" new with one string arguemtn")
  test_data = (
      ("-12 1/4",-49,4),
      ("-10.0",-10,1),
      ("-1",-1,1),
      ("-1/4",-1,4),
      ("0.0",0,1),
      ("0.25",1,4),
      ("1.0",1,1),
      ("10/1",10,1),
      ( "12.25",49,4)
  )
  for d in test_data:
    msg = "Set(\"{}\") = ({}/{})".format(*d)
    f = FractionType(d[0])
    th.Test(msg,R(f,d[1],d[2]) and type(f) == FractionType)

def test_new_fraction():
  th.TestCase(ft+" new with one fraction argument")
  test_data = (
      ( FractionType(0),0,1 ),
      ( FractionType(1),1,1),
      ( FractionType(-2),-2,1),
      ( FractionType("-1 1/2"),-3,2),
      ( FractionType(0.06),3,50),
  )
  for d in test_data:
    f = FractionType(d[0])
    msg = "{}({}/{}) = ({}/{})".format(ft,d[0].numerator,d[0].denominator,d[1],d[2])
    th.Test(msg,R(f,d[1],d[2]) and type(f) == FractionType)

def test_new_int_int():
  th.TestCase(ft+" new two integer arguments")
  test_data = (
      ( 0,1,0,1 ),
      (1,1,1,1),
      (-2,3,-2,3),
      (2,-3,-2,3),
      (-2,-3,2,3),
      (-12, 3, -4, 1),
      (100,200,1,2)
  )
  for d in test_data:
    msg = "{}({},{}) = ({}/{})".format(ft,*d)
    f = FractionType(d[0],d[1])
    th.Test(msg,R(f,d[2],d[3]) and type(f) == FractionType)

def test_new_int_int_int():
  th.TestCase(ft+" new/set with three integer arguments")
  test_data = (
      ( -10,2,3,-32,3 ),
      (0,-2,3,-2,3),
      (0,0,1,0,1),
      (0,2,3,2,3),
      (10,2,3,32,3),
      (-10,2,3,-32,3),
      (-10,-2,3,32,3),
      (-10,-2,-3,-32,3),
    )
  for d in test_data:
    msg = "{}({},{},{}) = ({}/{})".format(ft,*d)
    f = FractionType(d[0],d[1],d[2])
    th.Test(msg,R(f,d[3],d[4]) and type(f) == FractionType)

def test_str():
  test_data = None
  if FractionType == Fraction:
    test_data = (
      ( 0,1, "0"),
      ( 2,10, "1/5"),
      ( -16,3, "-16/3"),
      ( 9,150, "3/50"),
      ( -2,3, "-2/3"),
      ( -2,-3, "2/3"),
    )
  else:
    test_data = (
      ( 0,1, "0"),
      ( 2,10, "1/5"),
      ( -16,3, "-5 1/3"),
      ( 150,9, "16 2/3"),
      ( -2,3, "-2/3"),
      ( -2,-3, "2/3"),
    )

  for d in test_data:
    th.Test("str({}({},{})) = {}".format(ft,*d),str(FractionType(d[0],d[1])) == d[2])

def test_fraction_eq_fraction():
  th.TestCase(ft+" equal fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), True),
    ( FractionType(0,1), FractionType(1,2), False),
    ( FractionType(2,3), FractionType(-2,4), False),
    ( FractionType(2,3), FractionType(16,24), True),
    ( FractionType(1,3), FractionType(1,3), True),
    ( FractionType(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) == ({}) -- {}".format(*d)
    th.Test(msg,(d[0] == d[1]) == d[2])

def test_fraction_ne_fraction():
  th.TestCase("Fraction not equal fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), False),
    ( FractionType(0,1), FractionType(1,2), True),
    ( FractionType(2,3), FractionType(-2,4), True),
    ( FractionType(2,3), FractionType(16,24), False),
    ( FractionType(1,3), FractionType(1,3), False),
    ( FractionType(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) != ({}) -- {}".format(*d)
    th.Test(msg,(d[0] != d[1]) == d[2])

def test_fraction_lt_fraction():
  th.TestCase("Fraction less than fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), False),
    ( FractionType(0,1), FractionType(1,2), True),
    ( FractionType(2,3), FractionType(-2,4), False),
    ( FractionType(2,3), FractionType(16,24), False),
    ( FractionType(1,3), FractionType(1,3), False),
    ( FractionType(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) < ({}) -- {}".format(*d)
    th.Test(msg,(d[0] < d[1]) == d[2])

def test_fraction_le_fraction():
  th.TestCase("Fraction less than or equal fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), True),
    ( FractionType(0,1), FractionType(1,2), True),
    ( FractionType(2,3), FractionType(-2,4), False),
    ( FractionType(2,3), FractionType(16,24), True),
    ( FractionType(1,3), FractionType(1,3), True),
    ( FractionType(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) <= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] <= d[1]) == d[2])

def test_fraction_gt_fraction():
  th.TestCase("Fraction greater than fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), False),
    ( FractionType(0,1), FractionType(1,2), False),
    ( FractionType(2,3), FractionType(-2,4), True),
    ( FractionType(2,3), FractionType(16,24), False),
    ( FractionType(1,3), FractionType(1,3), False),
    ( FractionType(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) > ({}) -- {}".format(*d)
    th.Test(msg,(d[0] > d[1]) == d[2])

def test_fraction_ge_fraction():
  th.TestCase("Fraction greater than or equal fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), True),
    ( FractionType(0,1), FractionType(1,2), False),
    ( FractionType(2,3), FractionType(-2,4), True),
    ( FractionType(2,3), FractionType(16,24), True),
    ( FractionType(1,3), FractionType(1,3), True),
    ( FractionType(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) >= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] >= d[1]) == d[2])

def test_fraction_eq_number():
  th.TestCase("Fraction equal number")
  test_data = (
    ( FractionType(0,1), 0, True),
    ( FractionType(0,1), 1.0/2.0, False),
    ( FractionType(2,3), -1.0/2.0, False),
    ( FractionType(2,3), 2.0/3.0, True),
    ( FractionType(1,3), 1.0/3.0, True),
    ( FractionType(-5,7), 25.0/35.0, False),
  )
  for d in test_data:
    msg = "({}) == ({}) -- {}".format(*d)
    th.Test(msg,(d[0] == d[1]) == d[2])

def test_fraction_ne_number():
  th.TestCase("Fraction not equal number")
  test_data = (
    ( FractionType(0,1), 0, False),
    ( FractionType(0,1), 1.0/2.0, True),
    ( FractionType(2,3), -2.0/4.0, True),
    ( FractionType(2,3), 16.0/24.0, False),
    ( FractionType(1,3), 1.0/3.0, False),
    ( FractionType(-5,7), 25.0/35.0, True),
  )
  for d in test_data:
    msg = "({}) != ({}) -- {}".format(*d)
    th.Test(msg,(d[0] != d[1]) == d[2])

def test_fraction_lt_number():
  th.TestCase("Fraction less than number")
  test_data = (
    ( FractionType(0,1), 0, False),
    ( FractionType(0,1), 1.0/2.0, True),
    ( FractionType(2,3), -2.0/4.0, False),
    ( FractionType(2,3), 16.0/24.0, False),
    ( FractionType(1,3), 1.0/3.0, False),
    ( FractionType(-5,7), 25.0/35.0, True),
  )
  for d in test_data:
    msg = "({}) < ({}) -- {}".format(*d)
    th.Test(msg,(d[0] < d[1]) == d[2])

def test_fraction_le_number():
  th.TestCase("Fraction less than or equal number")
  test_data = (
    ( FractionType(0,1), 0, True),
    ( FractionType(0,1), 1.0/2.0, True),
    ( FractionType(2,3), -2.0/4.0, False),
    ( FractionType(2,3), 16.0/24.0, True),
    ( FractionType(1,3), 1.0/3.0, True),
    ( FractionType(-5,7), 25.0/35.0, True),
  )
  for d in test_data:
    msg = "({}) <= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] <= d[1]) == d[2])

def test_fraction_gt_number():
  th.TestCase("Fraction greater than number")
  test_data = (
    ( FractionType(0,1), 0, False),
    ( FractionType(0,1), 1.0/2.0, False),
    ( FractionType(2,3), -2.0/4.0, True),
    ( FractionType(2,3), 16.0/24.0, False),
    ( FractionType(1,3), 1.0/3.0, False),
    ( FractionType(-5,7), 25.0/35.0, False),
  )
  for d in test_data:
    msg = "({}) > ({}) -- {}".format(*d)
    th.Test(msg,(d[0] > d[1]) == d[2])

def test_fraction_ge_number():
  th.TestCase("Fraction greater than or equal number")
  test_data = (
    ( FractionType(0,1), 0, True),
    ( FractionType(0,1), 1.0/2.0, False),
    ( FractionType(2,3), -2.0/4.0, True),
    ( FractionType(2,3), 16.0/24.0, True),
    ( FractionType(1,3), 1.0/3.0, True),
    ( FractionType(-5,7), 25.0/35.0, False),
  )
  for d in test_data:
    msg = "({}) >= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] >= d[1]) == d[2])

def div_ints(n,d):
  return float(n)/float(d)

def test_number_eq_fraction():
  th.TestCase("Number equal fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), True),
    ( div_ints(0,1), FractionType(1,2), False),
    ( div_ints(2,3), FractionType(-2,4), False),
    ( div_ints(2,3), FractionType(16,24), True),
    ( div_ints(1,3), FractionType(1,3), True),
    ( div_ints(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) == ({}) -- {}".format(*d)
    th.Test(msg,(d[0] == d[1]) == d[2])

def test_number_ne_fraction():
  th.TestCase("Number not equal fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), False),
    ( div_ints(0,1), FractionType(1,2), True),
    ( div_ints(2,3), FractionType(-2,4), True),
    ( div_ints(2,3), FractionType(16,24), False),
    ( div_ints(1,3), FractionType(1,3), False),
    ( div_ints(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) != ({}) -- {}".format(*d)
    th.Test(msg,(d[0] != d[1]) == d[2])

def test_number_lt_fraction():
  th.TestCase("Number less than fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), False),
    ( div_ints(0,1), FractionType(1,2), True),
    ( div_ints(2,3), FractionType(-2,4), False),
    ( div_ints(2,3), FractionType(16,24), False),
    ( div_ints(1,3), FractionType(1,3), False),
    ( div_ints(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) < ({}) -- {}".format(*d)
    th.Test(msg,(d[0] < d[1]) == d[2])

def test_number_le_fraction():
  th.TestCase("Number less than or equal fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), True),
    ( div_ints(0,1), FractionType(1,2), True),
    ( div_ints(2,3), FractionType(-2,4), False),
    ( div_ints(2,3), FractionType(16,24), True),
    ( div_ints(1,3), FractionType(1,3), True),
    ( div_ints(-5,7), FractionType(25,35), True),
  )
  for d in test_data:
    msg = "({}) <= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] <= d[1]) == d[2])

def test_number_gt_fraction():
  th.TestCase("Number greater than fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), False),
    ( div_ints(0,1), FractionType(1,2), False),
    ( div_ints(2,3), FractionType(-2,4), True),
    ( div_ints(2,3), FractionType(16,24), False),
    ( div_ints(1,3), FractionType(1,3), False),
    ( div_ints(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) > ({}) -- {}".format(*d)
    th.Test(msg,(d[0] > d[1]) == d[2])

def test_number_ge_fraction():
  th.TestCase("Number greater than or equal fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), True),
    ( div_ints(0,1), FractionType(1,2), False),
    ( div_ints(2,3), FractionType(-2,4), True),
    ( div_ints(2,3), FractionType(16,24), True),
    ( div_ints(1,3), FractionType(1,3), True),
    ( div_ints(-5,7), FractionType(25,35), False),
  )
  for d in test_data:
    msg = "({}) >= ({}) -- {}".format(*d)
    th.Test(msg,(d[0] >= d[1]) == d[2])

def test_fraction_plus_fraction():
  th.TestCase("Fraction plus fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(1,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(17,45)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(-1,1)),
    ( FractionType(7,3), FractionType(10,7), FractionType(79,21)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(0,1)),
  )
  for d in test_data:
    msg = "({}) + ({}) = ({})".format(*d)
    f = d[0] + d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_minus_fraction():
  th.TestCase("Fraction minus fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(-1,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(37,45)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(1,2)),
    ( FractionType(7,3), FractionType(10,7), FractionType(19,21)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-10,7)),
  )
  for d in test_data:
    msg = "({}) - ({}) = ({})".format(*d)
    f = d[0] - d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_times_fraction():
  th.TestCase("Fraction times fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(0,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(-2,15)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(3,16)),
    ( FractionType(7,3), FractionType(10,7), FractionType(10,3)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-25,49)),
  )
  for d in test_data:
    msg = "({}) * ({}) = ({})".format(*d)
    f = d[0] * d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_divided_by_fraction():
  th.TestCase("Fraction divided by fraction")
  test_data = (
    ( FractionType(0,1), FractionType(1,1), FractionType(0,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(-27,10)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(1,3)),
    ( FractionType(7,3), FractionType(10,7), FractionType(49,30)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-1,1)),
  )
  for d in test_data:
    msg = "({}) / ({}) = ({})".format(*d)
    f = d[0] / d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_power_fraction():
  th.TestCase("Fraction to power of fraction")
  test_data = (
    ( FractionType(1,2), FractionType(1,2), FractionType(408,577) ),
    ( FractionType(5,2), FractionType(-2,5), FractionType(192,277) ),
    ( FractionType(2,3), FractionType(2,3), FractionType(1321,1731) ),
    ( FractionType(2,3), FractionType(-2,3), FractionType(1731,1321) ),
  )
  for d in test_data:
    msg = "({}) ** ({}) = ({})".format(*d)
    f = d[0] ** d[1]
    th.Test(msg,f == d[2] and isinstance(f,FractionType))

def test_fraction_plus_number():
  th.TestCase("Fraction plus number")
  test_data = (
    ( FractionType(0,1), div_ints(0,1), FractionType(0,1)),
    ( FractionType(0,1), div_ints(1,1), FractionType(1,1)),
    ( FractionType(3,5), div_ints(-2,9), FractionType(17,45)),
    ( FractionType(-2,8), div_ints(-6,8), FractionType(-1,1)),
    ( FractionType(7,3), div_ints(10,7), FractionType(79,21)),
    ( FractionType(-5,7), div_ints(25,35), FractionType(0,1)),
  )
  for d in test_data:
    msg = "({}) + ({}) = ({})".format(*d)
    f = d[0] + d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_minus_number():
  th.TestCase("Fraction minus number")
  test_data = (
    ( FractionType(0,1), div_ints(0,1), FractionType(0,1)),
    ( FractionType(0,1), div_ints(1,1), FractionType(-1,1)),
    ( FractionType(3,5), div_ints(-2,9), FractionType(37,45)),
    ( FractionType(-2,8), div_ints(-6,8), FractionType(1,2)),
    ( FractionType(7,3), div_ints(10,7), FractionType(19,21)),
    ( FractionType(-5,7), div_ints(25,35), FractionType(-10,7)),
  )
  for d in test_data:
    msg = "({}) - ({}) = ({})".format(*d)
    f = d[0] - d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_times_number():
  th.TestCase("Fraction times number")
  test_data = (
    ( FractionType(0,1), div_ints(0,1), FractionType(0,1)),
    ( FractionType(0,1), div_ints(1,1), FractionType(0,1)),
    ( FractionType(3,5), div_ints(-2,9), FractionType(-2,15)),
    ( FractionType(-2,8), div_ints(-6,8), FractionType(3,16)),
    ( FractionType(7,3), div_ints(10,7), FractionType(10,3)),
    ( FractionType(-5,7), div_ints(25,35), FractionType(-25,49)),
  )
  for d in test_data:
    msg = "({}) * ({}) = ({})".format(*d)
    f = d[0] * d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_divided_by_number():
  th.TestCase("Fraction divided by number")
  test_data = (
    ( FractionType(0,1), div_ints(1,1), FractionType(0,1)),
    ( FractionType(3,5), div_ints(-2,9), FractionType(-27,10)),
    ( FractionType(-2,8), div_ints(-6,8), FractionType(1,3)),
    ( FractionType(7,3), div_ints(10,7), FractionType(49,30)),
    ( FractionType(-5,7), div_ints(25,35), FractionType(-1,1)),
  )
  for d in test_data:
    msg = "({}) / ({}) = ({})".format(*d)
    f = d[0] / d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_power_number():
  th.TestCase("Fraction to power of number")
  test_data = (
    ( FractionType(1,2), (1/2), FractionType(408,577) ),
    ( FractionType(5,2), (-2/5), FractionType(192,277) ),
    ( FractionType(2,3), (2/3), FractionType(1321,1731) ),
    ( FractionType(2,3), (-2/3), FractionType(1731,1321) ),
  )
  for d in test_data:
    msg = "({}) ** ({}) = ({})".format(*d)
    f = d[0] ** d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_number_plus_fraction():
  th.TestCase("Number plus fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), div_ints(0,1)),
    ( div_ints(0,1), FractionType(1,1), div_ints(1,1)),
    ( div_ints(3,5), FractionType(-2,9), div_ints(17,45)),
    ( div_ints(-2,8), FractionType(-6,8), div_ints(-1,1)),
    ( div_ints(7,3), FractionType(10,7), div_ints(79,21)),
    ( div_ints(-5,7), FractionType(25,35), div_ints(0,1)),
  )
  for d in test_data:
    msg = "({}) + ({}) = ({})".format(*d)
    r = d[0] + d[1]
    th.Test(msg,abs(r - d[2]) < 5e-6  and type(r) == float)

def test_number_minus_fraction():
  th.TestCase("Number minus fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), div_ints(0,1)),
    ( div_ints(0,1), FractionType(1,1), div_ints(-1,1)),
    ( div_ints(3,5), FractionType(-2,9), div_ints(37,45)),
    ( div_ints(-2,8), FractionType(-6,8), div_ints(1,2)),
    ( div_ints(7,3), FractionType(10,7), div_ints(19,21)),
    ( div_ints(-5,7), FractionType(25,35), div_ints(-10,7)),
  )
  for d in test_data:
    msg = "({}) - ({}) = ({})".format(*d)
    r = d[0] - d[1]
    th.Test(msg,abs(r - d[2]) < 5e-6  and type(r) == float)

def test_number_times_fraction():
  th.TestCase("Number times fraction")
  test_data = (
    ( div_ints(0,1), FractionType(0,1), div_ints(0,1)),
    ( div_ints(0,1), FractionType(1,1), div_ints(0,1)),
    ( div_ints(3,5), FractionType(-2,9), div_ints(-2,15)),
    ( div_ints(-2,8), FractionType(-6,8), div_ints(3,16)),
    ( div_ints(7,3), FractionType(10,7), div_ints(10,3)),
    ( div_ints(-5,7), FractionType(25,35), div_ints(-25,49)),
  )
  for d in test_data:
    msg = "({}) * ({}) = ({})".format(*d)
    r = d[0] * d[1]
    th.Test(msg,abs(r - d[2]) < 5e-6  and type(r) == float)

def test_number_divided_by_fraction():
  th.TestCase("Number divided by fraction")
  test_data = (
    ( div_ints(0,1), FractionType(1,1), div_ints(0,1)),
    ( div_ints(3,5), FractionType(-2,9), div_ints(-27,10)),
    ( div_ints(-2,8), FractionType(-6,8), div_ints(1,3)),
    ( div_ints(7,3), FractionType(10,7), div_ints(49,30)),
    ( div_ints(-5,7), FractionType(25,35), div_ints(-1,1)),
  )
  for d in test_data:
    msg = "({}) / ({}) = ({})".format(*d)
    r = d[0] / d[1]
    th.Test(msg,abs(r - d[2]) < 5e-6  and type(r) == float)

def test_number_power_fraction():
  th.TestCase("Number to power of fraction")
  test_data = (
    ( (1/2), FractionType(1,2), (408/577) ),
    ( (5/2), FractionType(-2,5), (192/277) ),
    ( (2/3), FractionType(2,3), (1321/1731) ),
    ( (2/3), FractionType(-2,3), (1731/1321) ),
  )
  for d in test_data:
    msg = "({}) ** ({}) = ({})".format(*d)
    r = d[0] ** d[1]
    th.Test(msg,abs(r - d[2]) < 5e-6 and type(r) == float)

def test_fraction_inplace_add_fraction():
  th.TestCase("Fraction inplace add fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(1,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(17,45)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(-1,1)),
    ( FractionType(7,3), FractionType(10,7), FractionType(79,21)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(0,1)),
  )
  for d in test_data:
    msg = "({}) += ({})  ({})".format(*d)
    f = FractionType(d[0])
    f += d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_sub_fraction():
  th.TestCase("Fraction inplace subtract fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(-1,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(37,45)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(1,2)),
    ( FractionType(7,3), FractionType(10,7), FractionType(19,21)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-10,7)),
  )
  for d in test_data:
    msg = "({}) -= ({})  ({})".format(*d)
    f = FractionType(d[0])
    f -= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_mul_fraction():
  th.TestCase("Fraction inplace multiply fraction")
  test_data = (
    ( FractionType(0,1), FractionType(0,1), FractionType(0,1)),
    ( FractionType(0,1), FractionType(1,1), FractionType(0,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(-2,15)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(3,16)),
    ( FractionType(7,3), FractionType(10,7), FractionType(10,3)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-25,49)),
  )
  for d in test_data:
    msg = "({}) * ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f *= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_div_fraction():
  th.TestCase("Fraction inplace divide fraction")
  test_data = (
    ( FractionType(0,1), FractionType(1,1), FractionType(0,1)),
    ( FractionType(3,5), FractionType(-2,9), FractionType(-27,10)),
    ( FractionType(-2,8), FractionType(-6,8), FractionType(1,3)),
    ( FractionType(7,3), FractionType(10,7), FractionType(49,30)),
    ( FractionType(-5,7), FractionType(25,35), FractionType(-1,1)),
  )
  for d in test_data:
    msg = "({}) / ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f /= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_pow_fraction():
  th.TestCase("Fraction inplace power to fraction")
  test_data = (
    ( FractionType(1,2), FractionType(1,2), FractionType(408,577) ),
    ( FractionType(5,2), FractionType(-2,5), FractionType(192,277) ),
    ( FractionType(2,3), FractionType(2,3), FractionType(1321,1731) ),
    ( FractionType(2,3), FractionType(-2,3), FractionType(1731,1321) ),
  )
  for d in test_data:
    msg = "({}) ** ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f **= d[1]
    th.Test(msg,f == d[2] and isinstance(f,FractionType))

def test_fraction_inplace_add_number():
  th.TestCase("Fraction inplace add number")
  test_data = (
    ( FractionType(0,1), (0/1), FractionType(0,1)),
    ( FractionType(0,1), (1/1), FractionType(1,1)),
    ( FractionType(3,5), (-2/9), FractionType(17,45)),
    ( FractionType(-2,8), (-6/8), FractionType(-1,1)),
    ( FractionType(7,3), (10/7), FractionType(79,21)),
    ( FractionType(-5,7), (25/35), FractionType(0,1)),
  )
  for d in test_data:
    msg = "({}) += ({})  ({})".format(*d)
    f = FractionType(d[0])
    f += d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_sub_number():
  th.TestCase("Fraction inplace subtract number")
  test_data = (
    ( FractionType(0,1), (0/1), FractionType(0,1)),
    ( FractionType(0,1), (1/1), FractionType(-1,1)),
    ( FractionType(3,5), (-2/9), FractionType(37,45)),
    ( FractionType(-2,8), (-6/8), FractionType(1,2)),
    ( FractionType(7,3), (10/7), FractionType(19,21)),
    ( FractionType(-5,7), (25/35), FractionType(-10,7)),
  )
  for d in test_data:
    msg = "({}) -= ({})  ({})".format(*d)
    f = FractionType(d[0])
    f -= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_mul_number():
  th.TestCase("Fraction inplace multiply number")
  test_data = (
    ( FractionType(0,1), (0/1), FractionType(0,1)),
    ( FractionType(0,1), (1/1), FractionType(0,1)),
    ( FractionType(3,5), (-2/9), FractionType(-2,15)),
    ( FractionType(-2,8), (-6/8), FractionType(3,16)),
    ( FractionType(7,3), (10/7), FractionType(10,3)),
    ( FractionType(-5,7), (25/35), FractionType(-25,49)),
  )
  for d in test_data:
    msg = "({}) * ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f *= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_div_number():
  th.TestCase("Fraction inplace divide number")
  test_data = (
    ( FractionType(0,1), (1/1), FractionType(0,1)),
    ( FractionType(3,5), (-2/9), FractionType(-27,10)),
    ( FractionType(-2,8), (-6/8), FractionType(1,3)),
    ( FractionType(7,3), (10/7), FractionType(49,30)),
    ( FractionType(-5,7), (25/35), FractionType(-1,1)),
  )
  for d in test_data:
    msg = "({}) / ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f /= d[1]
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_fraction_inplace_pow_number():
  th.TestCase("Fraction inplace power to number")
  test_data = (
    ( FractionType(1,2), (1/2), FractionType(408,577) ),
    ( FractionType(5,2), (-2/5), FractionType(192,277) ),
    ( FractionType(2,3), (2/3), FractionType(1321,1731) ),
    ( FractionType(2,3), (-2/3), FractionType(1731,1321) ),
  )
  for d in test_data:
    msg = "({}) ** ({}) = ({})".format(*d)
    f = FractionType(d[0])
    f **= d[1]
    th.Test(msg,f == d[2] and isinstance(f,FractionType))

def test_round():
  th.TestCase("Fraction round")
  round_data = (
      ( FractionType(3333,10000),10,FractionType(3,10)),
      ( FractionType(3333,10000),100,FractionType(33,100)),
      ( FractionType(639,5176),100,FractionType(3,25)),
      ( FractionType(2147483647,106197), 1000, FractionType(10110849,500))
  )
  for d in round_data:
    msg = "round({},{}) = ({})".format(*d)
    f = round(d[0],d[1])
    th.Test(msg,f == d[2] and type(f) == FractionType)

def test_abs():
  th.TestCase("Fraction abs")
  round_data = (
      ( FractionType(3,10),FractionType(3,10)),
      ( FractionType(-3,10),FractionType(3,10)),
      ( FractionType(-15,2),FractionType(15,2)),
      ( FractionType(-7,22),FractionType(7,22)),
      ( FractionType(3,22),FractionType(3,22)),
  )
  for d in round_data:
    msg = "abs({}) = ({})".format(*d)
    f=abs(d[0])
    print(d[0]," ",f)
    th.Test(msg,f == d[1] and type(f) == FractionType)

tests = (
    test_gcd,
    test_new_zero_args,
    test_new_int,
    test_new_float,
    test_new_string,
    test_new_fraction,
    test_new_int_int,
    test_new_int_int_int,
    test_str,
    test_fraction_eq_fraction,
    test_fraction_ne_fraction,
    test_fraction_lt_fraction,
    test_fraction_le_fraction,
    test_fraction_gt_fraction,
    test_fraction_ge_fraction,
    test_fraction_eq_number,
    test_fraction_ne_number,
    test_fraction_lt_number,
    test_fraction_le_number,
    test_fraction_gt_number,
    test_fraction_ge_number,
    test_number_eq_fraction,
    test_number_ne_fraction,
    test_number_lt_fraction,
    test_number_le_fraction,
    test_number_gt_fraction,
    test_number_ge_fraction,
    test_fraction_plus_fraction,
    test_fraction_minus_fraction,
    test_fraction_times_fraction,
    test_fraction_divided_by_fraction,
    test_fraction_power_fraction,
    test_fraction_plus_number,
    test_fraction_minus_number,
    test_fraction_times_number,
    test_fraction_divided_by_number,
    test_fraction_power_number,
    test_number_plus_fraction,
    test_number_minus_fraction,
    test_number_times_fraction,
    test_number_divided_by_fraction,
    test_number_power_fraction,
    test_fraction_inplace_add_fraction,
    test_fraction_inplace_sub_fraction,
    test_fraction_inplace_mul_fraction,
    test_fraction_inplace_div_fraction,
#    test_fraction_inplace_pow_fraction,
    test_fraction_inplace_add_number,
    test_fraction_inplace_sub_number,
    test_fraction_inplace_mul_number,
    test_fraction_inplace_div_number,
#    test_fraction_inplace_pow_number,
    test_round,
    test_abs
  )

th.RunTests(tests,test_numbers)
