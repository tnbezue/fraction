#include "fraction.h"
#include "test_harness.h"
#include <math.h>
#include <limits.h>
#include <string.h>

void test_init()
{
}

void test_gcd()
{
  int test_data[][3] = {
    { 0,2,2},
    { 10,1,1},
    { 105,15,15},
    { 10,230,10},
    { 28,234,2},
    {872452914,78241452,6 },
  };
  int i,n=ARRAY_SIZE(test_data);
  char msg[64];
  TESTCASE("Greatest Common Divisor");
  for(i=0;i<n;i++) {
    sprintf(msg,"GCD(%d,%d) = %d",test_data[i][0],test_data[i][1],test_data[i][2]);
    TEST(msg,fraction_gcd(test_data[i][0],test_data[i][1])==test_data[i][2]);
  }
}

#define S(f,n,d) fraction_set(&f,n,d)
#define SM(f,w,n,d) fraction_set_mixed(&f,w,n,d)
#define R(f,n,d) (f.numerator_==n && f.denominator_==d)
#define TS(f) fraction_to_s(f)
#define TMS(f) fraction_to_mixed_s(f)

/*
int R(fraction_t f,int n,int d)
{
  printf("ZZ %ld %d %ld %d\n",f.numerator_,n,f.denominator_,d);
  return (f.numerator_==n && f.denominator_==d);
}
*/
typedef struct {
  int n1;
  int d1;
  int n2;
  int d2;
} IIII;
void test_fraction_set()
{
  fraction_t f;

  TESTCASE("Fraction set");
  IIII test_data[]={
    { 0,1,0,1 },
    {1,1,1,1},
    {-2,3,-2,3},
    {2,-3,-2,3},
    {-20,-30,2,3},
    {INT_MAX}
    };
  char msg[64];
  const IIII* i;
  for(i=test_data;i->n1 != INT_MAX;i++) {
    sprintf(msg,"fraction_set(%d,%d) = (%d/%d)",i->n1,i->d1,i->n2,i->d2);
    S(f,i->n1,i->d1);
    TEST(msg,R(f,i->n2,i->d2));
  }
}

typedef struct {
  int w;
  int n1;
  int d1;
  int n2;
  int d2;
} IIIII;
void test_fraction_set_mixed()
{
  TESTCASE("Fraction set WND");
  fraction_t f;
  char msg[64];
  IIIII test_data[]= {
    { -10,2,3,-32,3 },
    {0,-2,3,-2,3},
    {0,0,1,0,1},
    {0,2,3,2,3},
    {10,2,3,32,3},
    {INT_MAX}
  };
  const IIIII* i;
  for(i=test_data;i->w != INT_MAX;i++) {
    sprintf(msg,"set_mixed(%d,%d,%d) = (%d/%d)",i->w,i->n1,i->d1,i->n2,i->d2);

    SM(f,i->w,i->n1,i->d1);
    TEST(msg,R(f,i->n2,i->d2));
  }
}

typedef struct {
  double dbl;
  int n;
  int d;
} DII;

void test_fraction_set_double()
{
  DII test_data[] = {
    { 0.0, 0,1 },
    { 1.0, 1,1 },
    { 12.25, 49,4},
    { -2.5,-5,2 },
    { -0.06,-3,50 },
    { 0.3, 3,10 },
    { 0.33, 33,100 },
    { 0.33333333,1,3},
    { 0, INT_MAX },
  };
  const DII* i;
  TESTCASE("Fraction set double");
  fraction_t f;
  char msg[64];
  for(i=test_data;i->n != INT_MAX;i++) {
    sprintf(msg,"fraction_set_double(%lg) = (%d/%d)",i->dbl,i->n,i->d);
    fraction_set_double(&f,i->dbl);
    TEST(msg,R(f,i->n,i->d));
  }
}

typedef struct {
  const char* s;
  int n;
  int d;
} SII;

