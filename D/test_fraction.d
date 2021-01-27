import std.stdio;
import core.stdc.time;
import std.math;
import std.conv;
import std.string;
import std.random;
import Fraction;
import TestHarness;

version (MIXED) {
  alias FractionType = MixedFraction;
  string ftname = "MixedFraction";
} else {
  alias FractionType = Fraction;
  string ftname = "Fraction";
}

bool R(FractionType f,fraction_numerator_denominator_t n,fraction_numerator_denominator_t d)
{
  return f.numerator == n && f.denominator == d;
}

TestHarness th;

void test_gcd()
{
  int[][] test_data =
  [
    [ 0,2,2],
    [10,1,1],
    [105,15,15],
    [10,230,10],
    [28,234,2],
    [872452914,78241452,6]
  ];
  th.TestCase("Greatest common denominator");
  foreach(td; test_data) {
    th.Test(format("%s.GCD(%s/%s)==%s",ftname,td[0],td[1],td[2]),FractionType.gcd(td[0],td[1]) == td[2]);
  }
}

void test_new_zero_args()
{
  th.TestCase("new zero args");
  FractionType f=new FractionType();
  th.Test(format("%s() = (0/1)",ftname),R(f,0,1) && is(typeof(f) == FractionType));
}

void test_new_one_integer_arg() {
  long[] test_data = [ 0 , -1, 10, 11, -13 ];

  th.TestCase("New one integer arg");
  foreach (i ; test_data) {
    auto f=new FractionType(i);

    th.Test(format("%s(%d) = %d/1",ftname,i,i),R(f,i,1) && is(typeof(f) == FractionType));
  }
}

void test_new_two_integer_args() {
  long[][] test_data =
  [
    [0,1,0,1],
    [1,-3,-1,3],
    [-1,-3,1,3],
    [-6,-8,3,4],
    [2,4,1,2],
  ];

  th.TestCase("New two integer args");
  foreach (td; test_data) {
    auto f=new FractionType(td[0],td[1]);

    th.Test(format("%s(%s,%s) = %s/%s",ftname,td[0],td[1],td[2],td[3]),R(f,td[2],td[3]) && is(typeof(f) == FractionType));
  }
}

void test_new_three_integers() {
  int[][] test_data =
  [
    [-10,2,3,-32,3],
    [0,-1,3,-1,3],
    [0,0,1,0,1],
    [0,1,3,1,3],
    [10,2,3,32,3],
  ];

  th.TestCase("New three integers");

  foreach (td ; test_data) {
    auto f=new FractionType(td[0],td[1],td[2]);
    th.Test(format("%s(%s,%s,%s) = %s/%s",ftname,td[0],td[1],
          td[2],td[3],td[4]),R(f,td[3],td[4]) && is(typeof(f) == FractionType));
  }
}

struct DII {
  double dbl;
  int n;
  int d;
}
void test_new_double()
{
  DII [] test_data = [
    {0.0 , 0, 1 },
    {1.0 , 1, 1 },
    {12.25 , 49, 4 },
    {-2.5 , -5, 2 },
    {-0.06 , -3, 50 },
    {0.3 , 3, 10 },
    {0.33 , 33, 100 },
    {0.33333333 , 1, 3 },
  ];
  th.TestCase("New single double arg");

  foreach( td; test_data) {
    auto f = new FractionType(td.dbl);
    th.Test(format("%s(%s) = %s/%s",ftname,td.dbl,td.n,td.d), R(f,td.n,td.d) && is(typeof(f) == FractionType));
  }
}

struct SII {
  string s;
  int n;
  int d;
}
void test_new_string()
{
  th.TestCase("New with one string arguemtn");
  SII [] test_data = [
    {  "-12 1/4",-49,4},
    {  "12 -1/4",-49,4},
    {  "-12 -1/4",49,4},
    {  "12 -1/-4",49,4},
    {  "-12 -1/-4",-49,4},
    {  "-10.0",-10,1},
    {  "-1",-1,1},
    {  "-1/4",-1,4},
    {  "0.0",0,1},
    {  "0.25",1,4},
    {  "1.0",1,1},
    {  "10/1",10,1},
    {   "12.25",49,4 },
  ];
  foreach( td; test_data) {
    auto f = new FractionType(td.s);
    th.Test(format("%s(\"%s\") = (%d/%d)",ftname,td.s,td.n,td.d),R(f,td.n,td.d) && is(typeof(f) == FractionType));
  }
}

