import std.math;
import std.stdio;
import std.string;

class Fraction {
  protected:
    int numerator_;
    int denominator_;

  public:
    this() { set(0,1); }
    this(int n) { set(n,1); }
    this(int n,int d) { set(n,d); }
    this(int w,int n,int d) { set(w,n,d); }
    this(double d) { set(d); }
    this(Fraction f) { set(f.numerator_,f.denominator_); }

    static long gcd(long a,long b)
    {
      long t;
      while(b!=0) {
        t = b;
        b = a % b;
        a = t;
      }
      return a;
    }

    unittest {
      assert(Fraction.gcd(0,2)==2);
      assert(Fraction.gcd(10,1)==1);
      assert(Fraction.gcd(105,15)==15);
      assert(Fraction.gcd(10,230)==10);
      assert(Fraction.gcd(28,234)==2);
      assert(Fraction.gcd(872452914,78241452)==6);
    }

    void set(long n,long d) {
      if (d < 0) {
        d=-d;
        n=-n;
      }
      long divisor=gcd(abs(n),d);
      numerator_=n/divisor;
      denominator_=d/divisor;
    }

    unittest {
      Fraction f=new Fraction;
      f.set(0,1);
      assert(f.numerator_==0 && f.denominator_==1);

      f.set(1,-3);
      assert(f.numerator_==-1 && f.denominator_==3);

      f.set(-1,-3);
      assert(f.numerator_==1 && f.denominator_==3);

      f.set(-6,-8);
      assert(f.numerator_==3 && f.denominator_==4);

      f.set(2,4);
      assert(f.numerator_==1 && f.denominator_==2);

    }
    void set(int w,int n,int d) { set(w*d+(w<0?-1:1)*n,d); }

    unittest {
      Fraction f=new Fraction;

      f.set(-10,2,3);
      assert(f.numerator_==-32 && f.denominator_==3);

      f.set(0,-1,3);
      assert(f.numerator_==-1 && f.denominator_==3);

      f.set(0,0,1);
      assert(f.numerator_==0 && f.denominator_==1);

      f.set(0,1,3);
      assert(f.numerator_==1 && f.denominator_==3);

      f.set(10,2,3);
      assert(f.numerator_==32 && f.denominator_==3);

    }

    static double epsilon=0.000005;

    version (CALCULATE_LOOP_STATISTICS) {
      static int loops;
    }
    void set(double d)
    {
      // Will be 0/1 if fraction part is zero (or near zero)
      long numerator=0;
      long denominator=1;
      long sign = d < 0 ? -1 : 1;
      long whole = cast(long)fabs(d);
      double fract=fabs(d)-whole;
      version (CALCULATE_LOOP_STATISTICS) {
        Fraction.loops=0;
      }
      if(fract > Fraction.epsilon) {
        // Starting approximation is 1 for numerator and 1/fract for denominator
        // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
        // So starting fraction is 1/16
        numerator=1;
        denominator=cast(long)(1.0/fract+Fraction.epsilon); // Round to next whole number if very close to it
        while(1) {
          // End if it's close enough to fract
          double value=cast(double)numerator/cast(double)denominator;
          double diff=value-fract;
          if(fabs(diff) < Fraction.epsilon)
            break;
            version (CALCULATE_LOOP_STATISTICS) {
              Fraction.loops++;
            }
          // The desired fraction is current fraction (numerator/denominator) +/- the difference
          // Convert difference to fraction in the same manner as starting approximation
          // (numerator = 1 and denominator = 1/diff) and add to current fraction.
          // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
          long dd;
          dd=cast(long)(fabs(1.0/diff)+Fraction.epsilon); // Round to next whole number if very close to it.
          numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
          denominator*=dd;
        }
      }
      set(sign*(whole*denominator+numerator),denominator);
    }