void test_fraction_set_string()
{
  TESTCASE("Fraction set string");
  char msg[64];
  fraction_t f;
  SII test_data[] = {
    { "12.25", 49, 4},
    { "-0.06",-3, 50},
    { "1 1/2",3, 2 },
    { "-3 3/5",-18, 5},
    { "-3 -3/5",18, 5},
    { "-3 -3/-5",-18, 5},
    {NULL}
  };
  const SII* i;
  for(i=test_data;i->s != NULL;i++) {
    sprintf(msg,"set_string(\"%s\")=(%d/%d)",i->s,i->n,i->d);
    fraction_set_string(&f,i->s);
    TEST(msg,R(f,i->n,i->d));
  }
}

typedef struct {
  int n;
  int d;
  const char* s;
} IIS;

void test_fraction_to_s()
{
  IIS test_data [] = {
    { 0,1, "0"},
    { 2,10, "1/5"},
    { -16,3, "-16/3"},
    { 3,50, "3/50"},
    { -2,3, "-2/3"},
    { -2,-3, "2/3"},
    {  0,0 , NULL}
  };

  TESTCASE("Fraction to string");
  fraction_t f;
  const IIS* i;
  char msg[64];
  for(i=test_data;i->s != NULL; i++) {
    sprintf(msg,"fraction_to_s((%d/%d)) = \"%s\"",i->n,i->d,i->s);
    S(f,i->n,i->d);
    const char* fs = TS(f);
    TEST(msg,strcmp(fs,i->s)==0);
  }
}

void test_fraction_to_mixed_s()
{
  IIS test_data [] = {
    { 0,1, "0"},
    { 2,10, "1/5"},
    { -16,3, "-5 1/3"},
    { 50,3, "16 2/3"},
    { -2,3, "-2/3"},
    { -2,-3, "2/3"},
    {  0,0 , NULL}
  };

  TESTCASE("Fraction to string");
  fraction_t f;
  const IIS* i;
  char msg[64];
  for(i=test_data;i->s != NULL; i++) {
    sprintf(msg,"fraction_to_s((%d/%d)) = \"%s\"",i->n,i->d,i->s);
    S(f,i->n,i->d);
    const char* fs = TMS(f);
    TEST(msg,strcmp(fs,i->s)==0);
  }
}

typedef struct {
  fraction_t f1;
  fraction_t f2;
  int expected;
} FFB;

void test_fraction_eq_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  1},
    { {0,1}, {1,2},  0},
    { {2,3}, {-2,4}, 0},
    { {2,3}, {2,3},  1},
    { {1,3}, {1,3},  1},
    { {-5,7},{5,7},  0},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction equals fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) == (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_eq_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

void test_fraction_ne_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  0},
    { {0,1}, {1,2},  1},
    { {2,3}, {-2,4}, 1},
    { {2,3}, {2,3},  0},
    { {1,3}, {1,3},  0},
    { {-5,7},{5,7},  1},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction not equal fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) != (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_ne_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

void test_fraction_lt_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  0},
    { {0,1}, {1,2},  1},
    { {2,3}, {-2,4}, 0},
    { {2,3}, {2,3},  0},
    { {1,3}, {1,3},  0},
    { {-5,7},{5,7},  1},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction less than fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) < (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_lt_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

void test_fraction_le_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  1},
    { {0,1}, {1,2},  1},
    { {2,3}, {-2,4}, 0},
    { {2,3}, {2,3},  1},
    { {1,3}, {1,3},  1},
    { {-5,7},{5,7},  1},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction less than or equal fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) <= (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_le_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

void test_fraction_gt_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  0},
    { {0,1}, {1,2},  0},
    { {2,3}, {-2,4}, 1},
    { {2,3}, {2,3},  0},
    { {1,3}, {1,3},  0},
    { {-5,7},{5,7},  0},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction greater than fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) > (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_gt_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

void test_fraction_ge_fraction()
{
  FFB test_data [] = {
    { {0,1}, {0,1},  1},
    { {0,1}, {1,2},  0},
    { {2,3}, {-2,4}, 1},
    { {2,3}, {2,3},  1},
    { {1,3}, {1,3},  1},
    { {-5,7},{5,7},  0},
    { {0,0},{0,0}  , INT_MAX}
  };
  TESTCASE("Fraction greater than or equal fraction");

  char msg[64];
  const FFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) < (%s) -- %s",TS(i->f1),TS(i->f2),(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_ge_fraction(i->f1,i->f2) == (i->expected == 1));
  }
}