struct IIS {
  int n;
  int d;
  string s;
}

void test_fraction_to_string()
{
  version (MIXED) {
    IIS [] test_data = [
      { -503,50,"-10 3/50" },
      { -3,50, "-3/50"},
      { 0,1,"0" },
      { 3,50, "3/50"  },
      { 503,50,"10 3/50"  },
    ];
  } else {
    IIS [] test_data = [
      { -503,50,"-503/50" },
      { -3,50, "-3/50"},
      { 0,1,"0" },
      { 3,50, "3/50"  },
      { 503,50,"503/50"  },
    ];
  }
  th.TestCase("Fraction toString");

  foreach(td; test_data) {
    auto f = new FractionType(td.n,td.d);
    writeln(is(typeof(f)==MixedFraction));
    th.Test(format("%s(%s,%s).toString() = \"%s\"",ftname,td.n,td.d,td.s),f.toString() == td.s);
  }
}


struct FFB {
  FractionType f1;
  FractionType f2;
  bool expected;
}

void test_fraction_equal_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),true},
    { new FractionType(0,1),new FractionType(1,2),false},
    { new FractionType(2,3),new FractionType(-2,3),false},
    { new FractionType(2,3),new FractionType(2,3),true},
    { new FractionType(1,3),new FractionType(1,3),true},
    { new FractionType(-5,7),new FractionType(5,7),false},
  ];
  th.TestCase("Fraction equal Fraction");

  foreach (td; test_data) {
    th.Test(format(" (%s) == (%s) - %s",td.f1,td.f2,td.expected),(td.f1 == td.f2) == td.expected);
  }
}

void test_fraction_not_equal_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),false},
    { new FractionType(0,1),new FractionType(1,2),true},
    { new FractionType(2,3),new FractionType(-2,3),true},
    { new FractionType(2,3),new FractionType(2,3),false},
    { new FractionType(1,3),new FractionType(1,3),false},
    { new FractionType(-5,7),new FractionType(5,7),true},
  ];
  th.TestCase("Fraction not equal Fraction");
  foreach (td; test_data) {
    th.Test(format(" (%s) != (%s) - %s",td.f1,td.f2,td.expected),(td.f1 != td.f2) == td.expected);
  }

}

void test_fraction_less_than_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),false},
    { new FractionType(0,1),new FractionType(1,2),true},
    { new FractionType(2,3),new FractionType(-2,3),false},
    { new FractionType(2,3),new FractionType(2,3),false},
    { new FractionType(1,3),new FractionType(1,3),false},
    { new FractionType(-5,7),new FractionType(5,7),true},
  ];
  th.TestCase("Fraction less than fraction");
  foreach (td; test_data) {
    th.Test(format(" (%s) < (%s) - %s",td.f1,td.f2,td.expected),(td.f1 < td.f2) == td.expected);
  }
}

void test_fraction_less_than_equal_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),true},
    { new FractionType(0,1),new FractionType(1,2),true},
    { new FractionType(2,3),new FractionType(-2,3),false},
    { new FractionType(2,3),new FractionType(2,3),true},
    { new FractionType(1,3),new FractionType(1,3),true},
    { new FractionType(-5,7),new FractionType(5,7),true},
  ];
  th.TestCase("Fraction less than or equal fraction");
  foreach (td; test_data) {
    th.Test(format(" (%s) <= (%s) - %s",td.f1,td.f2,td.expected),(td.f1 <= td.f2) == td.expected);
  }
}

void test_fraction_greater_than_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),false},
    { new FractionType(0,1),new FractionType(1,2),false},
    { new FractionType(2,3),new FractionType(-2,3),true},
    { new FractionType(2,3),new FractionType(2,3),false},
    { new FractionType(1,3),new FractionType(1,3),false},
    { new FractionType(-5,7),new FractionType(5,7),false},
  ];
  th.TestCase("Fraction greater than fraction");
  foreach (td; test_data) {
    th.Test(format(" (%s) > (%s) - %s",td.f1,td.f2,td.expected),(td.f1 > td.f2) == td.expected);
  }
}

