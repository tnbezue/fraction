import std.stdio;
import std.math;
import std.conv;
import std.string;
import Fraction;
import TestHarness;

TestHarness th;
void test_init()
{
}

void test_gcd()
{
  int[][] test_gcd_data =
  [
    [ 0,2,2],
    [10,1,1],
    [105,15,15],
    [10,230,10],
    [28,234,2],
    [872452914,78241452,2]
  ];

  Fraction f=new Fraction;
  for(int i=0;i<test_gcd_data.length;i++) {
    th.Test(format("GCD(%s/%s)==%s",test_gcd_data[i][0],test_gcd_data[i][1],test_gcd_data[i][2]),f.gcd(test_gcd_data[i][0],test_gcd_data[i][0]) == test_gcd_data[i][0]);
  }
}

void test_set() {
  int[][] test_set_data =
  [
    [0,1,0,1],
    [1,-3,-1,3],
    [-1,-3,1,3],
    [-6,-8,3,4],
    [2,4,1,2]
  ];

  th.TestCase("Fraction Set(n,d)");
  Fraction f=new Fraction;
  for(int i=0;i<test_set_data.length;i++) {
    f.set(test_set_data[i][0],test_set_data[i][1]);
    th.Test(format("Set(%s,%s) = %s/%s",test_set_data[i][0],test_set_data[i][1],test_set_data[i][2],test_set_data[i][3]),
          f.numerator()==test_set_data[i][2] && f.denominator()==test_set_data[i][3]);
  }
}

void test_set_wnd() {
  int[][] test_set_wnd_data =
  [
    [-10,2,3,-32,3],
    [0,-1,3,-1,3],
    [0,0,1,0,1],
    [0,1,3,1,3],
    [10,2,3,32,3],
  ];

  th.TestCase("Fraction Set(w,n,d)");
  Fraction f=new Fraction;

  for(int i=0;i<test_set_wnd_data.length;i++) {
    f.set(test_set_wnd_data[i][0],test_set_wnd_data[i][1],test_set_wnd_data[i][2]);
    th.Test(format("Set(%s,%s,%s) = %s/%s",test_set_wnd_data[i][0],test_set_wnd_data[i][1],
          test_set_wnd_data[i][2],test_set_wnd_data[i][3],test_set_wnd_data[i][4]),
          f.numerator()==test_set_wnd_data[i][3] && f.denominator()==test_set_wnd_data[i][4]);
  }
}


void test_set_double()
{
  double [] test_set_double_input = [ 0.0, 1.0, 12.25, -2.5, -0.06,0.3,0.33,0.3333333];
  int [][] test_set_double_output = [
    [0,1] , [ 1,1] , [ 49, 4 ], [-5,2 ], [ -3, 50 ], [3,10] , [ 33,100], [1,3]
  ];
  Fraction f = new Fraction;

  for(int i=0;i<test_set_double_input.length;i++) {
    f.set(test_set_double_input[i]);
    th.Test(format("Set(%s) = %s/%s",test_set_double_input[i],test_set_double_output[i][0],test_set_double_output[i][1]),
          f.numerator()==test_set_double_output[i][0] && f.denominator()==test_set_double_output[i][1]);
  }
}

void test_equality()
{
  int [][] test_equality_data = [
    [0,1,0,1,1],
    [0,1,1,2,0],
    [2,3,-2,3,0],
    [2,3,16,24,1],
    [1,3,1,3,1],
    [-5,7,25,35,0]
  ];
  th.TestCase("Fraction equality");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_equality_data.length;i++) {
    f1.set(test_equality_data[i][0],test_equality_data[i][1]);
    f2.set(test_equality_data[i][2],test_equality_data[i][3]);
    if(test_equality_data[i][4]==1)
      th.Test(format(" (%s/%s == %s/%s)",test_equality_data[i][0],test_equality_data[i][1],test_equality_data[i][2],
          test_equality_data[i][3]),f1==f2);
    else
      th.Test(format("!(%s/%s == %s/%s)",test_equality_data[i][0],test_equality_data[i][1],test_equality_data[i][2],
          test_equality_data[i][3]),!(f1==f2));
  }
}