typedef struct {
  fraction_t f;
  double d;
  int expected;
} FDB;

void test_fraction_eq_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  1},
    { {0,1}, 1.0/2,  0},
    { {2,3}, -2.0/4, 0},
    { {2,3}, 2.0/3,  1},
    { {1,3}, 1.0/3,  1},
    { {-5,7},5.0/7,  0},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction equal to double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) == (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_eq_double(i->f,i->d) == (i->expected == 1));
  }
}

void test_fraction_ne_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  0},
    { {0,1}, 1.0/2,  1},
    { {2,3}, -2.0/4, 1},
    { {2,3}, 2.0/3,  0},
    { {1,3}, 1.0/3,  0},
    { {-5,7},5.0/7,  1},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction not equal to double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) != (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_ne_double(i->f,i->d) == (i->expected == 1));
  }
}

void test_fraction_lt_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  0},
    { {0,1}, 1.0/2,  1},
    { {2,3}, -2.0/4, 0},
    { {2,3}, 2.0/3,  0},
    { {1,3}, 1.0/3,  0},
    { {-5,7},5.0/7,  1},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction less than double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) < (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_lt_double(i->f,i->d) == (i->expected == 1));
  }
}

void test_fraction_le_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  1},
    { {0,1}, 1.0/2,  1},
    { {2,3}, -2.0/4, 0},
    { {2,3}, 2.0/3,  1},
    { {1,3}, 1.0/3,  1},
    { {-5,7},5.0/7,  1},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction less than or equal to double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) <= (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_le_double(i->f,i->d) == (i->expected == 1));
  }
}

void test_fraction_gt_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  0},
    { {0,1}, 1.0/2,  0},
    { {2,3}, -2.0/4, 1},
    { {2,3}, 2.0/3,  0},
    { {1,3}, 1.0/3,  0},
    { {-5,7},5.0/7,  0},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction greater than double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) > (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_gt_double(i->f,i->d) == (i->expected == 1));
  }
}

void test_fraction_ge_double()
{
  FDB test_data [] = {
    { {0,1}, 0.0/1,  1},
    { {0,1}, 1.0/2,  0},
    { {2,3}, -2.0/4, 1},
    { {2,3}, 2.0/3,  1},
    { {1,3}, 1.0/3,  1},
    { {-5,7},5.0/7,  0},
    { {0,0} , 0,  INT_MAX}
  };
  TESTCASE("Fraction greater than or equal to double");

  char msg[64];
  const FDB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%s) >= (%lg) -- %s",TS(i->f),i->d,(i->expected == 1 ? "true" : "false"));
    TEST(msg,fraction_ge_double(i->f,i->d) == (i->expected == 1));
  }
}

typedef struct {
  double d;
  fraction_t f;
  int expected;
} DFB;
void test_double_eq_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  1},
    { 0.0/1, {1,2},  0},
    { 2.0/3, {-2,4}, 0},
    { 2.0/3, {2,3},  1},
    { 1.0/3, {1,3},  1},
    { -5.9/7,{5,7},  0},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double equal to fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) == (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_eq_fraction(i->d,i->f) == (i->expected == 1));
  }
}

void test_double_ne_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  0},
    { 0.0/1, {1,2},  1},
    { 2.0/3, {-2,4}, 1},
    { 2.0/3, {2,3},  0},
    { 1.0/3, {1,3},  0},
    { -5.9/7,{5,7},  1},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double not equal to fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) != (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_ne_fraction(i->d,i->f) == (i->expected == 1));
  }
}

void test_double_lt_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  0},
    { 0.0/1, {1,2},  1},
    { 2.0/3, {-2,4}, 0},
    { 2.0/3, {2,3},  0},
    { 1.0/3, {1,3},  0},
    { -5.9/7,{5,7},  1},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double less than fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) < (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_lt_fraction(i->d,i->f) == (i->expected == 1));
  }
}

void test_double_le_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  1},
    { 0.0/1, {1,2},  1},
    { 2.0/3, {-2,4}, 0},
    { 2.0/3, {2,3},  1},
    { 1.0/3, {1,3},  1},
    { -5.9/7,{5,7},  1},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double less than or equal to fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) <= (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_le_fraction(i->d,i->f) == (i->expected == 1));
  }
}