    unittest {
      Fraction f = new Fraction;

      f.set(0.0);
      assert(f.numerator_==0 && f.denominator_==1);

      f.set(1.0);
      assert(f.numerator_==1 && f.denominator_==1);

      f.set(12.25);
      assert(f.numerator_==49 && f.denominator_==4);

      f.set(-2.5);
      assert(f.numerator_==-5 && f.denominator_==2);

      f.set(-0.06);
      assert(f.numerator_==-3 && f.denominator_==50);

      f.set(0.3);
      assert(f.numerator_==3 && f.denominator_==10);

      f.set(0.33);
      assert(f.numerator_==33 && f.denominator_==100);

      f.set(0.333333333);
      assert(f.numerator_==1 && f.denominator_==3);
    }

    override bool opEquals(Object o)
    {
      return opCmp(o) == 0;
    }

    override int opCmp(Object o)
    {
      if(auto oFraction=cast(Fraction)o) {
        return cast(int)((cast(long)numerator_)*(cast(long)oFraction.denominator_) - (cast(long)oFraction.numerator_)*(cast(long)denominator_));
      } else
        assert(0,"Can compare object to Fraction");
    }

    unittest {
      // Equality
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(f1 == f2);

      f2.set(1,2);
      assert(!(f1 == f2));

      f1.set(2,3);
      f2.set(-2,3);
      assert(!(f1 == f2));

      f1.set(2,3);
      f2.set(16,24);
      assert(f1 == f2);

      f1.set(1,3);
      f2.set(1,3);
      assert(f1 == f2);

      f1.set(-5,7);
      f2.set(25,35);
      assert(!(f1 == f2));
    }

    unittest {
      // Inequality
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(!(f1 != f2));

      f2.set(1,2);
      assert(f1 != f2);

      f1.set(2,3);
      f2.set(-2,3);
      assert(f1 != f2);

      f1.set(2,3);
      f2.set(16,24);
      assert(!(f1 != f2));

      f1.set(1,3);
      f2.set(1,3);
      assert(!(f1 != f2));

      f1.set(-5,7);
      f2.set(25,35);
      assert(f1 != f2);
    }

    unittest {
      // Less than
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(!(f1<f2));

      f1.set(0,1);
      f2.set(1,1);
      assert(f1<f2);

      f1.set(2,3);
      f2.set(-2,3);
      assert(!(f1<f2));

      f1.set(2,3);
      f2.set(16,24);
      assert(!(f1<f2));

      f1.set(1,3);
      f2.set(1,3);
      assert(!(f1<f2));

      f1.set(-5,7);
      f2.set(25,35);
      assert(f1<f2);
    }

    unittest {
      // Less than equal
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(f1<=f2);

      f1.set(0,1);
      f2.set(1,1);
      assert(f1<=f2);

      f1.set(2,3);
      f2.set(-2,3);
      assert(!(f1<=f2));

      f1.set(2,3);
      f2.set(16,24);
      assert(f1<=f2);

      f1.set(1,3);
      f2.set(1,3);
      assert(f1<=f2);

      f1.set(-5,7);
      f2.set(25,35);
      assert(f1<=f2);
    }

    unittest {
      // Greater than
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(!(f1>f2));

      f1.set(0,1);
      f2.set(1,1);
      assert(!(f1>f2));

      f1.set(2,3);
      f2.set(-2,3);
      assert(f1>f2);

      f1.set(2,3);
      f2.set(16,24);
      assert(!(f1>f2));

      f1.set(1,3);
      f2.set(1,3);
      assert(!(f1>f2));

      f1.set(-5,7);
      f2.set(25,35);
      assert(!(f1>f2));
    }

    unittest {
      // Greater than equal
      Fraction f1=new Fraction;
      Fraction f2=new Fraction;

      f1.set(0,1);
      f2.set(0,1);
      assert(f1>=f2);

      f1.set(0,1);
      f2.set(1,1);
      assert(!(f1>=f2));

      f1.set(2,3);
      f2.set(-2,3);
      assert(f1>=f2);

      f1.set(2,3);
      f2.set(16,24);
      assert(f1>=f2);

      f1.set(1,3);
      f2.set(1,3);
      assert(f1>=f2);

      f1.set(-5,7);
      f2.set(25,35);
      assert(!(f1>=f2));
    }

