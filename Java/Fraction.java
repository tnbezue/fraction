import java.util.regex.Pattern;  // Used in parseFraction
import java.util.regex.Matcher;  // Used in parseFraction

public final class Fraction extends Number implements Comparable<Fraction> {
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

  public void set(long n,long d)
  {
    if(d<0) {
      n=-n;
      d=-d;
    }
    long divisor=Fraction.gcd(Math.abs(n),d);
    numerator_=(int)(n/divisor);
    denominator_=(int)(d/divisor);
  }

  public void set(long w,long n,long d)
  {
    set(w*d+(w<0 ? -1 : 1)*n,d);
  }

  public void set(double d)
  {
    long whole = (long)d;
    double fract=Math.abs(d-whole);
    long numerator=0;
    long denominator=1; // Round to next whole number if very close to it
    if(fract > Fraction.epsilon) {
      // Starting approximation is 1 for numerator and 1/fract for denominator
      // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
      // So starting fraction is 1/16
      numerator=1;
      denominator=(long)(1.0/fract+Fraction.epsilon); // Round to next whole number if very close to it
      while(true) {
        // End if it's close enough to fract
        double value=(double)numerator/(double)denominator;
        double diff=value-fract;
        if(Math.abs(diff) < Fraction.epsilon)
          break;
        // The desired fraction is current fraction (numerator/denominator) +/- the difference
        // Convert difference to fraction in the same manner as starting approximation
        // (numerator = 1 and denominator = 1/diff) and add to current fraction.
        // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
        long dd;
        dd=(long)(Math.abs(1.0/diff)+Fraction.epsilon); // Round to next whole number if very close to it.
        numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
        denominator*=dd;
      }
    }

    set(whole*denominator+(whole < 0 ? -1 : 1)*numerator,denominator);
  }

  public void set(String s)
  {
    Fraction f = Fraction.parseFraction(s);
    numerator_=f.numerator_;
    denominator_=f.denominator_;
  }

  public void plus(Fraction a)
  {
    set(((long)numerator_)*((long)a.denominator_) + ((long)a.numerator_)*((long)denominator_),
        ((long)denominator_)*((long)a.denominator_));
  }

  public static Fraction add(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.plus(b);
    return r;
  }

  public void minus(Fraction a)
  {
    set(((long)numerator_)*((long)a.denominator_) - ((long)a.numerator_)*((long)denominator_),
        ((long)denominator_)*((long)a.denominator_));
  }

  public static Fraction subtract(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.minus(b);
    return r;
  }

  public void times(Fraction a)
  {
    set(((long)numerator_)*((long)a.numerator_),((long)denominator_)*((long)a.denominator_));
  }

  public static Fraction multiply(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.times(b);
    return r;
  }

  public void divided_by(Fraction a)
  {
    set(((long)numerator_)*((long)a.denominator_),((long)denominator_)*((long)a.numerator_));
  }

  public static Fraction divide(Fraction a,Fraction b)
  {
    Fraction r=new Fraction(a);
    r.divided_by(b);
    return r;
  }

  public double doubleValue()
  {
    return ((double)numerator_)/((double)denominator_);
  }

  public float floatValue()
  {
    return ((float)numerator_)/((float)denominator_);
  }

  public long longValue()
  {
    return ((long)numerator_)/((long)denominator_);
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
    return (int)(((long)numerator_)*((long)anotherFraction.denominator_) - ((long)anotherFraction.numerator_)*((long)denominator_));
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

  public String toStringMixed()
  {
    String s=new String();
    int whole=numerator_/denominator_;
    if(whole==0)
      return toString();
    int num=numerator_-whole*denominator_;
    s=s+whole;
    if(numerator_ != 0)
      s=s+" "+num+"/"+denominator_;
    return s;
  }

  static private Pattern wnd=Pattern.compile("^\\s*(\\d+)\\s+(\\d+)/(\\d+)\\s*");
  static private Pattern nd=Pattern.compile("^\\s*(\\d+)/(\\d+)\\s*");

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