void test_fraction_greater_than_equal_fraction()
{
  FFB [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),true},
    { new FractionType(0,1),new FractionType(1,2),false},
    { new FractionType(2,3),new FractionType(-2,3),true},
    { new FractionType(2,3),new FractionType(2,3),true},
    { new FractionType(1,3),new FractionType(1,3),true},
    { new FractionType(-5,7),new FractionType(5,7),false},
  ];
  th.TestCase("Fracton greater than or equal fraction");
  foreach (td; test_data) {
    th.Test(format(" (%s) >= (%s) - %s",td.f1,td.f2,td.expected),(td.f1 >= td.f2) == td.expected);
  }
}

struct FD
{
  FractionType f;
  double d;
}
void test_cast_to_double()
{
  th.TestCase("Fraction cast to double");
  FD [] test_data = [
    { new FractionType(0,1), 0.0 },
    { new FractionType(1,1), 1.0 },
    { new FractionType(-1,1), -1.0 },
    { new FractionType(-3,50), -0.06 },
    { new FractionType(49,4), 12.25 },
  ];

  foreach (td; test_data) {
    th.Test(format("(%s) = %s",td.f,td.d),fabs(cast(double)td.f - td.d) < FractionType.epsilon);
  }
}

struct FDB {
  FractionType f;
  double d;
  bool expected;
}
void test_fraction_equal_to_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),true},
    {new FractionType(0,1),(1.0/2),false},
    {new FractionType(2,3),(-2.0/3),false},
    {new FractionType(2,3),(2.0/3),true},
    {new FractionType(1,3),(1.0/3),true},
    {new FractionType(-5,7),(5.0/7),false},
  ];
  th.TestCase("Fraction equal to double");

  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f==td.d) == td.expected);
  }
}

void test_fraction_not_equal_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),false},
    {new FractionType(0,1),(1.0/2),true},
    {new FractionType(2,3),(-2.0/3),true},
    {new FractionType(2,3),(2.0/3),false},
    {new FractionType(1,3),(1.0/3),false},
    {new FractionType(-5,7),(5.0/7),true},
  ];
  th.TestCase("Fraction not equal double");

  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f!=td.d) == td.expected);
  }
}

void test_fraction_less_than_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),false},
    {new FractionType(0,1),(1.0/2),true},
    {new FractionType(2,3),(-2.0/3),false},
    {new FractionType(2,3),(2.0/3),false},
    {new FractionType(1,3),(1.0/3),false},
    {new FractionType(-5,7),(5.0/7),true},
  ];
  th.TestCase("Fraction less than double");

  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f<td.d) == td.expected);
  }
}

void test_fraction_less_than_equal_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),true},
    {new FractionType(0,1),(1.0/2),true},
    {new FractionType(2,3),(-2.0/3),false},
    {new FractionType(2,3),(2.0/3),true},
    {new FractionType(1,3),(1.0/3),true},
    {new FractionType(-5,7),(5.0/7),true},
  ];
  th.TestCase("Fraction less than or equal to double");

  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f<=td.d) == td.expected);
  }
}

void test_fraction_greater_than_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),false},
    {new FractionType(0,1),(1.0/2),false},
    {new FractionType(2,3),(-2.0/3),true},
    {new FractionType(2,3),(2.0/3),false},
    {new FractionType(1,3),(1.0/3),false},
    {new FractionType(-5,7),(5.0/7),false},
  ];
  th.TestCase("Fraction greater than double");
  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f>td.d) == td.expected);
  }
}

void test_fraction_greater_than_equal_double()
{
  FDB [] test_data = [
    {new FractionType(0,1),(0/1.0),true},
    {new FractionType(0,1),(1.0/2),false},
    {new FractionType(2,3),(-2.0/3),true},
    {new FractionType(2,3),(2.0/3),true},
    {new FractionType(1,3),(1.0/3),true},
    {new FractionType(-5,7),(5.0/7),false},
  ];
  th.TestCase("Fraction greater than or equal to double");

  th.TestCase("Fraction greater than double");
  foreach( td; test_data) {
    th.Test(format(" (%s) == %s - %s",td.f,td.d,td.expected),(td.f>=td.d) == td.expected);
  }

}

struct DFB {
  double d;
  FractionType f;
  bool expected;
}