    double opCast(T: double)() const
    {
      return cast(double)numerator_/cast(double)denominator_;
    }

    unittest {
      Fraction f=new Fraction;
      double value;

      value=0;
      f.set(0,1);
      assert(fabs(cast(double)f - value) < Fraction.epsilon);

      value=1;
      f.set(1,1);
      assert(fabs(cast(double)f - value) < Fraction.epsilon);

      value=-1;
      f.set(-1,1);
      assert(fabs(cast(double)f - value) < Fraction.epsilon);

      value=-0.06;
      f.set(-3,50);
      assert(fabs(cast(double)f - value) < Fraction.epsilon);

      value=12.25;
      f.set(49,4);
      assert(fabs(cast(double)f - value) < Fraction.epsilon);
    }

    void opOpAssign(string op)(Fraction rhs)
    {
      static if(op == "+")
        set(cast(long)numerator_*cast(long)rhs.denominator_
                  + cast(long)denominator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "-")
        set(cast(long)numerator_*cast(long)rhs.denominator_
                  - cast(long)denominator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "*")
        set(cast(long)numerator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "/")
        set(cast(long)numerator_*cast(long)rhs.denominator_,cast(long)denominator_*cast(long)rhs.numerator_);
      else
        static assert(0,"Op"~op~"not supported");
    }

    Fraction opBinary(string op)(Fraction rhs)
    {
      Fraction f=new Fraction(this);
      static if(op == "+" || op == "-" || op == "*" || op == "/")
        f.opOpAssign!(op)(rhs);
      else static assert(0, "Operator "~op~" not implemented");
      return f;
    }

    unittest {
      // Addition
      Fraction f1=new Fraction;
      Fraction f2= new Fraction;
      Fraction f3;

      f1.set(0,1);
      f2.set(0,1);
      f3= f1 + f2;
      assert(f3.numerator_==0 && f3.denominator_==1);

      f1.set(0,1);
      f2.set(1,1);
      f3= f1 + f2;
      assert(f3.numerator_==1 && f3.denominator_==1);

      f1.set(3,5);
      f2.set(-2,9);
      f3= f1 + f2;
      assert(f3.numerator_==17 && f3.denominator_==45);

      f1.set(-2,8);
      f2.set(-6,8);
      f3= f1 + f2;
      assert(f3.numerator_==-1 && f3.denominator_==1);

      f1.set(7,3);
      f2.set(10,7);
      f3= f1 + f2;
      assert(f3.numerator_==79 && f3.denominator_==21);

      f1.set(-5,7);
      f2.set(25,35);
      f3= f1 + f2;
      assert(f3.numerator_==0 && f3.denominator_==1);
    }

    unittest {
      // Subtraction
      Fraction f1=new Fraction;
      Fraction f2= new Fraction;
      Fraction f3;

      f1.set(0,1);
      f2.set(0,1);
      f3= f1 - f2;
      assert(f3.numerator_==0 && f3.denominator_==1);

      f1.set(0,1);
      f2.set(1,1);
      f3= f1 - f2;
      assert(f3.numerator_==-1 && f3.denominator_==1);

      f1.set(3,5);
      f2.set(-2,9);
      f3= f1 - f2;
      assert(f3.numerator_==37 && f3.denominator_==45);

      f1.set(-2,8);
      f2.set(-6,8);
      f3= f1 - f2;
      assert(f3.numerator_==1 && f3.denominator_==2);

      f1.set(7,3);
      f2.set(10,7);
      f3= f1 - f2;
      assert(f3.numerator_==19 && f3.denominator_==21);

      f1.set(-5,7);
      f2.set(25,35);
      f3= f1 - f2;
      assert(f3.numerator_==-10 && f3.denominator_==7);
    }