void test_inequality()
{
  int [][] test_inequality_data = [
    [0,1,0,1,0],
    [0,1,1,2,1],
    [2,3,-2,3,1],
    [2,3,16,24,0],
    [1,3,1,3,0],
    [-5,7,25,35,1]
  ];
  th.TestCase("Fraction inequality");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_inequality_data.length;i++) {
    f1.set(test_inequality_data[i][0],test_inequality_data[i][1]);
    f2.set(test_inequality_data[i][2],test_inequality_data[i][3]);
    if(test_inequality_data[i][4]==1)
      th.Test(format(" (%s/%s != %s/%s)",test_inequality_data[i][0],test_inequality_data[i][1],test_inequality_data[i][2],
          test_inequality_data[i][3]),f1!=f2);
    else
      th.Test(format("!(%s/%s != %s/%s)",test_inequality_data[i][0],test_inequality_data[i][1],test_inequality_data[i][2],
          test_inequality_data[i][3]),!(f1!=f2));
  }
}

void test_less_than()
{
  int [][] test_less_than_data = [
    [0,1,0,1,0],
    [0,1,1,2,1],
    [2,3,-2,3,0],
    [2,3,16,24,0],
    [1,3,1,3,0],
    [-5,7,25,35,1]
  ];
  th.TestCase("Less than");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_less_than_data.length;i++) {
    f1.set(test_less_than_data[i][0],test_less_than_data[i][1]);
    f2.set(test_less_than_data[i][2],test_less_than_data[i][3]);
    if(test_less_than_data[i][4]==1)
      th.Test(format(" (%s/%s < %s/%s)",test_less_than_data[i][0],test_less_than_data[i][1],test_less_than_data[i][2],
          test_less_than_data[i][3]),f1<f2);
    else
      th.Test(format("!(%s/%s < %s/%s)",test_less_than_data[i][0],test_less_than_data[i][1],test_less_than_data[i][2],
          test_less_than_data[i][3]),!(f1<f2));
  }

}

void test_less_than_equal()
{
  int [][] test_less_than_equal_data = [
    [0,1,0,1,1],
    [0,1,1,2,1],
    [2,3,-2,3,0],
    [2,3,16,24,1],
    [1,3,1,3,1],
    [-5,7,25,35,1]
  ];
  th.TestCase("Less than or equal");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_less_than_equal_data.length;i++) {
    f1.set(test_less_than_equal_data[i][0],test_less_than_equal_data[i][1]);
    f2.set(test_less_than_equal_data[i][2],test_less_than_equal_data[i][3]);
    if(test_less_than_equal_data[i][4]==1)
      th.Test(format(" (%s/%s <= %s/%s)",test_less_than_equal_data[i][0],test_less_than_equal_data[i][1],test_less_than_equal_data[i][2],
          test_less_than_equal_data[i][3]),f1<=f2);
    else
      th.Test(format("!(%s/%s <= %s/%s)",test_less_than_equal_data[i][0],test_less_than_equal_data[i][1],test_less_than_equal_data[i][2],
          test_less_than_equal_data[i][3]),!(f1<=f2));
  }

}

void test_greater_than()
{
  int [][] test_greater_than_data = [
    [0,1,0,1,0],
    [0,1,1,2,0],
    [2,3,-2,3,1],
    [2,3,16,24,0],
    [1,3,1,3,0],
    [-5,7,25,35,0]
  ];
  th.TestCase("Greater than");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_greater_than_data.length;i++) {
    f1.set(test_greater_than_data[i][0],test_greater_than_data[i][1]);
    f2.set(test_greater_than_data[i][2],test_greater_than_data[i][3]);
    if(test_greater_than_data[i][4]==1)
      th.Test(format(" (%s/%s > %s/%s)",test_greater_than_data[i][0],test_greater_than_data[i][1],test_greater_than_data[i][2],
          test_greater_than_data[i][3]),f1>f2);
    else
      th.Test(format("!(%s/%s > %s/%s)",test_greater_than_data[i][0],test_greater_than_data[i][1],test_greater_than_data[i][2],
          test_greater_than_data[i][3]),!(f1>f2));
  }

}

