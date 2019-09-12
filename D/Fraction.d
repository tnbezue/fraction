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
        // So starting fraction is 1/17
        numerator=1;
        denominator=cast(long)std.math.round(1.0/fract);
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
          dd=cast(long)std.math.round(fabs(1.0/diff));
          numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
          denominator*=dd;
        }
      }
      set(sign*(whole*denominator+numerator),denominator);
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

