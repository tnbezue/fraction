
public class TestFraction
{

  static void TestGCD()
  {
    int gcd_test_data[][]= { {6,2,1}, {10,1,1}, {105,15,15}, {10,230,10}, {28,234,2}, {872452914,78241452,6} };
    TestHarness.TestCase("Greatest common denominator");

    for(int i=0;i<gcd_test_data.length;i++) {
      String s;
      TestHarness.Test("GCD("+gcd_test_data[i][0]+","+gcd_test_data[i][1]+") = "+gcd_test_data[i][2],
            Fraction.gcd(0,2)==2);
    }
  }

  static void S(Fraction f,long n,long d)
  {
    f.set(n,d);
  }

  static void S(Fraction f,long w,long n,long d)
  {
    f.set(w,n,d);
  }

  static boolean R(Fraction f,long n,long d)
  {
//    System.out.println(f.numerator()+" "+f.denominator());
    return f.numerator() == n && f.denominator() == d;
  }

  static void TestSet()
  {
    TestHarness.TestCase("Fraction Set");
    Fraction f = new Fraction();
    int i;

    int set_data[] = { 15, -10 };
    for(i=0;i<set_data.length;i++) {
      f.set(set_data[i]);
      TestHarness.Test("Set("+set_data[i] + ") = "+set_data[i]+"/1",R(f,set_data[i],1));
    }

    long set_nd_data[][] = {
      { 1,-3,-1,3}, {-1,-3,1,3}, {-6,8,-3,4}, {2,4,1,2},{10,7,10,7},
      { 17179869183L,68719476736L, 536870912L,2147483647L}, { 68719476736L,17179869183L,2147483647L,536870912L }
    , { -17179869183L,68719476736L, -536870912L,2147483647L}, { -68719476736L,17179869183L,-2147483647L,536870912L }
    };
    for(i=0;i<set_nd_data.length;i++) {
      f.set(set_nd_data[i][0],set_nd_data[i][1]);
      TestHarness.Test("Set("+set_nd_data[i][0] + "," + set_nd_data[i][1] + ") = "+set_nd_data[i][2]+"/"
          +set_nd_data[i][2],R(f,set_nd_data[i][2],set_nd_data[i][3]));
    }

    int set_wnd_data[][] = {
      { -10,2,3,-32,3}, { 0, -2, 3, -2,3}, { 0,0,1,0,1}, {0,2,3,2,3}, {10,2,3,32,3}
    };
    for(i=0;i<set_wnd_data.length;i++) {
      f.set(set_wnd_data[i][0],set_wnd_data[i][1],set_wnd_data[i][2]);
      TestHarness.Test("Set("+set_wnd_data[i][0] + "," + set_wnd_data[i][1] + set_wnd_data[i][2] +") = "
          +set_wnd_data[i][3]+"/"+set_wnd_data[i][4],R(f,set_wnd_data[i][3],set_wnd_data[i][4]));
    }

    double set_double_input[] = { -2.06, -0.06, 0.0, 0.06, 2.06, 0.3, 0.33, 0.33333333};
    int set_double_output[][] = { { -103,50}, {-3,50}, {0, 1}, {3,50} , {103,50}, {3,10}, {33,100}, {1,3} };

    for(i=0;i<set_double_input.length;i++) {
      f.set(set_double_input[i]);
      TestHarness.Test("Set("+set_double_input[i] +") = "+set_double_output[i][0]
            +"/"+set_double_output[i][1],R(f,set_double_output[i][0],set_double_output[i][1]));
    }

    String set_string_input[]= { "12","12.25", "12 1/4"};
    int set_string_output[][]= { { 12,1 }, {49,4}, {49,4}};
    for(i=0;i<set_string_input.length;i++) {
      f.set(set_string_input[i]);
      TestHarness.Test("Set("+set_string_input[i] +") = "+set_string_output[i][0]
            +"/"+set_string_output[i][1],R(f,set_string_output[i][0],set_string_output[i][1]));
    }
  }

  static void TestConstructor()
  {
    TestHarness.TestCase("Constructors");

    Fraction f = new Fraction();
    TestHarness.Test("Default constructor = 0/1",R(f,0,1));

    f = new Fraction(2,3);
    TestHarness.Test("Fraction(2,3) = 2/3",R(f,2,3));

    TestHarness.Test("Fraction(Fraction(2,3)) = 2/3",R(new Fraction(f),2,3));

    f = new Fraction(2,-3);
    TestHarness.Test("Fraction(2,-3) = -2/3",R(f,-2,3));

    f = new Fraction(-6,8);
    TestHarness.Test("Fraction(-6,8) = -3/4",R(f,-3,4));

    f = new Fraction(10,0,3);
    TestHarness.Test("Fraction(10,0,3) = 10/1",R(f,10,1));

    f = new Fraction(-10,2,3);
    TestHarness.Test("Fraction(-10,2,3) = -32/3",R(f,-32,3));
  }