void test_double_gt_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  0},
    { 0.0/1, {1,2},  0},
    { 2.0/3, {-2,4}, 1},
    { 2.0/3, {2,3},  0},
    { 1.0/3, {1,3},  0},
    { -5.9/7,{5,7},  0},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double greater than fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) > (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_gt_fraction(i->d,i->f) == (i->expected == 1));
  }
}

void test_double_ge_fraction()
{
  DFB test_data [] = {
    { 0.0/1, {0,1},  1},
    { 0.0/1, {1,2},  0},
    { 2.0/3, {-2,4}, 1},
    { 2.0/3, {2,3},  1},
    { 1.0/3, {1,3},  1},
    { -5.9/7,{5,7},  0},
    { 0 ,    {0,0},  INT_MAX}
  };
  TESTCASE("Double greater than or equal to fraction");
  char msg[64];
  const DFB* i;
  for(i=test_data;i->expected != INT_MAX;i++) {
    sprintf(msg,"(%lg) >= (%s) -- %s",i->d,TS(i->f),(i->expected == 1 ? "true" : "false"));
    TEST(msg,double_ge_fraction(i->d,i->f) == (i->expected == 1));
  }
}

typedef struct {
  fraction_t f1;
  fraction_t f2;
  fraction_t f3;
} FFF;

void test_fraction_plus_fraction()
{
  FFF test_data [] = {
    { {0,1},  {0,1},    {0,1} },
    { {0,1},  {1,1},    {1,1} },
    { {3,5},  {-2,9},   {17,45} },
    { {-2,8}, {-3,4},   {-1,1} },
    { {7,3},  {10,7},   {79,21} },
    { {-5,7},  {5,7}, {0,1} },
    { {INT_MAX,0},  {0,0}, {0,0} },
  };

  TESTCASE("Fraction plus fraction");
  char msg[64];
  const FFF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%s) = (%s)",TS(i->f1),TS(i->f2),TS(i->f3));
    TEST(msg,fraction_eq_fraction(fraction_plus_fraction(i->f1,i->f2),i->f3));
  }
}

void test_fraction_minus_fraction()
{
  FFF test_data [] = {
    { {0,1},  {0,1},    {0,1} },
    { {0,1},  {1,1},    {-1,1} },
    { {3,5},  {-2,9},   {37,45} },
    { {-2,8}, {-3,4},   {1,2} },
    { {7,3},  {10,7},   {19,21} },
    { {-5,7},  {5,7}, {-10,7} },
    { {INT_MAX,0},  {0,0}, {0,0} },
  };

  TESTCASE("Fraction minus fraction");
  char msg[64];
  const FFF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) - (%s) = (%s)",TS(i->f1),TS(i->f2),TS(i->f3));
    TEST(msg,fraction_eq_fraction(fraction_minus_fraction(i->f1,i->f2),i->f3));
  }
}

void test_fraction_times_fraction()
{
  FFF test_data [] = {
    { {0,1},  {0,1},    {0,1} },
    { {0,1},  {1,1},    {0,1} },
    { {3,5},  {-2,9},   {-2,15} },
    { {-2,8}, {-3,4},   {3,16} },
    { {7,3},  {10,7},   {10,3} },
    { {-5,7},  {5,7}, {-25,49} },
    { {INT_MAX,0},  {0,0}, {0,0} },
  };

  TESTCASE("Fraction times fraction");
  char msg[64];
  const FFF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) * (%s) = (%s)",TS(i->f1),TS(i->f2),TS(i->f3));
    TEST(msg,fraction_eq_fraction(fraction_times_fraction(i->f1,i->f2),i->f3));
  }
}


void test_fraction_divided_by_fraction()
{
  FFF test_data [] = {
    { {0,1},  {1,1},    {0,1} },
    { {3,5},  {-2,9},   {-27,10} },
    { {-2,8}, {-3,4},   {1,3} },
    { {7,3},  {10,7},   {49,30} },
    { {-5,7},  {5,7}, {-1,1} },
    { {INT_MAX,0},  {0,0}, {0,0} },
  };

  TESTCASE("Fraction divided by fraction");
  char msg[64];
  const FFF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%s) = (%s)",TS(i->f1),TS(i->f2),TS(i->f3));
    TEST(msg,fraction_eq_fraction(fraction_divided_by_fraction(i->f1,i->f2),i->f3));
  }
}

