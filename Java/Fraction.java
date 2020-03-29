import java.util.regex.Pattern;  // Used in parseFraction
import java.util.regex.Matcher;  // Used in parseFraction

public final class Fraction extends Number implements Comparable<Fraction> {
  private static final boolean calculate_loop_statistics = true;
  private int numerator_;
  private int denominator_;

  public static double epsilon = 0.000005;
  public Fraction()
  {
    numerator_=0;
    denominator_=1;
  }

  public Fraction(Fraction f)
  {
    numerator_=f.numerator_;
    denominator_=f.denominator_;
  }

  public Fraction(int n)
  {
    set(n,1);
  }

  public Fraction(int n,int d)
  {
    set(n,d);
  }

  public Fraction(int w,int n,int d)
  {
    set(w,n,d);
  }

  public Fraction(double v)
  {
    set(v);
  }

  public Fraction(String s)
  {
    set(s);
  }

  public int numerator()
  {
    return numerator_;
  }

  public int denominator()
  {
    return denominator_;
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

  public void set(int n,int d)
  {
    // Negative sign should be in numerator
    if(d<0) {
      n=-n;
      d=-d;
    }

    // Reduce to lowest fraction
    int divisor=Fraction.gcd(Math.abs(n),d);
    if(divisor != 1) {
      n/=divisor;
      d/=divisor;
    }

    numerator_=(int)n;
    denominator_=(int)d;
  }

  public void set(int w,int n,int d)
  {
    set(w*d+(w<0 ? -1 : 1)*n,d);
  }

  public static int nLoops;
  public void set(double d)
  {
  int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = d;
  nLoops=0;
  while(true) {
    int a=(int)v;
    h=a*hm1 + hm2;
    k=a*km1 + km2;
    if(Math.abs(d - (double)h/(double)k) < Fraction.epsilon)
      break;
    v = 1.0/(v -a);
    hm2=hm1;
    hm1=h;
    km2=km1;
    km1=k;
    nLoops++;
  }
  if(k<0) {
    k=-k;
    h=-h;
  }
  numerator_=h;
  denominator_=k;

/*    int sign = d<0 ? -1 : 1;
    int whole = Math.abs((long)d);
    double fract=Math.abs(d)-whole;
    long numerator=0;
    long denominator=1; // Round to next whole number if very close to it
    if(calculate_loop_statistics)
      loops=0;
    if(fract > Fraction.epsilon) {
      // Starting approximation is 1 for numerator and 1/fract for denominator
      // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
      // So starting fraction is 1/17
      numerator=1;
      denominator=(long)Math.round(1.0/fract);
      while(true) {
        // End if it's close enough to fract
        double value=(double)numerator/(double)denominator;
        double diff=value-fract;
        if(Math.abs(diff) < Fraction.epsilon)
          break;
        if(calculate_loop_statistics)
          loops++;
        // The desired fraction is current fraction (numerator/denominator) +/- the difference
        // Convert difference to fraction in the same manner as starting approximation
        // (numerator = 1 and denominator = 1/diff) and add to current fraction.
        // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
        long dd;
        dd=(long)Math.round(Math.abs(1.0/diff));
        numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
        denominator*=dd;
      }
    }

    set(sign*(whole*denominator+numerator),denominator);*/
  }

  public void set(String s)
  {
    Fraction f = Fraction.parseFraction(s);
    numerator_=f.numerator_;
    denominator_=f.denominator_;
  }

  public void plus(Fraction a)
  {
    set(numerator_*a.denominator_ + a.numerator_*denominator_,denominator_*a.denominator_);
  }

  public static Fraction add(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.plus(b);
    return r;
  }

  public void minus(Fraction a)
  {
    set(numerator_*a.denominator_ - a.numerator_*denominator_,denominator_*a.denominator_);
  }

  public static Fraction subtract(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.minus(b);
    return r;
  }

  public void times(Fraction a)
  {
    set(numerator_*a.numerator_,denominator_*a.denominator_);
  }

  public static Fraction multiply(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.times(b);
    return r;
  }

  public void divided_by(Fraction a)
  {
    set(numerator_*a.denominator_,denominator_*a.numerator_);
  }

  public static Fraction divide(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.divided_by(b);
    return r;
  }

  public void Round(int denom)
  {
    if(denom < denominator_)
      set((int)Math.round((double)denom*(double)numerator_/(double)denominator_),denom);
  }

  public double doubleValue()
  {
    return ((double)numerator_)/((double)denominator_);
  }

  public float floatValue()
  {
    return (float)doubleValue();
  }

  public long longValue()
  {
    return (long)doubleValue();
  }

  public int intValue()
  {
    return numerator_/denominator_;
  }

  public boolean equals(Object anotherObject)
  {
    return anotherObject.getClass() == Fraction.class ? compareTo((Fraction)anotherObject) == 0 : false;
  }

  public int compareTo(Fraction anotherFraction)
  {
    return (int)(numerator_*anotherFraction.denominator_ - anotherFraction.numerator_*denominator_);
  }

  public static int compare(Fraction lhs,Fraction rhs)
  {
    return lhs.compareTo(rhs);
  }

  public String toString()
  {
    String s=new String();
    s=s+numerator_;
    if(denominator_ != 1)
      s=s+"/"+denominator_;
    return s;
  }

  public String toMixedString()
  {
    String s=new String();
    int whole=numerator_/denominator_;
    if(whole==0)
      return toString();
    int num=numerator_-whole*denominator_;
    s=s+whole;
    if(num != 0)
      s=s+" "+num+"/"+denominator_;
    return s;
  }

  static private Pattern wnd=Pattern.compile("^\\s*([+-]?\\d+)\\s+(\\d+)/(\\d+)\\s*");
  static private Pattern nd=Pattern.compile("^\\s*([+-]?\\d+)/(\\d+)\\s*");

  static Fraction parseFraction(String s)
  {
    Fraction f = new Fraction();
    try {
      int l=Integer.parseInt(s);
      f.set(l);
    } catch(NumberFormatException ne1) {
      try {
        double d=Double.parseDouble(s);
        f.set(d);
      } catch(NumberFormatException ne2) {
        Matcher m=wnd.matcher(s);
        if(m.matches()) {
          f.set(Integer.parseInt(m.group(1)),Integer.parseInt(m.group(2)),Integer.parseInt(m.group(3)));
        } else {
          m=nd.matcher(s);
          if(m.matches()) {
            f.set(Integer.parseInt(m.group(1)),Integer.parseInt(m.group(2)));
          } else {
            throw new NumberFormatException(s);
          }
        }
      }
    }
    return f;
  }
}
