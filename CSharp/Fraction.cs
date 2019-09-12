using System;
using System.Text.RegularExpressions;

public class Fraction : IComparable {
  protected int _numerator;
  protected int _denominator;

  public static double epsilon = 0.000005;

  public Fraction()
  {
    _numerator=0;
    _denominator=1;
  }

  public Fraction(Fraction f)
  {
    _numerator=f._numerator;
    _denominator=f._denominator;
  }

  public Fraction(int n)
  {
    Set(n,1);
  }

  public Fraction(int n,int d)
  {
    Set(n,d);
  }

  public Fraction(int w,int n,int d)
  {
    Set(w,n,d);
  }

  public Fraction(double v)
  {
    Set(v);
  }

/*  public Fraction(String s)
  {
    set(s);
  }*/

  public int Numerator()
  {
    return _numerator;
  }

  public int Denominator()
  {
    return _denominator;
  }

public static long gcd(long a,long b)
  {
    long t;
    while(b!=0) {
      t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  public void Set(long n,long d)
  {
    // Negative sign should be in numerator
    if(d<0) {
      n=-n;
      d=-d;
    }

    // Reduce to lowest fraction
    long divisor;
    if((divisor=Fraction.gcd(Math.Abs(n),d)) != 1) {
      n /= divisor;
      d /= divisor;
    }

    // Result should fit in an integer value
    long max=Math.Abs(n)<d ? d : Math.Abs(n);
    if(max > (long)int.MaxValue) {
      double scale=(double)max/((double)int.MaxValue);
      n=(int)Math.Round((double)n/scale);
      d=(int)Math.Round((double)d/scale);

      /// May need to be reduced again
      if((divisor=Fraction.gcd(Math.Abs(n),d)) != 1) {
        n /= divisor;
        d /= divisor;
      }
    }

    _numerator=(int)n;
    _denominator=(int)d;
  }

  public void Set(long w,long n,long d)
  {
    Set(w*d+(w<0 ? -1 : 1)*n,d);
  }
#if CALCULATE_LOOP_STATISTICS
  public static int loops=0;
#endif
  public void Set(double d)
  {
    long sign = d<0 ? -1 : 1;
    long whole = Math.Abs((long)d);
    double fract=Math.Abs(d)-whole;
    long numerator=0;
    long denominator=1; // Round to next whole number if very close to it
#if CALCULATE_LOOP_STATISTICS
    loops=0;
#endif
    if(fract > Fraction.epsilon) {
      // Starting approximation is 1 for numerator and 1/fract for denominator
      // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
      // So starting fraction is 1/17
      numerator=1;
      denominator=(long)Math.Round(1.0/fract);
      while(true) {
        // End if it's close enough to fract
        double value=(double)numerator/(double)denominator;
        double diff=value-fract;
        if(Math.Abs(diff) < Fraction.epsilon)
          break;
#if CALCULATE_LOOP_STATISTICS
        loops++;
#endif
        // The desired fraction is current fraction (numerator/denominator) +/- the difference
        // Convert difference to fraction in the same manner as starting approximation
        // (numerator = 1 and denominator = 1/diff) and add to current fraction.
        // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
        long dd;
        dd=(long)(Math.Round(Math.Abs(1.0/diff)));
        numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
        denominator*=dd;
      }
    }
    Set(sign*((long)whole*(long)denominator+(long)numerator),(long)denominator);
  }

  public static Fraction operator+(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set((long)a._numerator*(long)b._denominator+(long)a._denominator*(long)b._numerator,
          (long)a._denominator*(long)b._denominator);
    return f;
  }

  public static Fraction operator-(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set((long)a._numerator*(long)b._denominator-(long)a._denominator*(long)b._numerator,
            (long)a._denominator*(long)b._denominator);
    return f;
  }

  public static Fraction operator*(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set((long)a._numerator*(long)b._numerator,(long)a._denominator*(long)b._denominator);
    return f;
  }

  public static Fraction operator/(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set((long)a._numerator*(long)b._denominator,(long)a._denominator*(long)b._numerator);
    return f;
  }

  protected static int cmp(Fraction lhs,Fraction rhs)
  {
    return (int)((long)lhs._numerator*(long)rhs._denominator - (long)rhs._numerator*(long)lhs._denominator);
  }

  public static bool operator ==(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) == 0;
  }

  public static bool operator !=(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) != 0;
  }

  public static bool operator <(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) < 0;
  }

  public static bool operator <=(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) <= 0;
  }

  public static bool operator >(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) > 0;
  }

  public static bool operator >=(Fraction lhs,Fraction rhs)
  {
    return cmp(lhs,rhs) >= 0;
  }

  public void Round(int denom)
  {
    Set((long)Math.Round((double)denom*(double)_numerator/(double)_denominator),denom);
  }

  public bool Equals(Fraction obj)
  {
    return cmp(this,obj) == 0;
  }

  public override bool Equals(Object obj)
  {
    return (obj is Fraction) && Equals((Fraction)obj);
  }

  public override int GetHashCode()
  {
    return _numerator ^ _denominator;
  }

  public int CompareTo(object obj) {
    if (obj == null) return 1;

    Fraction otherFraction = obj as Fraction;
    if (otherFraction != null)
      return cmp(this,otherFraction);
    else
      throw new ArgumentException("Object is not a Fraction");
  }

  public override string ToString()
  {
    if(_denominator==1)
      return _numerator.ToString();
    return String.Format("{0}/{1}",_numerator,_denominator);
  }

  public virtual string ToStringMixed()
  {
    int whole = _numerator/_denominator;
    if(whole == 0)
      return ToString();
    int num=_numerator-whole*_denominator;
    if(num == 0)
      return whole.ToString();
    return String.Format("{0} {1}/{2}",whole,num,_denominator);
  }

  static private Regex mixedFractionRegex = new Regex("^\\s*([+-]?\\d+)\\s+(\\d+)/(\\d+)\\s*");
  static private Regex fractionRegex = new Regex(@"^\s*([+-]?\d+)/(\d+)\s*");
  static public Fraction Parse(string s)
  {
    Fraction f = new Fraction();
    try {
      double d = double.Parse(s);
      f.Set(d);
    } catch (System.FormatException ) {
      Match match = fractionRegex.Match(s);
      if(match.Groups[0].Length > 0) {
        f.Set(int.Parse(match.Groups[1].ToString()),int.Parse(match.Groups[2].ToString()));
      } else {
        match = mixedFractionRegex.Match(s);
        if(match.Groups[0].Length > 0) {
          f.Set(int.Parse(match.Groups[1].ToString()),int.Parse(match.Groups[2].ToString()),int.Parse(match.Groups[3].ToString()));
        } else {
          throw new System.FormatException(s);
        }
      }
    }
    return f;
  }

  public static implicit operator double(Fraction f) => (((double)f._numerator)/((double)f._denominator));
  public static explicit operator Fraction(double d) => new Fraction(d);
}