void test_double_equal_to_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),true},
    { 0.0/1.0, new FractionType(1,2),false},
    { 2.0/3.0, new FractionType(-2,3),false},
    { 2.0/3, new FractionType(2,3),true},
    { 1.0/3, new FractionType(1,3),true},
    { -5.0/7, new FractionType(5,7),false},
  ];
  th.TestCase("Fraction equal to double");
  foreach( td; test_data) {
    th.Test(format(" %s == (%s) - %s",td.d,td.f,td.expected),(td.d==td.f) == td.expected);
  }

}

void test_double_not_equal_to_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),false},
    { 0.0/1.0, new FractionType(1,2),true},
    { 2.0/3.0, new FractionType(-2,3),true},
    { 2.0/3, new FractionType(2,3),false},
    { 1.0/3, new FractionType(1,3),false},
    { -5.0/7, new FractionType(5,7),true},
  ];
  th.TestCase("Double not equal Fraction");
  foreach( td; test_data) {
    th.Test(format(" %s != (%s) - %s",td.d,td.f,td.expected),(td.d!=td.f) == td.expected);
  }
}

void test_double_less_than_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),false},
    { 0.0/1.0, new FractionType(1,2),true},
    { 2.0/3.0, new FractionType(-2,3),false},
    { 2.0/3, new FractionType(2,3),false},
    { 1.0/3, new FractionType(1,3),false},
    { -5.0/7, new FractionType(5,7),true},
  ];
  th.TestCase("Double Less than fraction");

  foreach( td; test_data) {
    th.Test(format(" %s < (%s) - %s",td.d,td.f,td.expected),(td.d<td.f) == td.expected);
  }

}

void test_double_less_than_equal_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),true},
    { 0.0/1.0, new FractionType(1,2),true},
    { 2.0/3.0, new FractionType(-2,3),false},
    { 2.0/3, new FractionType(2,3),true},
    { 1.0/3, new FractionType(1,3),true},
    { -5.0/7, new FractionType(5,7),true},
  ];
  th.TestCase("Double less than or equal to fraction");

  foreach( td; test_data) {
    th.Test(format(" %s <= (%s) - %s",td.d,td.f,td.expected),(td.d<=td.f) == td.expected);
  }
}

void test_double_greater_than_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),false},
    { 0.0/1.0, new FractionType(1,2),false},
    { 2.0/3.0, new FractionType(-2,3),true},
    { 2.0/3, new FractionType(2,3),false},
    { 1.0/3, new FractionType(1,3),false},
    { -5.0/7, new FractionType(5,7),false},
  ];
  th.TestCase("Double greater than fraction");
  foreach( td; test_data) {
    th.Test(format(" %s > (%s) - %s",td.d,td.f,td.expected),(td.d>td.f) == td.expected);
  }
}

void test_double_greater_than_equal_fraction()
{
  DFB [] test_data = [
    { 0.0, new FractionType(0,1),true},
    { 0.0/1.0, new FractionType(1,2),false},
    { 2.0/3.0, new FractionType(-2,3),true},
    { 2.0/3, new FractionType(2,3),true},
    { 1.0/3, new FractionType(1,3),true},
    { -5.0/7, new FractionType(5,7),false},
  ];
  th.TestCase("Double greater than or equal to fraction");
  foreach( td; test_data) {
    th.Test(format(" %s >= (%s) - %s",td.d,td.f,td.expected),(td.d>=td.f) == td.expected);
  }

}

struct FFF {
  FractionType f1;
  FractionType f2;
  FractionType f3;
}
void test_fraction_plus_fraction()
{
  FFF [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),new FractionType(0,1)},
    { new FractionType(0,1),new FractionType(1,1),new FractionType(1,1)},
    { new FractionType(3,5),new FractionType(-2,9),new FractionType(17,45)},
    { new FractionType(-1,4),new FractionType(-3,4),new FractionType(-1,1)},
    { new FractionType(7,3),new FractionType(10,7),new FractionType(79,21)},
    { new FractionType(-5,7),new FractionType(5,7),new FractionType(0,1)},
  ];

  th.TestCase("Fraction plus fraction");
  foreach (td; test_data) {
    auto f = td.f1+td.f2;
    th.Test(format("(%s) + (%s) = (%s)",td.f1,td.f2,td.f3),(f == td.f3) && is(typeof(f) == FractionType));
  }
}