  static void TestAdd()
  {
    TestHarness.TestCase("Fraction addition");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int plus_data[][] = { { 0,1,0,1,0,1}, {0,1,1,1,1,1}, {3,5,-2,9,17,45}, {-2,8,-6,8,-1,1},
          {7,3,10,7,79,21}, {-5,7,25,35,0,1}};

    int i;
    for(i=0;i<plus_data.length;i++) {
      S(f1,plus_data[i][0],plus_data[i][1]);
      S(f2,plus_data[i][2],plus_data[i][3]);
      f3=Fraction.add(f1,f2);
      TestHarness.Test("("+plus_data[i][0]+"/"+plus_data[i][1]+") + " + "("+plus_data[i][2]+"/"+plus_data[i][3]+")"+
          " = ("+plus_data[i][4]+"/"+plus_data[i][5]+")",R(f3,plus_data[i][4],plus_data[i][5]));
    }

  }

  static void TestSub()
  {
    TestHarness.TestCase("Fraction subtract");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int minus_data[][] = { { 0,1,0,1,0,1}, {0,1,1,1,-1,1}, {3,5,-2,9,37,45}, {-2,8,-6,8,1,2},
          {7,3,10,7,19,21}, {-5,7,25,35,-10,7}};

    int i;
    for(i=0;i<minus_data.length;i++) {
      S(f1,minus_data[i][0],minus_data[i][1]);
      S(f2,minus_data[i][2],minus_data[i][3]);
      f3=Fraction.subtract(f1,f2);
      TestHarness.Test("("+minus_data[i][0]+"/"+minus_data[i][1]+") - " + "("+minus_data[i][2]+"/"+minus_data[i][3]+")"+
          " = ("+minus_data[i][4]+"/"+minus_data[i][5]+")",R(f3,minus_data[i][4],minus_data[i][5]));
    }

  }

  static void TestMul()
  {
    TestHarness.TestCase("Fraction multiply");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int times_data[][] = { { 0,1,0,1,0,1}, {0,1,1,1,0,1}, {3,5,-2,9,-2,15}, {-2,8,-6,8,3,16},
          {7,3,10,7,10,3}, {-5,7,25,35,-25,49}};

    int i;
    for(i=0;i<times_data.length;i++) {
      S(f1,times_data[i][0],times_data[i][1]);
      S(f2,times_data[i][2],times_data[i][3]);
      f3=Fraction.multiply(f1,f2);
      TestHarness.Test("("+times_data[i][0]+"/"+times_data[i][1]+") * " + "("+times_data[i][2]+"/"+times_data[i][3]+")"+
          " = ("+times_data[i][4]+"/"+times_data[i][5]+")",R(f3,times_data[i][4],times_data[i][5]));
    }
  }

  static void TestDiv()
  {
    TestHarness.TestCase("Fraction divide");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int div_data[][] = { {0,1,1,1,0,1}, {3,5,-2,9,-27,10}, {-2,8,-6,8,1,3},
          {7,3,10,7,49,30}, {-5,7,25,35,-1,1}};

    int i;
    for(i=0;i<div_data.length;i++) {
      S(f1,div_data[i][0],div_data[i][1]);
      S(f2,div_data[i][2],div_data[i][3]);
      f3=Fraction.divide(f1,f2);
      TestHarness.Test("("+div_data[i][0]+"/"+div_data[i][1]+") / " + "("+div_data[i][2]+"/"+div_data[i][3]+")"+
          " = ("+div_data[i][4]+"/"+div_data[i][5]+")",R(f3,div_data[i][4],div_data[i][5]));
    }
  }

  static void TestRound()
  {
    TestHarness.TestCase("Fraction divide");
    Fraction f=new Fraction();

    int round_data[][] = { {3333,10000,100,33,100}, {3333,10000,10,3,10}, {639,5176,100,3,25}};
    int i;
    for(i=0;i<round_data.length;i++) {
      S(f,round_data[i][0],round_data[i][1]);
      f.Round(round_data[i][2]);
      TestHarness.Test("("+round_data[i][0]+"/"+round_data[i][1]+").Round(" + round_data[i][2]+") = ("+
          round_data[i][3]+"/"+round_data[i][4]+")",R(f,round_data[i][3],round_data[i][4]));
    }
  }

  static void TestEquality()
  {
    TestHarness.TestCase("Fraction equality");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int eq_data[][] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
    int i;
    for(i=0;i<eq_data.length;i++) {
      f1.set(eq_data[i][0],eq_data[i][1]);
      f2.set(eq_data[i][2],eq_data[i][3]);
      TestHarness.Test("("+eq_data[i][0]+"/"+eq_data[i][1]+") == ("+eq_data[i][2]+"/"+eq_data[i][3]+
            ") -- "+(eq_data[i][4]==1 ? "true" : "false"),f1.equals(f2) == (eq_data[i][4] == 1));
    }
  }