void test_greater_than_equal()
{
  int [][] test_greater_than_equal_data = [
    [0,1,0,1,1],
    [0,1,1,2,0],
    [2,3,-2,3,1],
    [2,3,16,24,1],
    [1,3,1,3,1],
    [-5,7,25,35,0]
  ];
  th.TestCase("Greater than or equal");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;

  for(int i=0;i<test_greater_than_equal_data.length;i++) {
    f1.set(test_greater_than_equal_data[i][0],test_greater_than_equal_data[i][1]);
    f2.set(test_greater_than_equal_data[i][2],test_greater_than_equal_data[i][3]);
    if(test_greater_than_equal_data[i][4]==1)
      th.Test(format(" (%s/%s >= %s/%s)",test_greater_than_equal_data[i][0],test_greater_than_equal_data[i][1],test_greater_than_equal_data[i][2],
          test_greater_than_equal_data[i][3]),f1>=f2);
    else
      th.Test(format("!(%s/%s >= %s/%s)",test_greater_than_equal_data[i][0],test_greater_than_equal_data[i][1],test_greater_than_equal_data[i][2],
          test_greater_than_equal_data[i][3]),!(f1>=f2));
  }

}

void test_cast_to_double()
{
  Fraction f=new Fraction;

  th.TestCase("Fraction to double");
  int [][] test_to_double_input = [ [0,1], [1,1], [-1,1] , [-3,50], [49,4 ] ];
  double [] test_to_double_output = [ 0.0, 1.0, -1.0, -0.06, 12.25 ];

  for(int i=0;i<test_to_double_input.length;i++) {
    f.set(test_to_double_input[i][0],test_to_double_input[i][1]);
    th.Test(format("%s/%s = %s",test_to_double_input[i][0],test_to_double_input[i][1],test_to_double_output[i]),
          fabs(cast(double)f - test_to_double_output[i]) < f.epsilon);
  }
}

void test_fraction_addition()
{
  int [][] test_addition_data =
  [
    [0,1,0,1,0,1],
    [0,1,1,1,1,1],
    [3,5,-2,9,17,45],
    [-2,8,-6,8,-1,1],
    [7,3,10,7,79,21],
    [-5,7,25,35,0,1]
  ];

  th.TestCase("Fraction addition");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;
  Fraction f3;

  for(int i=0;i<test_addition_data.length;i++) {
    f1.set(test_addition_data[i][0],test_addition_data[i][1]);
    f2.set(test_addition_data[i][2],test_addition_data[i][3]);
    f3=f1+f2;
    th.Test(format("%s/%s + %s/%s = %s/%s",test_addition_data[i][0],test_addition_data[i][1],
          test_addition_data[i][2],test_addition_data[i][3],
          test_addition_data[i][4],test_addition_data[i][5]),
          f3.numerator()==test_addition_data[i][4] && f3.denominator()==test_addition_data[i][5]);
  }
}

void test_fraction_subtraction()
{
  int [][] test_subtraction_data =
  [
    [0,1,0,1,0,1],
    [0,1,1,1,-1,1],
    [3,5,-2,9,37,45],
    [-2,8,-6,8,1,2],
    [7,3,10,7,19,21],
    [-5,7,25,35,-10,7]
  ];

  th.TestCase("Fraction subtraction");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;
  Fraction f3;

  for(int i=0;i<test_subtraction_data.length;i++) {
    f1.set(test_subtraction_data[i][0],test_subtraction_data[i][1]);
    f2.set(test_subtraction_data[i][2],test_subtraction_data[i][3]);
    f3=f1-f2;
    th.Test(format("%s/%s - %s/%s = %s/%s",test_subtraction_data[i][0],test_subtraction_data[i][1],
          test_subtraction_data[i][2],test_subtraction_data[i][3],
          test_subtraction_data[i][4],test_subtraction_data[i][5]),
          f3.numerator()==test_subtraction_data[i][4] && f3.denominator()==test_subtraction_data[i][5]);
  }
}