void test_fraction_minus_fraction()
{
  FFF [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),new FractionType(0,1)},
    { new FractionType(0,1),new FractionType(1,1),new FractionType(-1,1)},
    { new FractionType(3,5),new FractionType(-2,9),new FractionType(37,45)},
    { new FractionType(-1,4),new FractionType(-3,4),new FractionType(1,2)},
    { new FractionType(7,3),new FractionType(10,7),new FractionType(19,21)},
    { new FractionType(-5,7),new FractionType(5,7),new FractionType(-10,7)},
  ];

  th.TestCase("Fraction minus fraction");
  foreach (td; test_data) {
    auto f = td.f1-td.f2;
    th.Test(format("(%s) - (%s) = (%s)",td.f1,td.f2,td.f3),f == td.f3 && is(typeof(f) == FractionType));
  }
}

void test_fraction_times_fraction()
{
  FFF [] test_data = [
    { new FractionType(0,1),new FractionType(0,1),new FractionType(0,1)},
    { new FractionType(0,1),new FractionType(1,1),new FractionType(0,1)},
    { new FractionType(3,5),new FractionType(-2,9),new FractionType(-2,15)},
    { new FractionType(-1,4),new FractionType(-3,4),new FractionType(3,16)},
    { new FractionType(7,3),new FractionType(10,7),new FractionType(10,3)},
    { new FractionType(-5,7),new FractionType(5,7),new FractionType(-25,49)},
  ];

  th.TestCase("Fraction times fraction");
  foreach (td; test_data) {
    auto f = td.f1*td.f2;
    th.Test(format("(%s) * (%s) = (%s)",td.f1,td.f2,td.f3),f == td.f3 && is(typeof(f) == FractionType));
  }
}

void test_fraction_divided_by_fraction()
{
  FFF [] test_data = [
    { new FractionType(0,1),new FractionType(1,1),new FractionType(0,1)},
    { new FractionType(3,5),new FractionType(-2,9),new FractionType(-27,10)},
    { new FractionType(-1,4),new FractionType(-3,4),new FractionType(1,3)},
    { new FractionType(7,3),new FractionType(10,7),new FractionType(49,30)},
    { new FractionType(-5,7),new FractionType(5,7),new FractionType(-1,1)},
  ];

  th.TestCase("Fraction divided by fraction");
  foreach (td; test_data) {
    auto f = td.f1/td.f2;
    th.Test(format("(%s) / (%s) = (%s)",td.f1,td.f2,td.f3),f == td.f3 && is(typeof(f) == FractionType));
  }
}

void test_fraction_power_fraction()
{
  FFF [] test_data = [
    { new FractionType(0,1),new FractionType(1,1),new FractionType(0,1)},
    { new FractionType(3,5),new FractionType(-2,9),new FractionType(643,574)},
    { new FractionType(1,4),new FractionType(-3,4),new FractionType(577,204)},
    { new FractionType(7,3),new FractionType(10,7),new FractionType(1399,417)},
    { new FractionType(-5,7),new FractionType(5,1),new FractionType(-37,199)},
  ];

  th.TestCase("Fraction to power of fraction");
  foreach (td; test_data) {
    auto f = td.f1^^td.f2;
    th.Test(format("(%s) ^^ (%s) = (%s)",td.f1,td.f2,td.f3),f == td.f3 && is(typeof(f) == FractionType));
  }
}

struct FDF {
  FractionType f1;
  double d;
  FractionType f2;
}

void test_fraction_plus_double()
{
  FDF [] test_data = [
    { new FractionType(0,1), 0.0/1.0,new FractionType(0,1) },
    { new FractionType(0,1), 1.0/1.0,new FractionType(1,1) },
    { new FractionType(3,5), -2.0/9,new FractionType(17,45) },
    { new FractionType(-1,4), -3.0/4.0,new FractionType(-1,1) },
    { new FractionType(7,3), 10.0/7.0,new FractionType(79,21) },
    { new FractionType(-5,7), 5.0/7.0,new FractionType(0,1) },
  ];
  th.TestCase("Fraction plus double");
  foreach (td; test_data) {
    auto f = td.f1+td.d;
    th.Test(format("(%s) / (%s) = (%s)",td.f1,td.d,td.f2),f == td.f2 && is(typeof(f) == FractionType));
  }
}

