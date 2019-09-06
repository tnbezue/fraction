
public class TestFraction
{

  static void TestGCD()
  {
    TestHarness.TestCase("Greatest common denominator");
    TestHarness.Test("GCD(0,2) = 1",Fraction.gcd(0,2)==2);
    TestHarness.Test("GCD(10,1) = 1",Fraction.gcd(10,1)==1);
    TestHarness.Test("GCD(105,15) = 1",Fraction.gcd(105,15)==15);
    TestHarness.Test("GCD(10,230) = 1",Fraction.gcd(10,230)==10);
    TestHarness.Test("GCD(28,234) = 1",Fraction.gcd(28,234)==2);
    TestHarness.Test("GCD(872452914,78241452) = 1",Fraction.gcd(872452914,78241452)==6);
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
    Fraction f = new Fraction();
    TestHarness.TestCase("Fraction Set");

    f.set(15);
    TestHarness.Test("Set 15 = 15/1",R(f,15,1));

    f.set(-10);
    TestHarness.Test("Set -10 = -10/1",R(f,-10,1));

    S(f,0,1);
    TestHarness.Test("Set 0/1 = 0/1",R(f,0,1));

    S(f,1,-3);
    TestHarness.Test("Set 1/-3 = -1/3",R(f,-1,3));

    S(f,-1,-3);
    TestHarness.Test("Set -1/-3 = 1/3",R(f,1,3));

    S(f,-6,8);
    TestHarness.Test("Set -6/8 = -3/4",R(f,-3,4));

    S(f,2,4);
    TestHarness.Test("Set 2/4 = 1/2",R(f,1,2));

    S(f,10,7);
    TestHarness.Test("Set 10/7 = 10/7",R(f,10,7));

    S(f,10,0,7);
    TestHarness.Test("Set 10 0/1 = 10/1",R(f,10,1));

    S(f,-10,2,3);
    TestHarness.Test("Set -10 2/3 = -32/3",R(f,-32,3));

    S(f,0,0,27);
    TestHarness.Test("Set 0 0/27 = 0/1",R(f,0,1));

    f.set(0.06);
    TestHarness.Test("Set 0.06 = 3/50",R(f,3,50));

    f.set(0.3);
    TestHarness.Test("Set 0.3 = 3/10",R(f,3,10));

    f.set(0.33);
    TestHarness.Test("Set 0.33 = 33/100",R(f,33,100));

    f.set(0.3333333333);
    TestHarness.Test("Set 0.33333333333 = 1/3",R(f,1,3));

    f.set("12");
    TestHarness.Test("Set \"12\" = 12/1",R(f,12,1));

    f.set("12.25");
    TestHarness.Test("Set \"12.25\" = 49/4",R(f,49,4));

    f.set("12 1/4");
    TestHarness.Test("Set \"12 1/4\" = 49/4",R(f,49,4));
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

    S(f1,0,1);
    S(f2,0,1);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("0/1 + 0/1 = 0/1",R(f3,0,1));

    S(f1,0,1);
    S(f2,1,1);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("0/1 + 1/1 = 1/1",R(f3,1,1));

    S(f1,3,5);
    S(f2,-2,9);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("3/5 + -2/9 = 17/45",R(f3,17,45));

    S(f1,-2,8);
    S(f2,-6,8);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("-2/8 + -6/8 = -1/1",R(f3,-1,1));

    S(f1,7,3);
    S(f2,10,7);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("7/3 + 10/7 = 79/21",R(f3,79,21));

    S(f1,-5,7);
    S(f2,25,35);
    f3=Fraction.add(f1,f2);
    TestHarness.Test("-5/7 + 25/35 = 0/1",R(f3,0,1));

  }

  static void TestSub()
  {
    TestHarness.TestCase("Fraction subtract");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    S(f1,0,1);
    S(f2,0,1);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("0/1 - 0/1 = 0/1",R(f3,0,1));

    S(f1,0,1);
    S(f2,1,1);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("0/1 - 1/1 = 1/1",R(f3,-1,1));

    S(f1,3,5);
    S(f2,-2,9);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("3/5 - -2/9 = 37/45",R(f3,37,45));

    S(f1,-2,8);
    S(f2,-6,8);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("-2/8 - -6/8 = 1/2",R(f3,1,2));

    S(f1,7,3);
    S(f2,10,7);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("7/3 - 10/7 = 19/21",R(f3,19,21));

    S(f1,-5,7);
    S(f2,25,35);
    f3=Fraction.subtract(f1,f2);
    TestHarness.Test("-5/7 - 25/35 = -10/7",R(f3,-10,7));
  }

  static void TestMul()
  {
    TestHarness.TestCase("Fraction multiply");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;
    S(f1,0,1);
    S(f2,0,1);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("0/1 * 0/1 = 0/1",R(f3,0,1));

    S(f1,0,1);
    S(f2,1,1);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("0/1 * 1/1 = 0/1",R(f3,0,1));

    S(f1,3,5);
    S(f2,-2,9);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("3/5 * -2/9 = -2/15",R(f3,-2,15));

    S(f1,-2,8);
    S(f2,-6,8);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("-2/8 * -6/8 = 3/16",R(f3,3,16));

    S(f1,7,3);
    S(f2,10,7);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("7/3 * 10/7 = 10/3",R(f3,10,3));

    S(f1,-5,7);
    S(f2,25,35);
    f3=Fraction.multiply(f1,f2);
    TestHarness.Test("-5/7 * 25/35 = -25/49",R(f3,-25,49));
  }

  static void TestDiv()
  {
    TestHarness.TestCase("Fraction divide");

    Fraction f1=new Fraction();
    Fraction f2=new Fraction();
    Fraction f3;

    S(f1,0,1);
    S(f2,1,1);
    f3=Fraction.divide(f1,f2);
    TestHarness.Test("0/1 / 1/1 = 1/1",R(f3,0,1));

    S(f1,3,5);
    S(f2,-2,9);
    f3=Fraction.divide(f1,f2);
    TestHarness.Test("3/5 / -2/9 = -27/10",R(f3,-27,10));

    S(f1,-2,8);
    S(f2,-6,8);
    f3=Fraction.divide(f1,f2);
    TestHarness.Test("-2/8 / -6/8 = 1/3",R(f3,1,3));

    S(f1,7,3);
    S(f2,10,7);
    f3=Fraction.divide(f1,f2);
    TestHarness.Test("7/3 / 10/7 = 49/30",R(f3,49,30));

    S(f1,-5,7);
    S(f2,25,35);
    f3=Fraction.divide(f1,f2);
    TestHarness.Test("-5/7 / 25/35 = -1",R(f3,-1,1));

  }

  static void TestRound()
  {
    TestHarness.TestCase("Fraction divide");
    Fraction f=new Fraction();

    S(f,3333,10000);
    f.Round(100);
    TestHarness.Test("Round(3333/10000,100) = 33/100",R(f,33,100));

    S(f,3333,10000);
    f.Round(10);
    TestHarness.Test("Round(3333/10000,100) = 3/10",R(f,3,10));

    S(f,639,5176);
    f.Round(100);
    TestHarness.Test("Round(639/5176,100) = 3/25",R(f,3,25));
  }

  static void TestEquality()
  {
    Fraction f1=new Fraction();
    Fraction f2=new Fraction();

    if(f1 == f2)
      System.out.println("Ok");
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