void test_fraction_multiplication()
{
  int [][] test_multiplication_data =
  [
    [0,1,0,1,0,1],
    [0,1,1,1,0,1],
    [3,5,-2,9,-2,15],
    [-2,8,-6,8,3,16],
    [7,3,10,7,10,3],
    [-5,7,25,35,-25,49]
  ];

  th.TestCase("Fraction multiplication");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;
  Fraction f3;

  for(int i=0;i<test_multiplication_data.length;i++) {
    f1.set(test_multiplication_data[i][0],test_multiplication_data[i][1]);
    f2.set(test_multiplication_data[i][2],test_multiplication_data[i][3]);
    f3=f1*f2;
    th.Test(format("(%s/%s) * (%s/%s) = %s/%s",test_multiplication_data[i][0],test_multiplication_data[i][1],
          test_multiplication_data[i][2],test_multiplication_data[i][3],
          test_multiplication_data[i][4],test_multiplication_data[i][5]),
          f3.numerator()==test_multiplication_data[i][4] && f3.denominator()==test_multiplication_data[i][5]);
  }
}

void test_fraction_division()
{
  int [][] test_division_data =
  [
    [0,1,1,1,0,1],
    [3,5,-2,9,-27,10],
    [-2,8,-6,8,1,3],
    [7,3,10,7,49,30],
    [-5,7,25,35,-1,1]
  ];

  th.TestCase("Fraction division");
  Fraction f1=new Fraction;
  Fraction f2=new Fraction;
  Fraction f3;

  for(int i=0;i<test_division_data.length;i++) {
    f1.set(test_division_data[i][0],test_division_data[i][1]);
    f2.set(test_division_data[i][2],test_division_data[i][3]);
    f3=f1/f2;
    th.Test(format("(%s/%s) / (%s/%s) = %s/%s",test_division_data[i][0],test_division_data[i][1],
          test_division_data[i][2],test_division_data[i][3],
          test_division_data[i][4],test_division_data[i][5]),
          f3.numerator()==test_division_data[i][4] && f3.denominator()==test_division_data[i][5]);
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

void test_fraction_to_string()
{
  int [][] fraction_to_string_input = [ [-503,50], [-3,50], [0,1], [3,50], [503,50]];
  string [] fraction_to_string_output = [ "-503/50", "-3/50" , "0", "3/50" , "503/50"];
  Fraction f = new Fraction;
  th.TestCase("Fraction toString");

  for(int i=0;i<fraction_to_string_input.length;i++) {
    f.set(fraction_to_string_input[i][0],fraction_to_string_input[i][1]);
    th.Test(format("toString(%s/%s) = \"%s\"",fraction_to_string_input[i][0],fraction_to_string_input[i][1],
          fraction_to_string_output[i]),f.toString()==fraction_to_string_output[i]);
  }
}

void test_fraction_to_string_mixed()
{
  int [][] fraction_to_string_mixed_input = [ [-503,50], [-3,50], [0,1], [3,50], [503,50]];
  string [] fraction_to_string_mixed_output = [ "-10 3/50", "-3/50" , "0", "3/50" , "10 3/50"];
  Fraction f = new Fraction;
  th.TestCase("Fraction toStringMixed");

  for(int i=0;i<fraction_to_string_mixed_input.length;i++) {
    f.set(fraction_to_string_mixed_input[i][0],fraction_to_string_mixed_input[i][1]);
    th.Test(format("toStringMixed(%s/%s) = \"%s\"",fraction_to_string_mixed_input[i][0],fraction_to_string_mixed_input[i][1],
          fraction_to_string_mixed_output[i]),f.toStringMixed()==fraction_to_string_mixed_output[i]);
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

void function() [] tests =
[
  &test_gcd,
  &test_set,
  &test_set_wnd,
  &test_set_double,
  &test_equality,
  &test_inequality,
  &test_less_than,
  &test_less_than_equal,
  &test_greater_than,
  &test_greater_than_equal,
  &test_cast_to_double,
  &test_fraction_addition,
  &test_fraction_subtraction,
  &test_fraction_multiplication,
  &test_fraction_division,
  &test_assign_int,
  &test_assign_double,
  &test_fraction_to_string,
  &test_fraction_to_string_mixed,
  &test_fraction_round
];

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