void test_fraction_minus_double()
{
  FDF [] test_data = [
    { new FractionType(0,1), 0.0/1.0,new FractionType(0,1) },
    { new FractionType(0,1), 1.0/1.0,new FractionType(-1,1) },
    { new FractionType(3,5), -2.0/9,new FractionType(37,45) },
    { new FractionType(-1,4), -3.0/4.0,new FractionType(1,2) },
    { new FractionType(7,3), 10.0/7.0,new FractionType(19,21) },
    { new FractionType(-5,7), 5.0/7.0,new FractionType(-10,7) },
  ];
  th.TestCase("Fraction minus double");
  foreach (td; test_data) {
    auto f = td.f1-td.d;
    writeln(f);
    th.Test(format("(%s) - (%s) = (%s)",td.f1,td.d,td.f2),f == td.f2 && is(typeof(f) == FractionType));
  }
}

void test_fraction_times_double()
{
  FDF [] test_data = [
    { new FractionType(0,1), 0.0/1.0,new FractionType(0,1) },
    { new FractionType(0,1), 1.0/1.0,new FractionType(0,1) },
    { new FractionType(3,5), -2.0/9,new FractionType(-2,15) },
    { new FractionType(-1,4), -3.0/4.0,new FractionType(3,16) },
    { new FractionType(7,3), 10.0/7.0,new FractionType(10,3) },
    { new FractionType(-5,7), 5.0/7.0,new FractionType(-25,49) },
  ];
  th.TestCase("Fraction times double");
  foreach (td; test_data) {
    auto f = td.f1*td.d;
    th.Test(format("(%s) * (%s) = (%s)",td.f1,td.d,td.f2),f == td.f2 && is(typeof(f) == FractionType));
  }
}

void test_fraction_divided_by_double()
{
  FDF [] test_data = [
    { new FractionType(0,1), 1.0/1.0,new FractionType(0,1) },
    { new FractionType(3,5), -2.0/9,new FractionType(-27,10) },
    { new FractionType(-1,4), -3.0/4.0,new FractionType(1,3) },
    { new FractionType(7,3), 10.0/7.0,new FractionType(49,30) },
    { new FractionType(-5,7), 5.0/7.0,new FractionType(-1,1) },
  ];
  th.TestCase("Fraction divided by double");
  foreach (td; test_data) {
    auto f = td.f1/td.d;
    th.Test(format("(%s) / (%s) = (%s)",td.f1,td.d,td.f2),f == td.f2 && is(typeof(f) == FractionType));
  }
}

void test_fraction_power_double()
{
  FDF [] test_data = [
    { new FractionType(0,1),1.0,new FractionType(0,1)},
    { new FractionType(3,5),-2.0/9,new FractionType(643,574)},
    { new FractionType(1,4),-3.0/4,new FractionType(577,204)},
    { new FractionType(7,3),10.0/7,new FractionType(1399,417)},
    { new FractionType(-5,7),5.0,new FractionType(-37,199)},
  ];

  th.TestCase("Fraction to power of double");
  foreach (td; test_data) {
    auto f = td.f1^^td.d;
    th.Test(format("(%s) ^^ (%s) = (%s)",td.f1,td.d,td.f2),f == td.f2 && is(typeof(f) == FractionType));
  }
}

struct DFD {
  double d1;
  FractionType f;
  double d2;
}
void test_double_plus_fraction()
{
  DFD [] test_data = [
    { 0.0/1, new FractionType(0,1),0.0/1 },
    { 0.0/1, new FractionType(1,1),1.0/1 },
    { 3.0/5, new FractionType(-2,9),17.0/45 },
    { -1.0/4, new FractionType(-3,4),-1.0/1 },
    { 7.0/3, new FractionType(10,7),79.0/21 },
    { -5.0/7, new FractionType(5,7),0.0/1 },
  ];

  th.TestCase("double plus fraction");
  foreach (td; test_data) {
    double d = td.d1+td.f;
    th.Test(format("(%s) + (%s) = (%s)",td.d1,td.f,td.d2),(fabs(d - td.d2) < FractionType.epsilon) && is(typeof(d) == double));
  }
}

