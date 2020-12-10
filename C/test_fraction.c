#include "fraction.h"
#include "test_harness.h"

void test_init()
{
}

void test_gcd()
{
  int gcd_test_data[][3] = { { 0,2,2},{ 10,1,1},{ 105,15,15},{ 10,230,10},{ 28,234,2}, {872452914,78241452,6 },};
  int i,n=ARRAY_SIZE(gcd_test_data);
  char msg[64];
  TESTCASE("Greatest Common Divisor");
  for(i=0;i<n;i++) {
    sprintf(msg,"GCD(%d,%d) = %d",gcd_test_data[i][0],gcd_test_data[i][1],
          gcd_test_data[i][2],gcd_test_data[i][3]);
    TEST(msg,fraction_gcd(gcd_test_data[i][0],gcd_test_data[i][1])==gcd_test_data[i][2]);
  }
}

#define S(f,n,d) fraction_set(&f,n,d)
#define SM(f,w,n,d) fraction_set_mixed(&f,w,n,d)
#define R(f,n,d) (f.numerator_==n && f.denominator_==d)

void test_fraction_set()
{
  fraction_t f;

  TESTCASE("Fraction set");
  int set_test_data[][4]={
    { 0,1,0,1 },
    {1,1,1,1},
    {-2,3,-2,3},
    {2,-3,-2,3},
    {-2,-3,2,3},
    };
  int i,n = ARRAY_SIZE(set_test_data);
  char msg[64];
  for(i=0;i<n;i++) {
    sprintf(msg,"set(%ld,%ld) = (%ld/%ld)",set_test_data[i][0],set_test_data[i][1],
          set_test_data[i][2],set_test_data[i][3]);
    S(f,set_test_data[i][0],set_test_data[i][1]);
    TEST(msg,R(f,set_test_data[i][2],set_test_data[i][3]));
  }
}

void test_fraction_set_mixed()
{
  TESTCASE("Fraction set WND");
  fraction_t f;
  char msg[64];
  int set_test_data[][5]={ { -10,2,3,-32,3 }, {0,-2,3,-2,3}, {0,0,1,0,1}, {0,2,3,2,3}, {10,2,3,32,3}};
  int i,n = ARRAY_SIZE(set_test_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"set(%d,%d,%d) = (%d/%d)",set_test_data[i][0],set_test_data[i][1],
          set_test_data[i][2],set_test_data[i][3],set_test_data[i][4]);
    SM(f,set_test_data[i][0],set_test_data[i][1],set_test_data[i][2]);
    TEST(msg,R(f,set_test_data[i][3],set_test_data[i][4]));
  }
}

void test_fraction_plus_fraction()
{
  int plus_data[][6] = { {0,1,0,1,0,1} , {0,1,1,1,1,1},{3,5,-2,9,17,45},
          {-2,8,-6,8,-1,1}, {7,3,10,7,79,21}, {-5,7,25,35,0,1}};
  TESTCASE("Add Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  char msg[64];
  int i,n=ARRAY_SIZE(plus_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) + (%d/%d) = (%d/%d)",plus_data[i][0],plus_data[i][1],plus_data[i][2],
          plus_data[i][3],plus_data[i][4],plus_data[i][5]);
    S(f1,plus_data[i][0],plus_data[i][1]);
    S(f2,plus_data[i][2],plus_data[i][3]);
    f3=fraction_plus_fraction(f1,f2);
    TEST(msg,R(f3,plus_data[i][4],plus_data[i][5]));
  }
}

void test_fraction_minus_fraction()
{
  int minus_data[][6] = { {0,1,0,1,0,1} , {0,1,1,1,-1,1},{3,5,-2,9,37,45},
          {-2,8,-6,8,1,2}, {7,3,10,7,19,21}, {-5,7,25,35,-10,7}};

  TESTCASE("Subtract Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  char msg[64];
  int i,n=ARRAY_SIZE(minus_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) - (%d/%d) = (%d/%d)",minus_data[i][0],minus_data[i][1],minus_data[i][2],
          minus_data[i][3],minus_data[i][4],minus_data[i][5]);
    S(f1,minus_data[i][0],minus_data[i][1]);
    S(f2,minus_data[i][2],minus_data[i][3]);
    f3=fraction_minus_fraction(f1,f2);
    TEST(msg,R(f3,minus_data[i][4],minus_data[i][5]));
  }
}

void test_fraction_times_fraction()
{
  int mul_data[][6] = { {0,1,0,1,0,1} , {0,1,1,1,0,1},{3,5,-2,9,-2,15},
          {-2,8,-6,8,3,16}, {7,3,10,7,10,3}, {-5,7,25,35,-25,49}};
  TESTCASE("Multiply Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  char msg[64];
  int i,n=ARRAY_SIZE(mul_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) * (%d/%d) = (%d/%d)",mul_data[i][0],mul_data[i][1],mul_data[i][2],
          mul_data[i][3],mul_data[i][4],mul_data[i][5]);
    S(f1,mul_data[i][0],mul_data[i][1]);
    S(f2,mul_data[i][2],mul_data[i][3]);
    f3=fraction_times_fraction(f1,f2);
    TEST(msg,R(f3,mul_data[i][4],mul_data[i][5]));
  }
}