void test_fraction_power_fraction()
{
  FFF test_data [] = {
    { {0,1},  {1,1},    {0,1} },
    { {3,5},  {-2,9},   {643,574} },
    { {1,4}, {-3,4},   {577,204} },
    { {7,3},  {10,7},   {1399,417} },
    { {-5,7},  {-3,1}, {-343,125} },
    { {INT_MAX,0},  {0,0}, {0,0} },
  };

  TESTCASE("Fraction power fraction");
  char msg[64];
  const FFF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) ** (%s) = (%s)",TS(i->f1),TS(i->f2),TS(i->f3));
    TEST(msg,fraction_eq_fraction(fraction_power_fraction(i->f1,i->f2),i->f3));
  }
}
typedef struct {
  fraction_t f1;
  double d;
  fraction_t f2;
} FDF;

void test_fraction_plus_double()
{
  FDF test_data [] = {
    { {0,1},  0.0/1,    {0,1} },
    { {0,1},  1.0/1,    {1,1} },
    { {3,5},  -2.0/9,   {17,45} },
    { {-2,8}, -3.0/4,   {-1,1} },
    { {7,3},  10.0/7,   {79,21} },
    { {-5,7},  5.0/7,   {0,1} },
    { {INT_MAX,0},  0, {0,0} }
  };

  TESTCASE("Fraction plus double");
  char msg[64];
  const FDF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%lg) = (%s)",TS(i->f1),i->d,TS(i->f2));
    TEST(msg,fraction_eq_fraction(fraction_plus_double(i->f1,i->d),i->f2));
  }
}

void test_fraction_minus_double()
{
  FDF test_data [] = {
    { {0,1},  0.0/1,    {0,1} },
    { {0,1},  1.0/1,    {-1,1} },
    { {3,5},  -2.0/9,   {37,45} },
    { {-2,8}, -3.0/4,   {1,2} },
    { {7,3},  10.0/7,   {19,21} },
    { {-5,7},  5.0/7,   {-10,7} },
    { {INT_MAX,0},  0, {0,0} }
  };

  TESTCASE("Fraction plus double");
  char msg[64];
  const FDF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%lg) = (%s)",TS(i->f1),i->d,TS(i->f2));
    TEST(msg,fraction_eq_fraction(fraction_minus_double(i->f1,i->d),i->f2));
  }
}

void test_fraction_times_double()
{
  FDF test_data [] = {
    { {0,1},  0.0/1,    {0,1} },
    { {0,1},  1.0/1,    {0,1} },
    { {3,5},  -2.0/9,   {-2,15} },
    { {-2,8}, -3.0/4,   {3,16} },
    { {7,3},  10.0/7,   {10,3} },
    { {-5,7},  5.0/7,   {-25,49} },
    { {INT_MAX,0},  0, {0,0} }
  };

  TESTCASE("Fraction times double");
  char msg[64];
  const FDF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%lg) = (%s)",TS(i->f1),i->d,TS(i->f2));
    TEST(msg,fraction_eq_fraction(fraction_times_double(i->f1,i->d),i->f2));
  }
}

void test_fraction_divided_by_double()
{
  FDF test_data [] = {
    { {0,1},  1.0/1,    {0,1} },
    { {3,5},  -2.0/9,   {-27,10} },
    { {-2,8}, -3.0/4,   {1,3} },
    { {7,3},  10.0/7,   {49,30} },
    { {-5,7},  5.0/7,   {-1,1} },
    { {INT_MAX,0},  0, {0,0} }
  };

  TESTCASE("Fraction divided by double");
  char msg[64];
  const FDF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) + (%lg) = (%s)",TS(i->f1),i->d,TS(i->f2));
    TEST(msg,fraction_eq_fraction(fraction_divided_by_double(i->f1,i->d),i->f2));
  }
}

