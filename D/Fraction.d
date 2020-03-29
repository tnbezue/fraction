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

    int numerator() const { return numerator_; }
    int denominator() const { return denominator_; }
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

    void set(long n,long d) {
      // Negative sign should be in numerator
      if (d < 0) {
        d=-d;
        n=-n;
      }

      // Reduce to lowest fraction
      long divisor;
      if((divisor=gcd(abs(n),d)) !=1) {
        n/=divisor;
        d/=divisor;
      }

      // Result should fit in an integer value
      long max = abs(n) < d ? d : abs(n);
      if(max > cast(long)int.max) {
        double scale=cast(double)max/(cast(double)int.max);
        n=cast(long)std.math.round(cast(double)n/scale);
        d=cast(long)std.math.round(cast(double)d/scale);
        // May need to be reduced again
        if((divisor=gcd(abs(n),d)) !=1) {
          n/=divisor;
          d/=divisor;
        }
      }

      numerator_=cast(int)n;
      denominator_=cast(int)d;
    }

    void set(int w,int n,int d) { set(w*d+(w<0?-1:1)*n,d); }

    static double epsilon=0.000005;

    version (CALCULATE_LOOP_STATISTICS) {
      static int nLoops;
    }
    void set(double d)
    {
      int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
      double v = d;
      version (CALCULATE_LOOP_STATISTICS) {
        Fraction.nLoops=0;
      }
      while(1) {
        int a=cast(int)v;
        h=a*hm1 + hm2;
        k=a*km1 + km2;
    //    printf("%lg %d %d %d %d %d %d %d\n",v,a,h,k,hm1,km1,hm2,km2);
        if(fabs(d - cast(double)h/cast(double)k) < Fraction.epsilon)
          break;
        v = 1.0/(v -a);
        hm2=hm1;
        hm1=h;
        km2=km1;
        km1=k;
        version (CALCULATE_LOOP_STATISTICS) {
          Fraction.nLoops++;
        }
      }
      if(k<0) {
        k=-k;
        h=-h;
      }
      numerator_=h;
      denominator_=k;
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


    double opCast(T: double)() const
    {
      return cast(double)numerator_/cast(double)denominator_;
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

    void opAssign(double d)
    {
      set(d);
    }

    override string toString() const
    {
      if(denominator_ == 1)
        return format("%s",numerator_);
      return format("%s/%s",numerator_,denominator_);
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

    void round(int denom)
    {
      set(cast(long)std.math.round(cast(double)denom*cast(double)numerator_/cast(double)denominator_),cast(long)denom);
    }

}