void test_fraction_divided_by_fraction()
{
  int div_data[][6] = { {0,1,1,1,0,1},{3,5,-2,9,-27,10},
          {-2,8,-6,8,1,3}, {7,3,10,7,49,30}, {-5,7,25,35,-1,1}};
  TESTCASE("Divide Fractions");
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;

  char msg[64];
  int i,n=ARRAY_SIZE(div_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) / (%d/%d) = (%d/%d)",div_data[i][0],div_data[i][1],div_data[i][2],
          div_data[i][3],div_data[i][4],div_data[i][5]);
    S(f1,div_data[i][0],div_data[i][1]);
    S(f2,div_data[i][2],div_data[i][3]);
    f3=fraction_divided_by_fraction(f1,f2);
    TEST(msg,R(f3,div_data[i][4],div_data[i][5]));
  }
}

void test_fraction_eq_fraction()
{
  int eq_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1},{-5,7,25,35,0}};
  TESTCASE("Fraction Equality");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(eq_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) == (%d/%d) -- %s",eq_data[i][0],eq_data[i][1],eq_data[i][2],
          eq_data[i][3],(eq_data[i][4] == 1 ? "true" : "false"));
    S(f1,eq_data[i][0],eq_data[i][1]);
    S(f2,eq_data[i][2],eq_data[i][3]);
    TEST(msg,fraction_eq_fraction(f1,f2) == (eq_data[i][4] == 1));
  }
}

void test_fraction_ne_fraction()
{
  int ne_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
  TESTCASE("Fraction inequality");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(ne_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) != (%d/%d) -- %s",ne_data[i][0],ne_data[i][1],ne_data[i][2],
          ne_data[i][3],(ne_data[i][4] == 1 ? "true" : "false"));
    S(f1,ne_data[i][0],ne_data[i][1]);
    S(f2,ne_data[i][2],ne_data[i][3]);
    TEST(msg,fraction_ne_fraction(f1,f2) == (ne_data[i][4] == 1));
  }
}

void test_fraction_lt_fraction()
{
  int lt_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
  TESTCASE("Fraction less than fraction");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(lt_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) < (%d/%d) -- %s",lt_data[i][0],lt_data[i][1],lt_data[i][2],
          lt_data[i][3],(lt_data[i][4] == 1 ? "true" : "false"));
    S(f1,lt_data[i][0],lt_data[i][1]);
    S(f2,lt_data[i][2],lt_data[i][3]);
    TEST(msg,fraction_lt_fraction(f1,f2) == (lt_data[i][4] == 1));
  }
}

void test_fraction_le_fraction()
{
  int le_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,1}};
  TESTCASE("Fraction less than or equal fraction");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(le_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) <= (%d/%d) -- %s",le_data[i][0],le_data[i][1],le_data[i][2],
          le_data[i][3],(le_data[i][4] == 1 ? "true" : "false"));
    S(f1,le_data[i][0],le_data[i][1]);
    S(f2,le_data[i][2],le_data[i][3]);
    TEST(msg,fraction_le_fraction(f1,f2) == (le_data[i][4] == 1));
  }
}

void test_fraction_gt_fraction()
{
  int gt_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,0}};
  TESTCASE("Fraction greater than fraction");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(gt_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) > (%d/%d) -- %s",gt_data[i][0],gt_data[i][1],gt_data[i][2],
          gt_data[i][3],(gt_data[i][4] == 1 ? "true" : "false"));
    S(f1,gt_data[i][0],gt_data[i][1]);
    S(f2,gt_data[i][2],gt_data[i][3]);
    TEST(msg,fraction_gt_fraction(f1,f2) == (gt_data[i][4] == 1));
  }
}

void test_fraction_ge_fraction()
{
  int ge_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
  TESTCASE("Fraction greater than or equal fraction");
  fraction_t f1;
  fraction_t f2;

  char msg[64];
  int i,n=ARRAY_SIZE(ge_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) <= (%d/%d) -- %s",ge_data[i][0],ge_data[i][1],ge_data[i][2],
          ge_data[i][3],(ge_data[i][4] == 1 ? "true" : "false"));
    S(f1,ge_data[i][0],ge_data[i][1]);
    S(f2,ge_data[i][2],ge_data[i][3]);
    TEST(msg,fraction_ge_fraction(f1,f2) == (ge_data[i][4] == 1));
  }
}