void test_fraction_power_double()
{
  FDF test_data [] = {
    { {0,1},  1.0/1,    {0,1} },
    { {3,5},  -2.0/9,   {643,574} },
    { {1,4}, -3.0/4,   {577,204} },
    { {7,3},  10.0/7,   {1399,417} },
    { {-5,7},  -3.0/1, {-343,125} },
    { {INT_MAX,0},  0 , {0,0} },
  };

  TESTCASE("Fraction power double");
  char msg[64];
  const FDF* i;
  for(i=test_data;i->f1.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%s) ** (%g) = (%s)",TS(i->f1),i->d,TS(i->f2));
    TEST(msg,fraction_eq_fraction(fraction_power_double(i->f1,i->d),i->f2));
  }
}

typedef struct {
  double d;
  fraction_t f;
  double r;
} DFD;

void test_double_plus_fraction()
{
  DFD test_data [] = {
    { 0.0/1,  {0,1},    0.0/1 },
    { 0.0/1,  {1,1},    1.0/1 },
    { 3.0/5,  {-2,9},   17.0/45 },
    { -2.0/8, {-3,4},   -1.0/1 },
    { 7.0/3,  {10,7},   79.0/21 },
    { -5.0/7,  {5,7}, 0.0/1 },
    { 0, {INT_MAX,0}, 0 },
  };

  TESTCASE("Double plus fraction");
  char msg[64];
  const DFD* i;
  for(i=test_data;i->f.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%lg) + (%s) = (%lg)",i->d,TS(i->f),i->r);
    TEST(msg,fabs(double_plus_fraction(i->d,i->f)-i->r) < fraction_epsilon);
  }
}

void test_double_minus_fraction()
{
  DFD test_data [] = {
    { 0.0/1,  {0,1},    0.0/1 },
    { 0.0/1,  {1,1},    -1.0/1 },
    { 3.0/5,  {-2,9},   37.0/45 },
    { -2.0/8, {-3,4},   1.0/2 },
    { 7.0/3,  {10,7},   19.0/21 },
    { -5.0/7,  {5,7}, -10.0/7 },
    { 0, {INT_MAX,0}, 0 },
  };

  TESTCASE("Double minus fraction");
  char msg[64];
  const DFD* i;
  for(i=test_data;i->f.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%lg) - (%s) = (%lg)",i->d,TS(i->f),i->r);
    TEST(msg,fabs(double_minus_fraction(i->d,i->f)-i->r) < fraction_epsilon);
  }
}

void test_double_times_fraction()
{
  DFD test_data [] = {
    { 0.0/1,  {0,1},    0.0/1 },
    { 0.0/1,  {1,1},    0.0/1 },
    { 3.0/5,  {-2,9},   -2.0/15 },
    { -2.0/8, {-3,4},   3.0/16 },
    { 7.0/3,  {10,7},   10.0/3 },
    { -5.0/7,  {5,7}, -25.0/49 },
    { 0, {INT_MAX,0}, 0 },
  };

  TESTCASE("Double times fraction");
  char msg[64];
  const DFD* i;
  for(i=test_data;i->f.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%lg) * (%s) = (%lg)",i->d,TS(i->f),i->r);
    TEST(msg,fabs(double_times_fraction(i->d,i->f)-i->r) < fraction_epsilon);
  }
}

void test_double_divided_by_fraction()
{
  DFD test_data [] = {
    { 0.0/1,  {1,1},    0.0/1 },
    { 3.0/5,  {-2,9},   -27.0/10 },
    { -2.0/8, {-3,4},   1.0/3 },
    { 7.0/3,  {10,7},   49.0/30 },
    { -5.0/7,  {5,7}, -1.0/1 },
    { 0, {INT_MAX,0}, 0 },
  };

  TESTCASE("Double divided_by fraction");
  char msg[64];
  const DFD* i;
  for(i=test_data;i->f.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%lg) / (%s) = (%lg)",i->d,TS(i->f),i->r);
    TEST(msg,fabs(double_divided_by_fraction(i->d,i->f)-i->r) < fraction_epsilon);
  }
}

