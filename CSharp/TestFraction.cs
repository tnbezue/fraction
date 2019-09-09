using System;

class TestFraction {

  void test_init()
  {
  }

  static void TestGCD()
  {
    int [,] gcd_data = new int [,]{ {0,2,2}, {10,1,1}, {105,15,15}, {10,230,10}, {28,234,2}, {872452914,78241452,6} };
    int n = gcd_data.GetUpperBound(0);
    TestHarness.TestCase("Greatest Common Divisor");
    for(int i=0;i<=n;i++) {
      TestHarness.Test(String.Format("GCD({0},{1})={2}",gcd_data[i,0],gcd_data[i,1],gcd_data[i,2]),
          Fraction.gcd(gcd_data[i,0],gcd_data[i,1]) == gcd_data[i,2]);
    }
  }

  static void S(Fraction f,long n,long d)
  {
    f.Set(n,d);
  }

  static void S(Fraction f,long w,long n,long d)
  {
    f.Set(w,n,d);
  }

  static bool R(Fraction f,long n,long d)
  {
    return f.Numerator() == n && f.Denominator() == d;
  }

  static void TestSetInt()
  {
    TestHarness.TestCase("Fraction Set(int)");
    Fraction f = new Fraction();
    int i;

    int []set_data = { 15, -10 , 0};
    for(i=0;i<set_data.Length;i++) {
      f.Set(set_data[i]);
      TestHarness.Test(String.Format("Set({0}) = ({0}/1)",set_data[i]),R(f,set_data[i],1));
    }
  }

  static void TestSetIntInt()
  {
    TestHarness.TestCase("Fraction Set(int,int)");
    Fraction f = new Fraction();

    int [,] set_data  = new int [,] {
      { 1,-3,-1,3}, {-1,-3,1,3}, {-6,8,-3,4}, {2,4,1,2},{10,7,10,7}
    };
    int n = set_data.GetUpperBound(0);
    for(int i=0;i<n;i++) {
      S(f,set_data[i,0],set_data[i,1]);
      TestHarness.Test(String.Format("Set({0},{1}) = ({2},{3})",set_data[i,0],set_data[i,1],set_data[i,2],set_data[i,3]),
          R(f,set_data[i,2],set_data[i,3]));
    }
  }

  static void TestSetIntIntInt()
  {
    TestHarness.TestCase("Fraction Set(int,int,int)");
    Fraction f = new Fraction();

    int [,] set_data  = new int [,] {
      { -10,2,3,-32,3}, { 0, -2, 3, -2,3}, { 0,0,1,0,1}, {0,2,3,2,3}, {10,2,3,32,3}
    };
    int n = set_data.GetUpperBound(0);
    for(int i=0;i<n;i++) {
      S(f,set_data[i,0],set_data[i,1],set_data[i,2]);
      TestHarness.Test(String.Format("Set({0},{1},{2}) = ({3},{4})",set_data[i,0],set_data[i,1],
          set_data[i,2],set_data[i,3],set_data[i,4]),R(f,set_data[i,3],set_data[i,4]));
    }
  }

  static void TestSetDouble()
  {
    TestHarness.TestCase("Fraction Set(double)");
    Fraction f = new Fraction();
    double[] set_double_input = new double[] {-2.06, -0.06, 0.0, 0.06, 2.06, 0.3, 0.33, 0.33333333 , 20221.6543599839};
    int [,] set_double_output = new int[,] { { -103,50}, {-3,50}, {0, 1}, {3,50} , {103,50}, {3,10}, {33,100}, {1,3}, { 2147483647,106197} };
    for(int i=0;i<set_double_input.Length;i++) {
      f.Set(set_double_input[i]);
      TestHarness.Test(String.Format("Set({0}) = ({1}/{2})",set_double_input[i],set_double_output[i,0],
          set_double_output[i,1]),R(f,set_double_output[i,0],set_double_output[i,1]));
    }
  }

  static void TestAdd()
  {
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int [,] plus_data = new int [,] { { 0,1,0,1,0,1}, {0,1,1,1,1,1}, {3,5,-2,9,17,45}, {-2,8,-6,8,-1,1},
          {7,3,10,7,79,21}, {-5,7,25,35,0,1}};
    int n = plus_data.GetUpperBound(0);
    TestHarness.TestCase("Fraction addition");
    for(int i=0;i<n;i++) {
      S(f1,plus_data[i,0],plus_data[i,1]);
      S(f2,plus_data[i,2],plus_data[i,3]);
      f3 = f1 + f2;
      TestHarness.Test(String.Format("({0}/{1}) + ({2}/{3}) = ({4}/{5})",
          plus_data[i,0],plus_data[i,1],plus_data[i,2],plus_data[i,3],plus_data[i,4],plus_data[i,5]),
          R(f3,plus_data[i,4],plus_data[i,5]));
    }
  }