void test_fraction_from_double()
{
  double input[] = { 0.0, 1.0, 12.25, -2.5, -0.06, 0.3, 0.33, 0.33333333};
  int output[][2] = { {0,1}, {1,1}, {49,4}, {-5,2}, {-3,50}, {3,10}, {33,100}, {1,3}};
  TESTCASE("Fraction from double");
  fraction_t f;

  char msg[64];
  int i,n=ARRAY_SIZE(input);
  for(i=0;i<n;i++) {
    sprintf(msg,"fraction_from_double(%lg) = (%d/%d)",input[i],output[i][0],output[i][1]);
    f = fraction_from_double(input[i]);
    TEST(msg,R(f,output[i][0],output[i][1]));
  }
}

void test_fraction_eq_double()
{
  int eq_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1},{-5,7,25,35,0}};
  TESTCASE("Fraction Equal to double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(eq_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) == (%d/%d) -- %s",eq_data[i][0],eq_data[i][1],eq_data[i][2],
          eq_data[i][3],(eq_data[i][4] == 1 ? "true" : "false"));
    S(f,eq_data[i][0],eq_data[i][1]);
    d=(double)eq_data[i][2]/(double)eq_data[i][3];
    TEST(msg,fraction_eq_double(f,d) == (eq_data[i][4] == 1));
  }
}

void test_fraction_ne_double()
{
  int ne_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
  TESTCASE("Fraction not equal double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(ne_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) != (%d/%d) -- %s",ne_data[i][0],ne_data[i][1],ne_data[i][2],
          ne_data[i][3],(ne_data[i][4] == 1 ? "true" : "false"));
    S(f,ne_data[i][0],ne_data[i][1]);
    d=(double)ne_data[i][2]/(double)ne_data[i][3];
    TEST(msg,fraction_ne_double(f,d) == (ne_data[i][4] == 1));
  }
}

void test_fraction_lt_double()
{
  int lt_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
  TESTCASE("Fraction less than double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(lt_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) < %lg -- %s",lt_data[i][0],lt_data[i][1],d,(lt_data[i][4] == 1 ? "true" : "false"));
    S(f,lt_data[i][0],lt_data[i][1]);
    d=(double)lt_data[i][2]/(double)lt_data[i][3];
    TEST(msg,fraction_lt_double(f,d) == (lt_data[i][4] == 1));
  }
}

void test_fraction_le_double()
{
  int le_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,1}};
  TESTCASE("Fraction less than or equal to double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(le_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) <= (%d/%d) -- %s",le_data[i][0],le_data[i][1],le_data[i][2],
          le_data[i][3],(le_data[i][4] == 1 ? "true" : "false"));
    S(f,le_data[i][0],le_data[i][1]);
    d=(double)le_data[i][2]/(double)le_data[i][3];
    TEST(msg,fraction_le_double(f,d) == (le_data[i][4] == 1));
  }
}

void test_fraction_gt_double()
{
  int gt_data[][5] = { { 0,1,0,1,0}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,0}};
  TESTCASE("Fraction greater than double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(gt_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) > (%d/%d) -- %s",gt_data[i][0],gt_data[i][1],gt_data[i][2],
          gt_data[i][3],(gt_data[i][4] == 1 ? "true" : "false"));
    S(f,gt_data[i][0],gt_data[i][1]);
    d=(double)gt_data[i][2]/(double)gt_data[i][3];
    TEST(msg,fraction_gt_double(f,d) == (gt_data[i][4] == 1));
  }
}

void test_fraction_ge_double()
{
  int ge_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
  TESTCASE("Fraction greater than or equal to double");
  fraction_t f;
  double d;

  char msg[64];
  int i,n=ARRAY_SIZE(ge_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"(%d/%d) <= (%d/%d) -- %s",ge_data[i][0],ge_data[i][1],ge_data[i][2],
          ge_data[i][3],(ge_data[i][4] == 1 ? "true" : "false"));
    S(f,ge_data[i][0],ge_data[i][1]);
    d=(double)ge_data[i][2]/(double)ge_data[i][3];
    TEST(msg,fraction_ge_double(f,d) == (ge_data[i][4] == 1));
  }
}

void test_round()
{
  int round_data[][5] = { {3333,10000,10,3,10}, {3333,10000,100,33,100},
        {639,5176,100,3,25}, { 2147483647,106197, 1000, 10110849,500}};
  TESTCASE("Fraction round");
  fraction_t f;
  char msg[64];

  int i,n=ARRAY_SIZE(round_data);
  for(i=0;i<n;i++) {
    sprintf(msg,"Round((%d/%d),%d) = (%d/%d)",round_data[i][0],round_data[i][1],round_data[i][2],
            round_data[i][3],round_data[i][4]);
    S(f,round_data[i][0],round_data[i][1]);
    fraction_round(&f,round_data[i][2]);
    TEST(msg,R(f,round_data[i][3],round_data[i][4]));
  }
}

test_function tests[] =
{
  test_gcd,
  test_fraction_set,
  test_fraction_set_mixed,
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
  test_fraction_from_double,
  test_fraction_eq_double,
  test_fraction_ne_double,
  test_fraction_lt_double,
  test_fraction_le_double,
  test_fraction_gt_double,
  test_fraction_ge_double,
  test_round,
};

TEST_MAIN(tests)
