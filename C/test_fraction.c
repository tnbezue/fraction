#include "fraction.h"
#include "test_harness.h"

void test_init()
{
}

void test_gcd()
{
  TESTCASE("Greatest Common Divisor");

  TEST("GCD(0,2) = 1",fraction_gcd(0,2)==2);
  TEST("GCD(10,1) = 1",fraction_gcd(10,1)==1);
  TEST("GCD(105,15) = 1",fraction_gcd(105,15)==15);
  TEST("GCD(10,230) = 1",fraction_gcd(10,230)==10);
  TEST("GCD(28,234) = 1",fraction_gcd(28,234)==2);
  TEST("GCD(872452914,78241452) = 1",fraction_gcd(872452914,78241452)==6);
}

#define S(f,n,d) f.numerator_=n,f.denominator_=d
#define R(f,n,d) (f.numerator_==n && f.denominator_==d)

void test_fraction_plus_fraction()
{
  TESTCASE("Add Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  S(f1,0,1);
  S(f2,0,1);
  f3=fraction_plus_fraction(f1,f2);
  TEST("0/1 + 0/1 = 0/1",R(f3,0,1));

  S(f1,0,1);
  S(f2,1,1);
  f3=fraction_plus_fraction(f1,f2);
  TEST("0/1 + 1/1 = 1/1",R(f3,1,1));

  S(f1,3,5);
  S(f2,-2,9);
  f3=fraction_plus_fraction(f1,f2);
  TEST("3/5 + -2/9 = 17/45",R(f3,17,45));

  S(f1,-2,8);
  S(f2,-6,8);
  f3=fraction_plus_fraction(f1,f2);
  TEST("-2/8 + -6/8 = -1/1",R(f3,-1,1));

  S(f1,7,3);
  S(f2,10,7);
  f3=fraction_plus_fraction(f1,f2);
  TEST("7/3 + 10/7 = 79/21",R(f3,79,21));

  S(f1,-5,7);
  S(f2,25,35);
  f3=fraction_plus_fraction(f1,f2);
  TEST("-5/7 + 25/35 = 0/1",R(f3,0,1));

}

void test_fraction_minus_fraction()
{
  TESTCASE("Subtract Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  S(f1,0,1);
  S(f2,0,1);
  f3=fraction_minus_fraction(f1,f2);
  TEST("0/1 - 0/1 = 0/1",R(f3,0,1));

  S(f1,0,1);
  S(f2,1,1);
  f3=fraction_minus_fraction(f1,f2);
  TEST("0/1 - 1/1 = 1/1",R(f3,-1,1));

  S(f1,3,5);
  S(f2,-2,9);
  f3=fraction_minus_fraction(f1,f2);
  TEST("3/5 - -2/9 = 37/45",R(f3,37,45));

  S(f1,-2,8);
  S(f2,-6,8);
  f3=fraction_minus_fraction(f1,f2);
  TEST("-2/8 - -6/8 = 1/2",R(f3,1,2));

  S(f1,7,3);
  S(f2,10,7);
  f3=fraction_minus_fraction(f1,f2);
  TEST("7/3 - 10/7 = 19/21",R(f3,19,21));

  S(f1,-5,7);
  S(f2,25,35);
  f3=fraction_minus_fraction(f1,f2);
  TEST("-5/7 - 25/35 = -10/7",R(f3,-10,7));

}

void test_fraction_times_fraction()
{
  TESTCASE("Multiply Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  S(f1,0,1);
  S(f2,0,1);
  f3=fraction_times_fraction(f1,f2);
  TEST("0/1 * 0/1 = 0/1",R(f3,0,1));

  S(f1,0,1);
  S(f2,1,1);
  f3=fraction_times_fraction(f1,f2);
  TEST("0/1 * 1/1 = 0/1",R(f3,0,1));

  S(f1,3,5);
  S(f2,-2,9);
  f3=fraction_times_fraction(f1,f2);
  TEST("3/5 * -2/9 = -2/15",R(f3,-2,15));

  S(f1,-2,8);
  S(f2,-6,8);
  f3=fraction_times_fraction(f1,f2);
  TEST("-2/8 * -6/8 = 3/16",R(f3,3,16));

  S(f1,7,3);
  S(f2,10,7);
  f3=fraction_times_fraction(f1,f2);
  TEST("7/3 * 10/7 = 10/3",R(f3,10,3));

  S(f1,-5,7);
  S(f2,25,35);
  f3=fraction_times_fraction(f1,f2);
  TEST("-5/7 * 25/35 = -25/49",R(f3,-25,49));

}


void test_fraction_divided_by_fraction()
{
  TESTCASE("Divide Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  S(f1,0,1);
  S(f2,1,1);
  f3=fraction_divided_by_fraction(f1,f2);
  TEST("0/1 / 1/1 = 1/1",R(f3,0,1));

  S(f1,3,5);
  S(f2,-2,9);
  f3=fraction_divided_by_fraction(f1,f2);
  TEST("3/5 / -2/9 = -27/10",R(f3,-27,10));

  S(f1,-2,8);
  S(f2,-6,8);
  f3=fraction_divided_by_fraction(f1,f2);
  TEST("-2/8 / -6/8 = 1/3",R(f3,1,3));

  S(f1,7,3);
  S(f2,10,7);
  f3=fraction_divided_by_fraction(f1,f2);
  TEST("7/3 / 10/7 = 49/30",R(f3,49,30));

  S(f1,-5,7);
  S(f2,25,35);
  f3=fraction_divided_by_fraction(f1,f2);
  TEST("-5/7 / 25/35 = -1",R(f3,-1,1));
}

void test_fraction_eq_fraction()
{
  TESTCASE("Fraction Equality");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 == 0/1 - true ",fraction_eq_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 == 1/2 - false ",!fraction_eq_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/1 == -2/3 - false ",!fraction_eq_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 == 16/24 - true ",fraction_eq_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 == 1/3 - true ",fraction_eq_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 == 25/35 - false ",!fraction_eq_fraction(f1,f2));
}

void test_fraction_ne_fraction()
{
  TESTCASE("Fraction inequality");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 != 0/1 - false ",!fraction_ne_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 != 1/2 - true ",fraction_ne_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/1 != -2/3 - true ",fraction_ne_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 != 16/24 - false ",!fraction_ne_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 != 1/3 - false ",!fraction_ne_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 != 25/35 - true ",fraction_ne_fraction(f1,f2));
}

void test_fraction_lt_fraction()
{
  TESTCASE("Fraction less than fraction");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 < 0/1 - false ",!fraction_lt_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 < 1/2 - true ",fraction_lt_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/1 < -2/3 - false ",!fraction_lt_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 < 16/24 - false ",!fraction_lt_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 < 1/3 - false ",!fraction_lt_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 < 25/35 - true ",fraction_lt_fraction(f1,f2));
}

void test_fraction_le_fraction()
{
  TESTCASE("Fraction less than or equal fraction");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 <= 0/1 - true ",fraction_le_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 <= 1/2 - true ",fraction_le_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/1 <= -2/3 - false ",!fraction_le_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 <= 16/24 - true ",fraction_le_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 <= 1/3 - true ",fraction_le_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 <= 25/35 - true ",fraction_le_fraction(f1,f2));
}