  static void TestSubtract()
  {
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int [,] minus_data = new int [,] { { 0,1,0,1,0,1}, {0,1,1,1,-1,1}, {3,5,-2,9,37,45}, {-2,8,-6,8,1,2},
          {7,3,10,7,19,21}, {-5,7,25,35,-10,7}};
    int n = minus_data.GetUpperBound(0);
    TestHarness.TestCase("Fraction subtraction");
    for(int i=0;i<n;i++) {
      S(f1,minus_data[i,0],minus_data[i,1]);
      S(f2,minus_data[i,2],minus_data[i,3]);
      f3 = f1 - f2;
      TestHarness.Test(String.Format("({0}/{1}) - ({2}/{3}) = ({4}/{5})",
          minus_data[i,0],minus_data[i,1],minus_data[i,2],minus_data[i,3],minus_data[i,4],minus_data[i,5]),
          R(f3,minus_data[i,4],minus_data[i,5]));
    }
  }

  static void TestMultiply()
  {
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int [,] mul_data = new int [,] { { 0,1,0,1,0,1}, {0,1,1,1,0,1}, {3,5,-2,9,-2,15}, {-2,8,-6,8,3,16},
          {7,3,10,7,10,3}, {-5,7,25,35,-25,49}};
    int n = mul_data.GetUpperBound(0);
    TestHarness.TestCase("Fraction multiplication");
    for(int i=0;i<n;i++) {
      S(f1,mul_data[i,0],mul_data[i,1]);
      S(f2,mul_data[i,2],mul_data[i,3]);
      f3 = f1 * f2;
      TestHarness.Test(String.Format("({0}/{1}) * ({2}/{3}) = ({4}/{5})",
          mul_data[i,0],mul_data[i,1],mul_data[i,2],mul_data[i,3],mul_data[i,4],mul_data[i,5]),
          R(f3,mul_data[i,4],mul_data[i,5]));
    }
  }

  static void TestDivide()
  {
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    int [,] div_data = new int [,] { {0,1,1,1,0,1}, {3,5,-2,9,-27,10}, {-2,8,-6,8,1,3},
          {7,3,10,7,49,30}, {-5,7,25,35,-1,1}};
    int n = div_data.GetUpperBound(0);
    TestHarness.TestCase("Fraction division");
    for(int i=0;i<n;i++) {
      S(f1,div_data[i,0],div_data[i,1]);
      S(f2,div_data[i,2],div_data[i,3]);
      f3 = f1 / f2;
      TestHarness.Test(String.Format("({0}/{1}) / ({2}/{3}) = ({4}/{5})",
          div_data[i,0],div_data[i,1],div_data[i,2],div_data[i,3],div_data[i,4],div_data[i,5]),
          R(f3,div_data[i,4],div_data[i,5]));
    }
  }

