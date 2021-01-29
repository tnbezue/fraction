/*
		Copyright (C) 2019-2020  by Terry N Bezue

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <sstream>
#include <vector>
#include <math.h>
#include "fraction.hh"
#include "test_harness.hh"

using namespace std;

#ifdef MIXED
typedef mixed_fraction_t fraction_type;
const string ftname = "mixed_fraction_t";
#else
typedef fraction_t fraction_type;
const string ftname = "fraction_t";
#endif

void test_init()
{
}

void test_gcd()
{
  int test_data[][3] = { { 0,2,2},{ 10,1,1},{ 105,15,15},{ 10,230,10},{ 28,234,2}, {872452914,78241452,6 }};
  int i,n=ARRAY_SIZE(test_data);

  TESTCASE("Greatest Common Divisor");
  for(i=0;i<n;i++) {
    ostringstream msg;
    msg << ftname << "::gcd(" << test_data[i][0] << ',' << test_data[i][1] << ") = (" << test_data[i][2];
    TEST(msg.str(),fraction_type::gcd(test_data[i][0],test_data[i][1])==test_data[i][2]);
  }
}

#define S(f,n,d) f.set(n,d)
#define SM(f,w,n,d) f.set(w,n,d)
#define R(f,n,d) (f.numerator()==n && f.denominator()==d)
#define TC(f) (typeid(f) == typeid(fraction_type&))
void test_fraction_new_zero_args()
{
  TESTCASE("Fraction new zero arguemtns");
  fraction_type f = fraction_type();
  TEST(ftname+"() = (0/1)",R(fraction_type(),0,1) && TC(f));
}

void test_fraction_new_one_arg()
{
  int test_data[] = { 0, 1, -2, -12, 12};
  for(int i=0;i<5;i++) {
    ostringstream msg;
    msg << ftname << "(" << test_data[i] << ") = (" << test_data[i] << "/1)";
    TEST(msg.str(),R(fraction_type((fraction_numerator_denominator_t)test_data[i]),test_data[i],1));
  }
}

struct IIII {
  int n1;
  int d1;
  int n2;
  int d2;
};

void test_fraction_new_two_args()
{

  TESTCASE("Fraction two integer arguments");
  vector<IIII> test_data = {
    { 0,1,0,1 },
    {1,1,1,1},
    {-2,3,-2,3},
    {2,-3,-2,3},
    {-2,-3,2,3}
  };
  vector<IIII>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << ftname << "(" << i->n1 << ',' << i->d1 << ") = (" << i->n2 << '/' << i->d2 << ')';
    TEST(msg.str(),R(fraction_type(i->n1,i->d1),i->n2,i->d2));
  }
}

typedef struct {
  int w;
  int n1;
  int d1;
  int n2;
  int d2;
} IIIII;

void test_fraction_new_three_args()
{
  TESTCASE("Fraction set WND");
  vector<IIIII> test_data  = {
    { -10,2,3,-32,3 },
    {0,-2,3,-2,3},
    {0,0,1,0,1},
    {0,2,3,2,3},
    {10,2,3,32,3}
  };
  vector<IIIII>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << ftname << "(" << i->w << ',' << i->n1 << ',' << i->d1
        << ") = (" << i->n2 << '/' << i->d2 << ')';
    TEST(msg.str(),R(fraction_type(i->w,i->n1,i->d1),i->n2,i->d2));
  }
}

typedef struct {
  double dbl;
  int n;
  int d;
} DII;

void test_fraction_new_double_arg()
{
  vector<DII> test_data = {
    { 0.0, 0,1 },
    { 1.0, 1,1 },
    { 12.25, 49,4},
    { -2.5,-5,2 },
    { -0.06,-3,50 },
    { 0.3, 3,10 },
    { 0.33, 33,100 },
    { 0.33333333,1,3}
  };
  TESTCASE("Fraction from double");
  vector<DII>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << ftname << "(" << i->dbl << " = (" << i->n << '/' << i->d << ')';
    TEST(msg.str(),R(fraction_type(i->dbl),i->n,i->d));
  }
}

struct SII {
  const char* s;
  int n;
  int d;
};


void test_fraction_new_string_arg()
{
  vector<SII> test_data = {
    { "12.25", 49, 4},
    { "-0.06",-3, 50},
    { "1 1/2",3, 2 },
    { "-3 3/5",-18, 5},
    { "-3 -3/5",18, 5},
    { "-3 -3/-5",-18, 5},
  };
  TESTCASE("Fraction new with string argument");
  vector<SII>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << ftname<< "(\"" << i->s << "\") = (" << i->n << '/' << i->d << ')';
    TEST(msg.str(),R(fraction_type(i->s),i->n,i->d));
  }
}

struct IIS {
  int n;
  int d;
  const char* s;
};

void test_fraction_to_s()
{
#ifdef MIXED
  vector<IIS> test_data = {
    { 0,1, "0"},
    { 2,10, "1/5"},
    { -16,3, "-5 1/3"},
    { 50,3, "16 2/3"},
    { -2,3, "-2/3"},
    { -2,-3, "2/3"}
  };
#else
  vector<IIS> test_data = {
    { 0,1, "0"},
    { 2,10, "1/5"},
    { -16,3, "-16/3"},
    { 3,50, "3/50"},
    { -2,3, "-2/3"},
    { -2,-3, "2/3"}
  };
#endif
  TESTCASE("Fraction to string");
  vector<IIS>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << ftname <<  "(" << i->n << ',' <<  i->d << ").to_s() = \"" << i->s << "\"";
    TEST(msg.str(),fraction_type(i->n,i->d).to_s() == i->s);
  }
}

struct FFB {
  fraction_type f1;
  fraction_type f2;
  bool expected;
};

void test_fraction_eq_fraction()
{
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  true},
    { fraction_type(0,1), fraction_type(1,2),  false},
    { fraction_type(2,3), fraction_type(-2,4), false},
    { fraction_type(2,3), fraction_type(2,3),  true},
    { fraction_type(1,3), fraction_type(1,3),  true},
    { fraction_type(-5,7),fraction_type(5,7),  false}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction equal fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg <<  '(' <<  i->f1  <<  ") == (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 == i->f2) == i->expected);
  }
}

void test_fraction_ne_fraction()
{
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  false},
    { fraction_type(0,1), fraction_type(1,2),  true},
    { fraction_type(2,3), fraction_type(-2,4), true},
    { fraction_type(2,3), fraction_type(2,3),  false},
    { fraction_type(1,3), fraction_type(1,3),  false},
    { fraction_type(-5,7),fraction_type(5,7),  true}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction not equal fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1  <<  ") != (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 != i->f2) == i->expected);
  }
}

void test_fraction_lt_fraction()
{
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  false},
    { fraction_type(0,1), fraction_type(1,2),  true},
    { fraction_type(2,3), fraction_type(-2,4), false},
    { fraction_type(2,3), fraction_type(2,3),  false},
    { fraction_type(1,3), fraction_type(1,3),  false},
    { fraction_type(-5,7),fraction_type(5,7),  true}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction less than fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1  <<  ") < (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 < i->f2) == i->expected);
  }
}

void test_fraction_le_fraction()
{
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  true},
    { fraction_type(0,1), fraction_type(1,2),  true},
    { fraction_type(2,3), fraction_type(-2,4), false},
    { fraction_type(2,3), fraction_type(2,3),  true},
    { fraction_type(1,3), fraction_type(1,3),  true},
    { fraction_type(-5,7),fraction_type(5,7),  true}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction less than or equal fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1  <<  ") <= (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 <= i->f2) == i->expected);
  }
}

void test_fraction_gt_fraction()
{
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  false},
    { fraction_type(0,1), fraction_type(1,2),  false},
    { fraction_type(2,3), fraction_type(-2,4), true},
    { fraction_type(2,3), fraction_type(2,3),  false},
    { fraction_type(1,3), fraction_type(1,3),  false},
    { fraction_type(-5,7),fraction_type(5,7),  false}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction greater than fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1  <<  ") > (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 > i->f2) == i->expected);
  }
}

void test_fraction_ge_fraction()
{
  int ge_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
  vector <FFB> test_data = {
    { fraction_type(0,1), fraction_type(0,1),  true},
    { fraction_type(0,1), fraction_type(1,2),  false},
    { fraction_type(2,3), fraction_type(-2,4), true},
    { fraction_type(2,3), fraction_type(2,3),  true},
    { fraction_type(1,3), fraction_type(1,3),  true},
    { fraction_type(-5,7),fraction_type(5,7),  false}
  };
  vector<FFB>::const_iterator i;
  TESTCASE("Fraction greater than or equal fraction");
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1  <<  ") >= (" << i->f2 << ") - " << ( i->expected ? "true" : "false");
    TEST(msg.str(),(i->f1 >= i->f2) == i->expected);
  }
}

struct FDB {
  fraction_type f;
  double d;
  int expected;
};

void test_fraction_eq_double()
{
  int eq_data[][5] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1},{-5,7,25,35,0}};
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  true},
    { fraction_type(0,1), 1.0/2,  false},
    { fraction_type(2,3), -2.0/4, false},
    { fraction_type(2,3), 2.0/3,  true},
    { fraction_type(1,3), 1.0/3,  true},
    { fraction_type(-5,7),5.0/7,  false}
  };
  TESTCASE("Fraction equal double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") == " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f == i->d) == i->expected);
  }
}

void test_fraction_ne_double()
{
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  false},
    { fraction_type(0,1), 1.0/2,  true},
    { fraction_type(2,3), -2.0/4, true},
    { fraction_type(2,3), 2.0/3,  false},
    { fraction_type(1,3), 1.0/3,  false},
    { fraction_type(-5,7),5.0/7,  true}
  };
  TESTCASE("Fraction not equal double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") != " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f != i->d) == i->expected);
  }
}

void test_fraction_lt_double()
{
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  false},
    { fraction_type(0,1), 1.0/2,  true},
    { fraction_type(2,3), -2.0/4, false},
    { fraction_type(2,3), 2.0/3,  false},
    { fraction_type(1,3), 1.0/3,  false},
    { fraction_type(-5,7),5.0/7,  true}
  };
  TESTCASE("Fraction less than double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") < " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f < i->d) == i->expected);
  }
}

void test_fraction_le_double()
{
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  true},
    { fraction_type(0,1), 1.0/2,  true},
    { fraction_type(2,3), -2.0/4, false},
    { fraction_type(2,3), 2.0/3,  true},
    { fraction_type(1,3), 1.0/3,  true},
    { fraction_type(-5,7),5.0/7,  true}
  };
  TESTCASE("Fraction less than or equal double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") <= " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f <= i->d) == i->expected);
  }
}

void test_fraction_gt_double()
{
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  false},
    { fraction_type(0,1), 1.0/2,  false},
    { fraction_type(2,3), -2.0/4, true},
    { fraction_type(2,3), 2.0/3,  false},
    { fraction_type(1,3), 1.0/3,  false},
    { fraction_type(-5,7),5.0/7,  false}
  };
  TESTCASE("Fraction greater than double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") > " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f > i->d) == i->expected);
  }
}

void test_fraction_ge_double()
{
  vector<FDB> test_data = {
    { fraction_type(0,1), 0.0/1,  true},
    { fraction_type(0,1), 1.0/2,  false},
    { fraction_type(2,3), -2.0/4, true},
    { fraction_type(2,3), 2.0/3,  true},
    { fraction_type(1,3), 1.0/3,  true},
    { fraction_type(-5,7),5.0/7,  false}
  };
  TESTCASE("Fraction greater than or equal double");
  vector<FDB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f << ") >= " << i->d << " - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->f >= i->d) == i->expected);
  }
}
struct DFB {
  double d;
  fraction_type f;
  int expected;
};

void test_double_eq_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  true},
    { 0.0/1, fraction_type(1,2),  false},
    { 2.0/3, fraction_type(-2,4), false},
    { 2.0/3, fraction_type(2,3),  true},
    { 1.0/3, fraction_type(1,3),  true},
    { -5.9/7, fraction_type(5,7),  false}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " == (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d == i->f) == i->expected);
  }
}

void test_double_ne_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  false},
    { 0.0/1, fraction_type(1,2),  true},
    { 2.0/3, fraction_type(-2,4), true},
    { 2.0/3, fraction_type(2,3),  false},
    { 1.0/3, fraction_type(1,3),  false},
    { -5.9/7, fraction_type(5,7),  true}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " != (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d != i->f) == i->expected);
  }
}

void test_double_lt_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  1},
    { 0.0/1, fraction_type(1,2),  0},
    { 2.0/3, fraction_type(-2,4), 0},
    { 2.0/3, fraction_type(2,3),  1},
    { 1.0/3, fraction_type(1,3),  1},
    { -5.9/7, fraction_type(5,7),  0}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " >= (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d == i->f) == i->expected);
  }
}

void test_double_le_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  1},
    { 0.0/1, fraction_type(1,2),  0},
    { 2.0/3, fraction_type(-2,4), 0},
    { 2.0/3, fraction_type(2,3),  1},
    { 1.0/3, fraction_type(1,3),  1},
    { -5.9/7, fraction_type(5,7),  0}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " >= (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d == i->f) == i->expected);
  }
}

void test_double_gt_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  1},
    { 0.0/1, fraction_type(1,2),  0},
    { 2.0/3, fraction_type(-2,4), 0},
    { 2.0/3, fraction_type(2,3),  1},
    { 1.0/3, fraction_type(1,3),  1},
    { -5.9/7, fraction_type(5,7),  0}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " >= (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d == i->f) == i->expected);
  }
}

void test_double_ge_fraction()
{
  vector<DFB> test_data = {
    { 0.0/1, fraction_type(0,1),  1},
    { 0.0/1, fraction_type(1,2),  0},
    { 2.0/3, fraction_type(-2,4), 0},
    { 2.0/3, fraction_type(2,3),  1},
    { 1.0/3, fraction_type(1,3),  1},
    { -5.9/7, fraction_type(5,7),  0}
  };
  TESTCASE("Double equal fraction");
  vector<DFB>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << i->d << " >= (" << i->f << ") - " << (i->expected ? "true" : "false");
    TEST(msg.str(),(i->d == i->f) == i->expected);
  }
}

struct FFF {
  fraction_type f1;
  fraction_type f2;
  fraction_type f3;
};

void test_fraction_plus_fraction()
{
  vector <FFF> test_data = {
    { fraction_type(0,1),fraction_type(0,1),fraction_type(0,1) },
    { fraction_type(0,1),fraction_type(1,1),fraction_type(1,1) },
    { fraction_type(3,5),fraction_type(-2,9),fraction_type(17,45) },
    { fraction_type(-2,8),fraction_type(-6,8),fraction_type(-1,1) },
    { fraction_type(7,3),fraction_type(10,7),fraction_type(79,21) },
    { fraction_type(-5,7),fraction_type(25,35),fraction_type(0,1) }
  };
  TESTCASE("Fraction plus Fraction");
  vector<FFF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") + (" << i->f2 << ") = (" << i->f3 << ')';
    auto f= i->f1 + i->f2;
    TEST(msg.str(),((f == i->f3) && TC(f)));
  }
}

void test_fraction_minus_fraction()
{
  vector <FFF> test_data = {
    { fraction_type(0,1),fraction_type(0,1),fraction_type(0,1) },
    { fraction_type(0,1),fraction_type(1,1),fraction_type(-1,1) },
    { fraction_type(3,5),fraction_type(-2,9),fraction_type(37,45) },
    { fraction_type(-2,8),fraction_type(-6,8),fraction_type(1,2) },
    { fraction_type(7,3),fraction_type(10,7),fraction_type(19,21) },
    { fraction_type(-5,7),fraction_type(25,35),fraction_type(-10,7) }
  };
  TESTCASE("Fraction minus fraction");
  vector<FFF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") - (" << i->f2 << ") = (" << i->f3 << ')';
    auto f= i->f1 - i->f2;
    TEST(msg.str(),((f == i->f3) && TC(f)));
  }
}

void test_fraction_times_fraction()
{
  vector <FFF> test_data = {
    { fraction_type(0,1),fraction_type(0,1),fraction_type(0,1) },
    { fraction_type(0,1),fraction_type(1,1),fraction_type(0,1) },
    { fraction_type(3,5),fraction_type(-2,9),fraction_type(-2,15) },
    { fraction_type(-2,8),fraction_type(-6,8),fraction_type(3,16) },
    { fraction_type(7,3),fraction_type(10,7),fraction_type(10,3) },
    { fraction_type(-5,7),fraction_type(25,35),fraction_type(-25,49) }
  };
  TESTCASE("Fraction times fraction");
  vector<FFF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") * (" << i->f2 << ") = (" << i->f3 << ')';
    auto f= i->f1 * i->f2;
    TEST(msg.str(),((f == i->f3) && TC(f)));
  }
}

void test_fraction_divided_by_fraction()
{
  vector <FFF> test_data = {
    { fraction_type(0,1),fraction_type(1,1),fraction_type(0,1) },
    { fraction_type(3,5),fraction_type(-2,9),fraction_type(-27,10) },
    { fraction_type(-2,8),fraction_type(-6,8),fraction_type(1,3) },
    { fraction_type(7,3),fraction_type(10,7),fraction_type(49,30) },
    { fraction_type(-5,7),fraction_type(25,35),fraction_type(-1,1) }
  };
  TESTCASE("Fraction divided by fraction");
  vector<FFF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") / (" << i->f2 << ") = (" << i->f3 << ')';
    auto f= i->f1 / i->f2;
    TEST(msg.str(),((f == i->f3) && TC(f)));
  }
}

void test_fraction_power_fraction()
{
  vector <FFF> test_data = {
    { fraction_type(0,1),fraction_type(1,1),fraction_type(0,1) },
    { fraction_type(3,5),fraction_type(-2,9),fraction_type(643,574) },
    { fraction_type(1,4),fraction_type(-3,4),fraction_type(577,204) },
    { fraction_type(7,3),fraction_type(10,7),fraction_type(1399,417) },
    { fraction_type(-5,7),fraction_type(-3,1),fraction_type(-343,125) }
  };
  TESTCASE("Fraction power fraction");
  vector<FFF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") ** (" << i->f2 << ") = (" << i->f3 << ')';
    auto f= pow(i->f1,i->f2);
    TEST(msg.str(),((f == i->f3) && TC(f)));
  }
}

struct FDF {
  fraction_type f1;
  double d;
  fraction_type f2;
};
void test_fraction_plus_double()
{
  vector <FDF> test_data = {
    { fraction_type(0,1),0.0/1,fraction_type(0,1) },
    { fraction_type(0,1),1.0/1,fraction_type(1,1) },
    { fraction_type(3,5),-2.0/9,fraction_type(17,45) },
    { fraction_type(-2,8),-3.0/4,fraction_type(-1,1) },
    { fraction_type(7,3),10.0/7,fraction_type(79,21) },
    { fraction_type(-5,7),5.0/7,fraction_type(0,1) }
  };
  TESTCASE("Fraction plus double");
  vector<FDF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") + (" << i->d << ") = (" << i->f2 << ')';
    auto f= i->f1 + i->d;
    TEST(msg.str(),((f == i->f2) && TC(f)));
  }
}

void test_fraction_minus_double()
{
  vector <FDF> test_data = {
    { fraction_type(0,1),0.0/1,fraction_type(0,1) },
    { fraction_type(0,1),1.0/1,fraction_type(-1,1) },
    { fraction_type(3,5),-2.0/9,fraction_type(37,45) },
    { fraction_type(-2,8),-3.0/4,fraction_type(1,2) },
    { fraction_type(7,3),10.0/7,fraction_type(19,21) },
    { fraction_type(-5,7),5.0/7,fraction_type(-10,7) }
  };
  TESTCASE("Fraction minus double");
  vector<FDF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") - (" << i->d << ") = (" << i->f2 << ')';
    auto f= i->f1 - i->d;
    TEST(msg.str(),((f == i->f2) && TC(f)));
  }
}

void test_fraction_times_double()
{
  vector <FDF> test_data = {
    { fraction_type(0,1),0.0/1,fraction_type(0,1) },
    { fraction_type(0,1),1.0/1,fraction_type(0,1) },
    { fraction_type(3,5),-2.0/9,fraction_type(-2,15) },
    { fraction_type(-2,8),-3.0/4,fraction_type(3,16) },
    { fraction_type(7,3),10.0/7,fraction_type(10,3) },
    { fraction_type(-5,7),5.0/7,fraction_type(-25,49) }
  };
  TESTCASE("Fraction times double");
  vector<FDF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") * (" << i->d << ") = (" << i->f2 << ')';
    auto f= i->f1 * i->d;
    TEST(msg.str(),((f == i->f2) && TC(f)));
  }
}

void test_fraction_divided_by_double()
{
  vector <FDF> test_data = {
    { fraction_type(0,1),1.0/1,fraction_type(0,1) },
    { fraction_type(3,5),-2.0/9,fraction_type(-27,10) },
    { fraction_type(-2,8),-3.0/4,fraction_type(1,3) },
    { fraction_type(7,3),10.0/7,fraction_type(49,30) },
    { fraction_type(-5,7),5.0/7,fraction_type(-1,1) }
  };
  TESTCASE("Fraction divided by double");
  vector<FDF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") / (" << i->d << ") = (" << i->f2 << ')';
    auto f= i->f1 / i->d;
    TEST(msg.str(),((f == i->f2) && TC(f)));
  }
}

void test_fraction_power_double()
{
  vector <FDF> test_data = {
    { fraction_type(0,1),1.0/1,fraction_type(0,1) },
    { fraction_type(3,5),-2.0/9,fraction_type(643,574) },
    { fraction_type(1,4),-3.0/4,fraction_type(577,204) },
    { fraction_type(7,3),10.0/7,fraction_type(1399,417) },
    { fraction_type(-5,7),-3.0/1,fraction_type(-343,125) }
  };
  TESTCASE("Fraction power double");
  vector<FDF>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->f1 << ") ** (" << i->d << ") = (" << i->f2 << ')';
    auto f= pow(i->f1,i->d);
    TEST(msg.str(),((f == i->f2) && TC(f)));
  }
}

struct DFD {
  double d;
  fraction_type f;
  double r;
};

void test_double_plus_fraction()
{
  vector <DFD> test_data = {
    { 0.0/1,fraction_type(0,1),0.0/1 },
    { 0.0/1,fraction_type(1,1),1.0/1 },
    { 3.0/5,fraction_type(-2,9),17.0/45 },
    { -1.0/4,fraction_type(-6,8),-1.0/1 },
    { 7.0/3,fraction_type(10,7),79.0/21 },
    { -5.0/7,fraction_type(25,35),0.0/1 }
  };
  TESTCASE("Double plus fraction");
  vector<DFD>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->d << ") + (" << i->f << ") = (" << i->r << ')';
    auto r= i->d + i->f;
    TEST(msg.str(),fabs(r - i->r)<fraction_type::epsilon && typeid(r) == typeid(double&));
  }
}

void test_double_minus_fraction()
{
  vector <DFD> test_data = {
    { 0.0/1,fraction_type(0,1),0.0/1 },
    { 0.0/1,fraction_type(1,1),-1.0/1 },
    { 3.0/5,fraction_type(-2,9),37.0/45 },
    { -1.0/4,fraction_type(-6,8),1.0/2 },
    { 7.0/3,fraction_type(10,7),19.0/21 },
    { -5.0/7,fraction_type(25,35),-10.0/7 }
  };
  TESTCASE("Double minus fraction");
  vector<DFD>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->d << ") - (" << i->f << ") = (" << i->r << ')';
    auto r= i->d - i->f;
    TEST(msg.str(),fabs(r - i->r)<fraction_type::epsilon && typeid(r) == typeid(double&));
  }
}

void test_double_times_fraction()
{
  vector <DFD> test_data = {
    { 0.0/1,fraction_type(0,1),0.0/1 },
    { 0.0/1,fraction_type(1,1),0.0/1 },
    { 3.0/5,fraction_type(-2,9),-2.0/15 },
    { -1.0/4,fraction_type(-6,8),3.0/16 },
    { 7.0/3,fraction_type(10,7),10.0/3 },
    { -5.0/7,fraction_type(25,35),-25.0/49 }
  };
  TESTCASE("Double times fraction");
  vector<DFD>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->d << ") * (" << i->f << ") = (" << i->r << ')';
    auto r= i->d * i->f;
    TEST(msg.str(),fabs(r - i->r)<fraction_type::epsilon && typeid(r) == typeid(double&));
  }
}

void test_double_divided_by_fraction()
{
  vector <DFD> test_data = {
    { 0.0/1,fraction_type(1,1),0.0/1 },
    { 3.0/5,fraction_type(-2,9),-27.0/10 },
    { -1.0/4,fraction_type(-6,8),1.0/3 },
    { 7.0/3,fraction_type(10,7),49.0/30 },
    { -5.0/7,fraction_type(25,35),-1.0/1 }
  };
  TESTCASE("Double divided by fraction");
  vector<DFD>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->d << ") / (" << i->f << ") = (" << i->r << ')';
    auto r= i->d / i->f;
    TEST(msg.str(),fabs(r - i->r)<fraction_type::epsilon && typeid(r) == typeid(double&));
  }
}

void test_double_power_fraction()
{
  vector <DFD> test_data = {
    { 0.0/1,fraction_type(1,1),0.0/1 },
    { 3.0/5,fraction_type(-2,9),643.0/574 },
    { 1.0/4,fraction_type(-3,4),577.0/204 },
    { 7.0/3,fraction_type(10,7), 1399.0/417},
    { -5.0/7,fraction_type(-3,1), -343.0/125}
  };
  TESTCASE("Double power fraction");
  vector<DFD>::const_iterator i;
  for(i=test_data.cbegin();i!=test_data.cend();i++) {
    ostringstream msg;
    msg << '(' << i->d << ") ** (" << i->f << ") = (" << i->r << ')';
    auto r= pow(i->d,i->f);
    TEST(msg.str(),fabs(r - i->r)<fraction_type::epsilon && typeid(r) == typeid(double&));
  }
}

void test_fraction_reciprocal()
{
  fraction_type f1;
  fraction_type f2;
  int test_data[][4] = {
    { 1,1, 1, 1},
    { -3,5, -5, 3},
    { 22,7, 7,22},
    { -9, 10, -10, 9},
    { 11, 3, 3, 11}
  };
  int i,n=ARRAY_SIZE(test_data);
  TESTCASE("Fraction reciprocal");
  for(i=0;i<n;i++) {
    ostringstream msg;
    msg << '(' << test_data[i][0] << ',' << test_data[i][1] << ").reciprocal = ("
            << test_data[i][2] << ',' << test_data[i][3] << ')';
    S(f1,test_data[i][0],test_data[i][1]);
    f2 = f1.reciprocal();
    TEST(msg.str(),R(f2,test_data[i][2],test_data[i][3]));
  }
}

void test_round()
{
  int round_data[][5] = { {3333,10000,10,3,10}, {3333,10000,100,33,100},
        {639,5176,100,3,25}, { 2147483647,106197, 1000, 10110849,500}};
  TESTCASE("Fraction round");
  fraction_type f;

  int i,n=ARRAY_SIZE(round_data);
  for(i=0;i<n;i++) {
    ostringstream msg;
    msg << "Round(" << round_data[i][0] << '/' << round_data[i][1] << ',' << round_data[i][2]
            << ") = " << round_data[i][3] << '/' << round_data[i][4];
    S(f,round_data[i][0],round_data[i][1]);
    f.round(round_data[i][2]);
    TEST(msg.str(),R(f,round_data[i][3],round_data[i][4]));
  }

}

void test_random()
{
  srand(time(NULL));
  int i,numerator,denominator;
  double value;
  fraction_type f;
  TESTCASE("Random double conversion");
  int sign=1;
  for(i=0;i<1000;i++) {
    ostringstream msg;
    numerator=sign*rand()%100000;
    denominator=rand()%100000;
    value=static_cast<double>(numerator)/static_cast<double>(denominator);
    f=value;
    msg << setw(12) << setprecision(6) << value << " = (" << numerator << "/" << denominator <<")";
    TEST(msg.str(),fabs(value - static_cast<double>(f)) < fraction_type::epsilon);
    sign=-sign;
  }

}

test_function tests[] =
{
  test_gcd,
  test_fraction_new_zero_args,
  test_fraction_new_one_arg,
  test_fraction_new_two_args,
  test_fraction_new_three_args,
  test_fraction_new_double_arg,
  test_fraction_new_string_arg,
  test_fraction_to_s,
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
  test_fraction_reciprocal,
  test_round,
  test_random,
};

TEST_MAIN(tests)