  static void TestInEquality()
  {
    TestHarness.TestCase("Fraction inequality");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int ne_data[][] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
    int i;
    for(i=0;i<ne_data.length;i++) {
      f1.set(ne_data[i][0],ne_data[i][1]);
      f2.set(ne_data[i][2],ne_data[i][3]);
      TestHarness.Test("("+ne_data[i][0]+"/"+ne_data[i][1]+") != ("+ne_data[i][2]+"/"+ne_data[i][3]+
            ") -- "+(ne_data[i][4]==1 ? "true" : "false"),!f1.equals(f2) == (ne_data[i][4] == 1));
    }
  }

  static void TestLessThan()
  {
    TestHarness.TestCase("Fraction less than");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int lt_data[][] = { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
    int i;
    for(i=0;i<lt_data.length;i++) {
      f1.set(lt_data[i][0],lt_data[i][1]);
      f2.set(lt_data[i][2],lt_data[i][3]);
      TestHarness.Test("("+lt_data[i][0]+"/"+lt_data[i][1]+") < ("+lt_data[i][2]+"/"+lt_data[i][3]+
            ") -- "+(lt_data[i][4]==1 ? "true" : "false"),(f1.compareTo(f2) < 0) == (lt_data[i][4] == 1));
    }
  }

  static void TestLessThanEqual()
  {
    TestHarness.TestCase("Fraction less than equal");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int le_data[][] = { { 0,1,0,1,1}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,1}};
    int i;
    for(i=0;i<le_data.length;i++) {
      f1.set(le_data[i][0],le_data[i][1]);
      f2.set(le_data[i][2],le_data[i][3]);
      TestHarness.Test("("+le_data[i][0]+"/"+le_data[i][1]+") <= ("+le_data[i][2]+"/"+le_data[i][3]+
            ") -- "+(le_data[i][4]==1 ? "true" : "false"),(f1.compareTo(f2) <= 0) == (le_data[i][4] == 1));
    }
  }

  static void TestGreaterThan()
  {
    TestHarness.TestCase("Fraction greater than");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int gt_data[][] = { { 0,1,0,1,0}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,0}};
    int i;
    for(i=0;i<gt_data.length;i++) {
      f1.set(gt_data[i][0],gt_data[i][1]);
      f2.set(gt_data[i][2],gt_data[i][3]);
      TestHarness.Test("("+gt_data[i][0]+"/"+gt_data[i][1]+") > ("+gt_data[i][2]+"/"+gt_data[i][3]+
            ") -- "+(gt_data[i][4]==1 ? "true" : "false"),(f1.compareTo(f2) > 0) == (gt_data[i][4] == 1));
    }
  }

  static void TestGreaterThanEqual()
  {
    TestHarness.TestCase("Fraction greater than equal");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int ge_data[][] = { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
    int i;
    for(i=0;i<ge_data.length;i++) {
      f1.set(ge_data[i][0],ge_data[i][1]);
      f2.set(ge_data[i][2],ge_data[i][3]);
      TestHarness.Test("("+ge_data[i][0]+"/"+ge_data[i][1]+") >= ("+ge_data[i][2]+"/"+ge_data[i][3]+
            ") -- "+(ge_data[i][4]==1 ? "true" : "false"),(f1.compareTo(f2) >= 0) == (ge_data[i][4] == 1));
    }
  }

  private static TestHarness.TestMethod [] tests = new TestHarness.TestMethod[] {
    new TestHarness.TestMethod() { public void test() { TestGCD(); } },
    new TestHarness.TestMethod() { public void test() { TestSet(); } },
    new TestHarness.TestMethod() { public void test() { TestConstructor(); } },
    new TestHarness.TestMethod() { public void test() { TestAdd(); } },
    new TestHarness.TestMethod() { public void test() { TestSub(); } },
    new TestHarness.TestMethod() { public void test() { TestMul(); } },
    new TestHarness.TestMethod() { public void test() { TestDiv(); } },
    new TestHarness.TestMethod() { public void test() { TestRound(); } },
    new TestHarness.TestMethod() { public void test() { TestEquality(); } },
    new TestHarness.TestMethod() { public void test() { TestInEquality(); } },
    new TestHarness.TestMethod() { public void test() { TestLessThan(); } },
    new TestHarness.TestMethod() { public void test() { TestLessThanEqual(); } },
    new TestHarness.TestMethod() { public void test() { TestGreaterThan(); } },
    new TestHarness.TestMethod() { public void test() { TestGreaterThanEqual(); } },
  };

  public static void main(String []args) {
    if(args.length == 0) {
      for(int i=0;i<tests.length;i++)
        tests[i].test();
    } else {
      for(int i=0;i<args.length;i++) {
        int j = Integer.valueOf(args[i]);
        if(j<tests.length) {
          tests[j].test();
        } else {
          System.out.println("No test for "+j);
        }
      }
    }
    TestHarness.FinalSummary();
  }

}