void test_double_minus_fraction()
{
  DFD [] test_data = [
    { 0.0/1, new FractionType(0,1),0.0/1 },
    { 0.0/1, new FractionType(1,1),-1.0/1 },
    { 3.0/5, new FractionType(-2,9),37.0/45 },
    { -1.0/4, new FractionType(-3,4),1.0/2 },
    { 7.0/3, new FractionType(10,7),19.0/21 },
    { -5.0/7, new FractionType(5,7),-10.0/7 },
  ];

  th.TestCase("double minus fraction");
  foreach (td; test_data) {
    auto d = td.d1-td.f;
    writeln(d);
    th.Test(format("(%s) - (%s) = (%s)",td.d1,td.f,td.d2),fabs(d - td.d2) < FractionType.epsilon);
  }
}

void test_double_times_fraction()
{
  DFD [] test_data = [
    { 0.0/1, new FractionType(0,1),0.0/1 },
    { 0.0/1, new FractionType(1,1),0.0/1 },
    { 3.0/5, new FractionType(-2,9),-2.0/15 },
    { -1.0/4, new FractionType(-3,4),3.0/16 },
    { 7.0/3, new FractionType(10,7),10.0/3 },
    { -5.0/7, new FractionType(5,7),-25.0/49 },
  ];

  th.TestCase("double times fraction");
  foreach (td; test_data) {
    auto d = td.d1*td.f;
    th.Test(format("(%s) * (%s) = (%s)",td.d1,td.f,td.d2),fabs(d - td.d2) < FractionType.epsilon);
  }
}

void test_double_divided_by_fraction()
{
  DFD [] test_data = [
    { 0.0/1, new FractionType(1,1),0.0/1 },
    { 3.0/5, new FractionType(-2,9),-27.0/10 },
    { -1.0/4, new FractionType(-3,4),1.0/3 },
    { 7.0/3, new FractionType(10,7),49.0/30 },
    { -5.0/7, new FractionType(5,7),-1.0/1 },
  ];

  th.TestCase("double divided by fraction");
  foreach (td; test_data) {
    auto d = td.d1/td.f;
    th.Test(format("(%s) / (%s) = (%s)",td.d1,td.f,td.d2),fabs(d - td.d2) < FractionType.epsilon);
  }
}

void test_double_power_fraction()
{
  DFD [] test_data = [
    { 0.0/1,new FractionType(1,1),0.0/1},
    { 3.0/5,new FractionType(-2,9),643.0/574},
    { 1.0/4,new FractionType(-3,4),577.0/204},
    { 7.0/3,new FractionType(10,7),1399.0/417},
    { -5.0/7,new FractionType(5,1),-37.0/199},
  ];

  th.TestCase("Double to power of fraction");
  foreach (td; test_data) {
    auto d = td.d1^^td.f;
    th.Test(format("(%s) / (%s) = (%s)",td.d1,td.f,td.d2),fabs(d - td.d2) < FractionType.epsilon);
  }
}

void test_assign_int()
{
  int [][] assign_int_data =
  [
    [-10, -10,1 ],
    [ 1, 1, 1],
    [ 0, 0, 1],
    [ 10, 10, 1]
  ];

  Fraction f=new Fraction;
  th.TestCase("Fraction = int");
  for(int i=0;i<assign_int_data.length;i++) {
    f=assign_int_data[i][0];
    th.Test(format("f = %s (%s/%s)",assign_int_data[i][0],assign_int_data[i][1],assign_int_data[i][2]),
            f.numerator()==assign_int_data[i][1] && f.denominator()==assign_int_data[i][2]);
  }
}

void test_assign_double()
{
  double [] assign_double_data_input = [ -10.06, -0.06, 0, 0.06, 10.06 ];
  int [][] assign_double_data_output = [ [-503,50], [-3,50], [0,1], [3,50], [503,50]];

  Fraction f=new Fraction;
  th.TestCase("Fraction = int");
  for(int i=0;i<assign_double_data_input.length;i++) {
    f=assign_double_data_input[i];
    th.Test(format("f = %s (%s/%s)",assign_double_data_input[i],assign_double_data_output[i][0],assign_double_data_output[i][1]),
            f.numerator()==assign_double_data_output[i][0] && f.denominator()==assign_double_data_output[i][1]);
  }
}