  static void TestEquality()
  {
    TestHarness.TestCase("Fraction equality");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] eq_data = new int [,] { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
    int i;
    int n=eq_data.GetUpperBound(0);
    for(i=0;i<n;i++) {
      f1.Set(eq_data[i,0],eq_data[i,1]);
      f2.Set(eq_data[i,2],eq_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) == ({2}/{3}) -- {4}",eq_data[i,0],eq_data[i,1],eq_data[i,2],
            eq_data[i,3],(eq_data[i,4]==1 ? "true" : "false")),(f1 == f2) == (eq_data[i,4] == 1));
    }
  }

  static void TestInEquality()
  {
    TestHarness.TestCase("Fraction inequality");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] ne_data= new int [,] { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
    int i;
    int n=ne_data.GetUpperBound(0);
    for(i=0;i<n;i++) {
      f1.Set(ne_data[i,0],ne_data[i,1]);
      f2.Set(ne_data[i,2],ne_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) != ({2}/{3}) -- {4}",ne_data[i,0],ne_data[i,1],ne_data[i,2],
            ne_data[i,3],(ne_data[i,4]==1 ? "true" : "false")),(f1 != f2) == (ne_data[i,4] == 1));
    }
  }

  static void TestLessThan()
  {
    TestHarness.TestCase("Fraction less than");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] lt_data = new int [,] { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}};
    int n=lt_data.GetUpperBound(0);
    int i;
    for(i=0;i<n;i++) {
      f1.Set(lt_data[i,0],lt_data[i,1]);
      f2.Set(lt_data[i,2],lt_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) != ({2}/{3}) -- {4}",lt_data[i,0],lt_data[i,1],lt_data[i,2],
            lt_data[i,3],(lt_data[i,4]==1 ? "true" : "false")),(f1 < f2) == (lt_data[i,4] == 1));
    }
  }

  static void TestLessThanEqual()
  {
    TestHarness.TestCase("Fraction less than equal");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] le_data = new int [,] { { 0,1,0,1,1}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,1}};
    int n=le_data.GetUpperBound(0);
    int i;
    for(i=0;i<n;i++) {
      f1.Set(le_data[i,0],le_data[i,1]);
      f2.Set(le_data[i,2],le_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) != ({2}/{3}) -- {4}",le_data[i,0],le_data[i,1],le_data[i,2],
            le_data[i,3],(le_data[i,4]==1 ? "true" : "false")),(f1 <= f2) == (le_data[i,4] == 1));
    }
  }

  static void TestGreaterThan()
  {
    TestHarness.TestCase("Fraction greater than");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] gt_data = new int [,] { { 0,1,0,1,0}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,0}};
    int i;
    int n=gt_data.GetUpperBound(0);
    for(i=0;i<n;i++) {
      f1.Set(gt_data[i,0],gt_data[i,1]);
      f2.Set(gt_data[i,2],gt_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) != ({2}/{3}) -- {4}",gt_data[i,0],gt_data[i,1],gt_data[i,2],
            gt_data[i,3],(gt_data[i,4]==1 ? "true" : "false")),(f1 > f2) == (gt_data[i,4] == 1));
    }
  }

  static void TestGreaterThanEqual()
  {
    TestHarness.TestCase("Fraction greater than equal");
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    int [,] ge_data = new int [,] { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0}};
    int n=ge_data.GetUpperBound(0);
    int i;
    for(i=0;i<n;i++) {
      f1.Set(ge_data[i,0],ge_data[i,1]);
      f2.Set(ge_data[i,2],ge_data[i,3]);
      TestHarness.Test(String.Format("({0}/{1}) != ({2}/{3}) -- {4}",ge_data[i,0],ge_data[i,1],ge_data[i,2],
            ge_data[i,3],(ge_data[i,4]==1 ? "true" : "false")),(f1 >= f2) == (ge_data[i,4] == 1));
    }
  }

  static void TestParse()
  {
    string [] parse_input = new string [] { "-1.25" , "-.25", "0" , "0.25" , "1.25" , "-1 1/4", "-1/4" , "0/1" , "1/4", "1 1/4"};
    int [,] parse_output = new int [,] { {-5,4 }, { -1, 4}, {0,1}, {1,4}, {5,4}, {-5,4 }, { -1, 4}, {0,1}, {1,4}, {5,4}};
    for(int i=0;i<parse_input.Length;i++) {
      Fraction f = Fraction.Parse(parse_input[i]);
      TestHarness.Test(String.Format("Fraction.Parse({0}) = ({1},{2})",parse_input[i],parse_output[i,0],
          parse_output[i,1]),R(f,parse_output[i,0],parse_output[i,1]));
    }
  }
  static TestHarness.TestMethod [] tests =
  {
    TestGCD,
    TestSetInt,
    TestSetIntInt,
    TestSetIntIntInt,
    TestSetDouble,
    TestAdd,
    TestSubtract,
    TestMultiply,
    TestDivide,
    TestEquality,
    TestInEquality,
    TestLessThan,
    TestLessThanEqual,
    TestGreaterThanEqual,
    TestGreaterThanEqual,
    TestParse
  };

  static void Main(string[] args)
  {
    if(args.Length > 0) {
      for(int i=0;i<args.Length;i++) {
        int j=int.Parse(args[i]);
        if(j < tests.Length)
          tests[j]();
        else
          Console.WriteLine("No test for "+j);
      }
    } else {
      for(int i=0;i<tests.Length;i++)
        tests[i]();
    }

    TestHarness.FinalSummary();
  }

}
