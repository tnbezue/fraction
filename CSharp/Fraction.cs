using System;
using System.Text.RegularExpressions;

public class Fraction : IComparable {
  protected int _numerator;
  protected int _denominator;

  public static double epsilon = 5e-7;

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

public static int gcd(int a,int b)
  {
    int t;
    while(b!=0) {
      t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  public void Set(int n,int d)
  {
    // Negative sign should be in numerator
    if(d<0) {
      n=-n;
      d=-d;
    }

    // Reduce to lowest fraction
    int divisor;
    if((divisor=Fraction.gcd(Math.Abs(n),d)) != 1) {
      n /= divisor;
      d /= divisor;
    }

    _numerator=(int)n;
    _denominator=(int)d;
  }

  public void Set(int w,int n,int d)
  {
    Set(w*d+(w<0 ? -1 : 1)*n,d);
  }

#if CALCULATE_LOOP_STATISTICS
  public static int nLoops=0;
#endif
  public void Set(double d)
  {
    int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
    double v = d;
#if CALCULATE_LOOP_STATISTICS
    nLoops=0;
#endif
    while(true) {
      int a=(int)v;
      h=a*hm1 + hm2;
      k=a*km1 + km2;
      if(Math.Abs(d - (double)h/(double)k) < Fraction.epsilon)
        break;
      v = 1.0/(v -a);
      hm2=hm1;
      hm1=h;
      km2=km1;
      km1=k;
#if CALCULATE_LOOP_STATISTICS
      nLoops++;
#endif
    }
    if(k<0) {
      k=-k;
      h=-h;
    }
    _numerator=h;
    _denominator=k;

  }

  public static Fraction operator+(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set((int)a._numerator*(int)b._denominator+(int)a._denominator*(int)b._numerator,
          (int)a._denominator*(int)b._denominator);
    return f;
  }

  public static Fraction operator-(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set(a._numerator*b._denominator-a._denominator*b._numerator,a._denominator*b._denominator);
    return f;
  }

  public static Fraction operator*(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set(a._numerator*b._numerator,a._denominator*b._denominator);
    return f;
  }

  public static Fraction operator/(Fraction a,Fraction b)
  {
    Fraction f=new Fraction();
    f.Set(a._numerator*b._denominator,a._denominator*b._numerator);
    return f;
  }

  protected static int cmp(Fraction lhs,Fraction rhs)
  {
    return (int)(lhs._numerator*rhs._denominator - rhs._numerator*lhs._denominator);
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
    Set((int)Math.Round((double)denom*(double)_numerator/(double)_denominator),denom);
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