void test_double_power_fraction()
{
  DFD test_data [] = {
    { 0.0/1,  {1,1},    0.0/1 },
    { 3.0/5,  {-2,9},   643.0/574 },
    { 1.0/4, {-3,4},   577.0/204 },
    { 7.0/3,  {10,7},   1399.0/417 },
    { -5.0/7,  {-3,1}, -343.0/125 },
    { 0, {INT_MAX,0}, 0 },
  };

  TESTCASE("Double power fraction");
  char msg[64];
  const DFD* i;
  for(i=test_data;i->f.numerator_ != INT_MAX;i++) {
    sprintf(msg,"(%lg) ** (%s) = (%lg)",i->d,TS(i->f),i->r);
    TEST(msg,fabs(double_power_fraction(i->d,i->f)-i->r) < fraction_epsilon);
  }
}

void test_fraction_neg()
{
  fraction_t f1;
  fraction_t f2;
  char msg[64];
  int test_data[][4] = {
    { 0,1 , 0, 1},
    { 1,1, -1, 1},
    { -3,5, 3, 5},
    { 22,7, -22,7},
  };
  int i,n=ARRAY_SIZE(test_data);
  TESTCASE("Fraction neg");
  for(i=0;i<n;i++) {
    sprintf(msg,"fraction_neg(%d/%d) = (%d/%d)",test_data[i][0],test_data[i][1],
          test_data[i][2],test_data[i][3]);
    S(f1,test_data[i][0],test_data[i][1]);
    f2 = fraction_neg(f1);
    TEST(msg,R(f2,test_data[i][2],test_data[i][3]));
  }
}

void test_fraction_reciprocal()
{
  fraction_t f1;
  fraction_t f2;
  char msg[64];
  int test_data[][4] = {
    { 1,1, 1, 1},
    { -3,5, -5, 3},
    { 22,7, 7,22},
    { -9, 10, -10, 9},
    { 11, 3, 3, 11},
  };
  int i,n=ARRAY_SIZE(test_data);
  TESTCASE("Fraction reciprocal");
  for(i=0;i<n;i++) {
    sprintf(msg,"fraction_reciprocal(%d/%d) = (%d/%d)",test_data[i][0],test_data[i][1],
          test_data[i][2],test_data[i][3]);
    S(f1,test_data[i][0],test_data[i][1]);
    f2 = fraction_reciprocal(f1);
    TEST(msg,R(f2,test_data[i][2],test_data[i][3]));
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

void test_random()
{
  srand(time(NULL));
  int i,numerator,denominator;
  double value;
  fraction_t f = { 0,1 };
  TESTCASE("Random double conversion");
  int sign=1;
  char msg[64];
  for(i=0;i<1000;i++) {
    numerator=sign*rand()%100000;
    denominator=rand()%100000;
    value=(double)numerator/(double)denominator;
    fraction_set_double(&f,value);
    sprintf(msg,"%12.5lf = (%d/%d)",value,numerator,denominator);
    TEST(msg,fabs(value - (double)f.numerator_/(double)f.denominator_) < fraction_epsilon);
    sign=-sign;
  }
}

test_function tests[] =
{
  test_gcd,
  test_fraction_set,
  test_fraction_set_mixed,
  test_fraction_set_double,
  test_fraction_set_string,
  test_fraction_to_s,
  test_fraction_to_mixed_s,
  test_fraction_eq_fraction,
  test_fraction_ne_fraction,
  test_fraction_lt_fraction,
  test_fraction_le_fraction,
  test_fraction_gt_fraction,
  test_fraction_ge_fraction,
  test_fraction_eq_double,
  test_fraction_ne_double,
  test_fraction_lt_double,
  test_fraction_le_double,
  test_fraction_gt_double,
  test_fraction_ge_double,
  test_double_eq_fraction,
  test_double_ne_fraction,
  test_double_lt_fraction,
  test_double_le_fraction,
  test_double_gt_fraction,
  test_double_ge_fraction,
  test_fraction_plus_fraction,
  test_fraction_minus_fraction,
  test_fraction_times_fraction,
  test_fraction_divided_by_fraction,
  test_fraction_power_fraction,
  test_fraction_plus_double,
  test_fraction_minus_double,
  test_fraction_times_double,
  test_fraction_divided_by_double,
  test_fraction_power_double,
  test_double_plus_fraction,
  test_double_minus_fraction,
  test_double_times_fraction,
  test_double_divided_by_fraction,
  test_double_power_fraction,
  test_fraction_neg,
  test_fraction_reciprocal,
  test_round,
  test_random,
};

TEST_MAIN(tests)