    unittest {
      // Multiply
      Fraction f1=new Fraction;
      Fraction f2= new Fraction;
      Fraction f3;

      f1.set(0,1);
      f2.set(0,1);
      f3= f1 * f2;
      assert(f3.numerator_==0 && f3.denominator_==1);

      f1.set(0,1);
      f2.set(1,1);
      f3= f1 * f2;
      assert(f3.numerator_==0 && f3.denominator_==1);

      f1.set(3,5);
      f2.set(-2,9);
      f3= f1 * f2;
      assert(f3.numerator_==-2 && f3.denominator_==15);

      f1.set(-2,8);
      f2.set(-6,8);
      f3= f1 * f2;
      assert(f3.numerator_==3 && f3.denominator_==16);

      f1.set(7,3);
      f2.set(10,7);
      f3= f1 * f2;
      assert(f3.numerator_==10 && f3.denominator_==3);

      f1.set(-5,7);
      f2.set(25,35);
      f3= f1 * f2;
      assert(f3.numerator_==-25 && f3.denominator_==49);
    }

    unittest {
      // Divide
      Fraction f1=new Fraction;
      Fraction f2= new Fraction;
      Fraction f3;

      f1.set(0,1);
      f2.set(1,1);
      f3= f1 / f2;
      assert(f3.numerator_==0 && f3.denominator_==1);

      f1.set(3,5);
      f2.set(-2,9);
      f3= f1 / f2;
      assert(f3.numerator_==-27 && f3.denominator_==10);

      f1.set(-2,8);
      f2.set(-6,8);
      f3= f1 / f2;
      assert(f3.numerator_==1 && f3.denominator_==3);

      f1.set(7,3);
      f2.set(10,7);
      f3= f1 / f2;
      assert(f3.numerator_==49 && f3.denominator_==30);

      f1.set(-5,7);
      f2.set(25,35);
      f3= f1 / f2;
      assert(f3.numerator_==-1 && f3.denominator_==1);
    }

    void opAssign(int n)
    {
      set(n,1);
    }

    unittest {

      Fraction f= new Fraction;

      f=0;
      assert(f.numerator_==0 && f.denominator_==1);

      f=1;
      assert(f.numerator_==1 && f.denominator_==1);

      f=-10;
      assert(f.numerator_==-10 && f.denominator_==1);

      f=10;
      assert(f.numerator_==10 && f.denominator_==1);
    }

    void opAssign(double d)
    {
      set(d);
    }

    unittest {

      Fraction f= new Fraction;

      f=-10.06;
      assert(f.numerator_==-503 && f.denominator_==50);

      f=-0.06;
      assert(f.numerator_==-3 && f.denominator_==50);

      f=0.0;
      assert(f.numerator_==0 && f.denominator_==1);

      f=0.06;
      assert(f.numerator_==3 && f.denominator_==50);

      f=10.06;
      assert(f.numerator_==503 && f.denominator_==50);

    }

    override string toString() const
    {
      if(denominator_ == 1)
        return format("%s",numerator_);
      return format("%s/%s",numerator_,denominator_);
    }

    unittest {
      Fraction f= new Fraction;

      f=-10.06;
      assert(f.toString() == "-503/50");

      f=-0.06;
      assert(f.toString() == "-3/50");

      f=0.0;
      assert(f.toString() == "0");

      f=0.06;
      assert(f.toString() == "3/50");

      f=10.06;
      assert(f.toString() == "503/50");
    }

    string toStringMixed() const
    {
      int whole = numerator_/denominator_;
      if(whole == 0)
        return toString();
      if(denominator_ == 1)
        return format("%s",whole);
      return format("%s %s/%s",whole,abs(numerator_-whole*denominator_),denominator_);
    }

    unittest {
      Fraction f= new Fraction;

      f=-10.06;
      stdout.writeln(f.toStringMixed());
      assert(f.toStringMixed() == "-10 3/50");

      f=-0.06;
      assert(f.toStringMixed() == "-3/50");

      f=0.0;
      assert(f.toStringMixed() == "0");

      f=0.06;
      assert(f.toStringMixed() == "3/50");

      f=10.06;
      assert(f.toStringMixed() == "10 3/50");
    }

}

version(unittest) {
void main(string[] args)
{
  Fraction f = new Fraction;
}
}