void test_fraction_gt_fraction()
{
  TESTCASE("Fraction greater than fraction");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 > 0/1 - false ",!fraction_gt_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 > 1/2 - false ",!fraction_gt_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/1 > -2/3 - true ",fraction_gt_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 > 16/24 - false ",!fraction_gt_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 > 1/3 - false ",!fraction_gt_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 > 25/35 - false ",!fraction_gt_fraction(f1,f2));
}

void test_fraction_ge_fraction()
{
  TESTCASE("Fraction greater than or equal fraction");
  fraction_t f1;
  fraction_t f2;

  S(f1,0,1);
  S(f2,0,1);
  TEST("0/1 >= 0/1 - true ",fraction_ge_fraction(f1,f2));

  S(f1,0,1);
  S(f2,1,1);
  TEST("0/1 >= 1/2 - false ",!fraction_ge_fraction(f1,f2));

  S(f1,2,3);
  S(f2,-2,3);
  TEST("2/3 >= -2/3 - true ",fraction_ge_fraction(f1,f2));

  S(f1,2,3);
  S(f2,16,24);
  TEST("2/3 >= 16/24 - true ",fraction_ge_fraction(f1,f2));

  S(f1,1,3);
  S(f2,1,3);
  TEST("1/3 >= 1/3 - true ",fraction_ge_fraction(f1,f2));

  S(f1,-5,7);
  S(f2,25,35);
  TEST("-5/7 >= 25/35 - false ",!fraction_ge_fraction(f1,f2));
}


test_function tests[] =
{
  test_gcd,
  test_fraction_plus_fraction,
  test_fraction_minus_fraction,
  test_fraction_times_fraction,
  test_fraction_divided_by_fraction,
  test_fraction_eq_fraction,
  test_fraction_ne_fraction,
  test_fraction_lt_fraction,
  test_fraction_le_fraction,
  test_fraction_gt_fraction,
  test_fraction_ge_fraction,
};

TEST_MAIN(tests)