void test_fraction_to_string_mixed()
{
  int [][] fraction_to_string_mixed_input = [ [-503,50], [-3,50], [0,1], [3,50], [503,50]];
  string [] fraction_to_string_mixed_output = [ "-10 3/50", "-3/50" , "0", "3/50" , "10 3/50"];
  MixedFraction f = new MixedFraction;
  th.TestCase("Fraction toStringMixed");

  for(int i=0;i<fraction_to_string_mixed_input.length;i++) {
    f.set(fraction_to_string_mixed_input[i][0],fraction_to_string_mixed_input[i][1]);
    th.Test(format("toString(%s/%s) = \"%s\"",fraction_to_string_mixed_input[i][0],fraction_to_string_mixed_input[i][1],
          fraction_to_string_mixed_output[i]),f.toString()==fraction_to_string_mixed_output[i]);
  }
}

void test_fraction_round()
{
  int [][] round_data =
  [
    [3333,10000,100,33,100],
    [3333,10000,10,3,10],
    [639,5176,100,3,25]
  ];

  Fraction f=new Fraction;
  th.TestCase("Fraction round");

  for(int i=0;i<round_data.length;i++) {
    f.set(round_data[i][0],round_data[i][1]);
    f.round(round_data[i][2]);
    th.Test(format("(%s/%s).round(%s) = (%s/%s)",round_data[i][0],round_data[i][1],round_data[i][2],
        round_data[i][3],round_data[i][4]),
        f.numerator()==round_data[i][3] && f.denominator()==round_data[i][4]);
  }
}

void test_random()
{
  th.TestCase("Random double to fraction");
  int numerator,denominator;
  Fraction f=new Fraction;
  auto rnd = Random(cast(int)time(null));
  for(int i=0;i<1000;i++) {
    numerator = uniform(100, 214748364, rnd);
    denominator = uniform(100, 214748364, rnd);
    double value = cast(double)numerator/cast(double)denominator;
    f.set(value);
    if(fabs(value - cast(double)f)) {
      th.PassIncrement();
    } else {
      th.FailIncrement();
    }
  }
}

void function() [] tests =
[
  &test_gcd,
  &test_new_zero_args,
  &test_new_one_integer_arg,
  &test_new_two_integer_args,
  &test_new_three_integers,
  &test_new_double,
  &test_new_string,
  &test_fraction_to_string,
  &test_fraction_equal_fraction,
  &test_fraction_not_equal_fraction,
  &test_fraction_less_than_fraction,
  &test_fraction_less_than_equal_fraction,
  &test_fraction_greater_than_fraction,
  &test_fraction_greater_than_equal_fraction,
  &test_cast_to_double,
  &test_fraction_equal_to_double,
  &test_fraction_not_equal_double,
  &test_fraction_less_than_double,
  &test_fraction_less_than_equal_double,
  &test_fraction_greater_than_double,
  &test_fraction_greater_than_equal_double,
  &test_double_equal_to_fraction,
  &test_double_not_equal_to_fraction,
  &test_double_less_than_fraction,
  &test_double_less_than_equal_fraction,
  &test_double_greater_than_fraction,
  &test_double_greater_than_equal_fraction,
  &test_fraction_plus_fraction,
  &test_fraction_minus_fraction,
  &test_fraction_times_fraction,
  &test_fraction_divided_by_fraction,
  &test_fraction_power_fraction,
  &test_fraction_plus_double,
  &test_fraction_minus_double,
  &test_fraction_times_double,
  &test_fraction_divided_by_double,
  &test_fraction_power_double,
  &test_double_plus_fraction,
  &test_double_minus_fraction,
  &test_double_times_fraction,
  &test_double_divided_by_fraction,
  &test_double_power_fraction,
  &test_assign_int,
  &test_assign_double,
  &test_fraction_to_string_mixed,
  &test_fraction_round,
  &test_random
];

int indexex[32];

void main(string args[])
{
  if(args.length == 1) {
    for(int i=0;i<tests.length;i++)
      tests[i]();
  } else {
    for(int i=1;i<args.length;i++) {
      int j = to!int(args[i]);
      if(j<tests.length)
        tests[j]();
      else
        stdout.writeln("No test for ",j);
    }
  }

  th.FinalSummary();
}
