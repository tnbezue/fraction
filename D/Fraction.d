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

import std.math;
import std.stdio;
import std.string;

version(USE_32_BIT_FRACTION)
{
  alias int fraction_numerator_denominator_t;
} else {
  alias long fraction_numerator_denominator_t;
}
class Fraction {
  private:
    static long gcd_private(long a,long b) {
      long t;
      while(b!=0) {
        t = b;
        b = a % b;
        a = t;
      }
      return a;
    }

    void set_private(long n,long d) {
      // Negative sign should be in numerator
      if (d < 0) {
        d=-d;
        n=-n;
      }

      // Reduce to lowest fraction
      long divisor;
      if((divisor=gcd_private(abs(n),d)) !=1) {
        n/=divisor;
        d/=divisor;
      }

      version (USE_32_BIT_FRACTION) {
        // Result should fit in an integer value
        long max = abs(n) < d ? d : abs(n);
        if(max > cast(long)fraction_numerator_denominator_t.max) {
          double scale=cast(double)max/(cast(double)fraction_numerator_denominator_t.max);
          n=cast(long)std.math.round(cast(double)n/scale);
          d=cast(long)std.math.round(cast(double)d/scale);
          // May need to be reduced again
          if((divisor=gcd(abs(n),d)) !=1) {
            n/=divisor;
            d/=divisor;
          }
        }
      }
      numerator_=cast(fraction_numerator_denominator_t)n;
      denominator_=cast(fraction_numerator_denominator_t)d;
    }

  protected:
    fraction_numerator_denominator_t numerator_;
    fraction_numerator_denominator_t denominator_;

  public:
    this() { set(0,1); }
    this(fraction_numerator_denominator_t n) { set(n,1); }
    this(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { set(n,d); }
    this(double d) { set(d); }
    this(Fraction f) { set(f.numerator_,f.denominator_); }

    fraction_numerator_denominator_t numerator() const { return numerator_; }
    fraction_numerator_denominator_t denominator() const { return denominator_; }
    static fraction_numerator_denominator_t gcd(fraction_numerator_denominator_t a,fraction_numerator_denominator_t b)
    {
      return cast(fraction_numerator_denominator_t)gcd_private(cast(long)a,cast(long)b);
    }

    void set(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d)
    {
      set_private(cast(long)n,cast(long)d);
    }

    static double epsilon=0.000005;

    version (CALCULATE_LOOP_STATISTICS) {
      static int nLoops;
    }
    void set(double d)
    {
      fraction_numerator_denominator_t hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
      double v = d;
      version (CALCULATE_LOOP_STATISTICS) {
        Fraction.nLoops=0;
      }
      while(1) {
        fraction_numerator_denominator_t a=cast(fraction_numerator_denominator_t)v;
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
        long lhs=cast(long)numerator_*cast(long)oFraction.denominator_;
        long rhs=cast(long)oFraction.numerator_*cast(long)denominator_;
        if(lhs < rhs) return -1;
        if(lhs > rhs) return 1;
        return 0;
      } else
        assert(0,"Can't compare object to Fraction");
    }

    bool opEquals(double d)
    {
      return opCmp(d) == 0;
    }

    int opCmp(double d)
    {
      double value = cast(double)numerator_/cast(double)denominator_;
      if(abs(value - d) < epsilon) return 0;
      if(value < d) return -1;
      return 1;
    }

    double opCast(T: double)() const
    {
      return cast(double)numerator_/cast(double)denominator_;
    }

    void opOpAssign(string op)(Fraction rhs)
    {
      static if(op == "+")
        set_private(cast(long)numerator_*cast(long)rhs.denominator_
                  + cast(long)denominator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "-")
        set_private(cast(long)numerator_*cast(long)rhs.denominator_
                  - cast(long)denominator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "*")
        set_private(cast(long)numerator_*cast(long)rhs.numerator_,cast(long)denominator_*cast(long)rhs.denominator_);
      else static if(op == "/")
        set_private(cast(long)numerator_*cast(long)rhs.denominator_,cast(long)denominator_*cast(long)rhs.numerator_);
      else
        static assert(0,"Op"~op~"not supported");
    }

    void opOpAssign(string op)(double rhs)
    {
      Fraction rhs_as_f=new Fraction(rhs);
      opOpAssign(op)(rhs_as_f);
    }

    Fraction opBinary(string op)(Fraction rhs)
    {
      Fraction f=new Fraction(this);
      static if(op == "+" || op == "-" || op == "*" || op == "/")
        f.opOpAssign!(op)(rhs);
      else static assert(0, "Operator "~op~" not implemented");
      return f;
    }

    Fraction opBinary(string op)(double rhs)
    {
      Fraction f=new Fraction(rhs);
      static if(op == "+" || op == "-" || op == "*" || op == "/")
        f.opOpAssign!(op)(this);
      else static assert(0, "Operator "~op~" not implemented");
      return f;
    }

    double opBinaryRight(string op)(double lhs)
    {
      double tmp=cast(double)this;
      static if(op == "+")
        return lhs + tmp;
      else static if(op == "-")
        return lhs - tmp;
      else static if(op == "*")
        return lhs * tmp;
      else static if(op == "/")
        return lhs/tmp;
      else static assert(0, "Operator "~op~" not implemented");
      return 0.0;
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

    void round(fraction_numerator_denominator_t denom)
    {
      set_private(cast(long)std.math.round(cast(double)denom*cast(double)numerator_/cast(double)denominator_),cast(long)denom);
    }

}

class MixedFraction : Fraction {

    this() { super(); }
    this(fraction_numerator_denominator_t w,fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { set(w,n,d); }
    this(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { Fraction.set(n,d); }
    this(double d) {
      super(d);
    }
    this(MixedFraction mf) {
      super(mf);
    }

    void set( fraction_numerator_denominator_t w, fraction_numerator_denominator_t n, fraction_numerator_denominator_t d) { Fraction.set(w*d+(w<0?-1:1)*n,d); }
    override void set(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { Fraction.set(n,d); }
    override string toString() const
    {
      fraction_numerator_denominator_t whole = numerator_/denominator_;
      if(whole == 0)
        return super.toString();
      if(denominator_ == 1)
        return format("%s",whole);
      return format("%s %s/%s",whole,abs(numerator_-whole*denominator_),denominator_);
    }

}
