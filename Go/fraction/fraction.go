package fraction
import ("math";"fmt";"reflect")

type Fraction struct {
	numerator int
	denominator int
}

func(f *Fraction) Numerator() int {
  return f.numerator;
}

func(f *Fraction) Denominator() int {
  return f.denominator;
}

func GCD(a int,b int) int {
  var t int
  if a<0 {
    a = -a
  }
  if b<0 {
    b = -b
  }
  for b!=0 {
    t = b
    b = a % b
    a = t
  }
  return a
}

func abs(n int) int {
  if n<0 {
    return -n
  }
  return n
}

func(f* Fraction) reduce() {
  if f.denominator<0 {
    f.denominator=-f.denominator
    f.numerator=-f.numerator
  }

  var divisor int
  divisor=GCD(abs(f.numerator),f.denominator)
  if divisor != 1 {
    f.numerator/=divisor
    f.denominator/=divisor
  }
}

func(f* Fraction) Set(args ...interface{})  {

  var w int
  nArgs :=len(args)
  switch nArgs {
    case 1:
      /* any int type (int, int32, etc) or float (float32 or float64) */
      switch args[0].(type) {
        case int,int8,int16,int32,int64:
          f.numerator=int(reflect.ValueOf(args[0]).Int())
          f.denominator=1
        case float32,float64:
          f.setfloat(reflect.ValueOf(args[0]).Float())

        default: /* Error */
      }

    case 2: /* Two int types for numerator and denominator. Panic if not ints  */
      f.numerator=int(reflect.ValueOf(args[0]).Int())
      f.denominator=int(reflect.ValueOf(args[1]).Int())

    case 3: /* Three int types for whole, numberator, denominator (mixed fraction). Panic if not ints */
      w=int(reflect.ValueOf(args[0]).Int())
      f.denominator=int(reflect.ValueOf(args[2]).Int())
      if w<0 {
       f.numerator =w*f.denominator-int(reflect.ValueOf(args[1]).Int())
      } else {
       f.numerator =w*f.denominator+int(reflect.ValueOf(args[1]).Int())
      }

      default:  /* Error */
  }
  f.reduce();
}

func(f *Fraction) Plus(other Fraction) {
  f.Set(f.numerator*other.denominator + f.denominator*other.numerator,f.denominator*other.denominator)
}

func(f *Fraction) Minus(other Fraction) {
  f.Set(f.numerator*other.denominator - f.denominator*other.numerator,f.denominator*other.denominator)
}

func(f *Fraction) Times(other Fraction) {
  f.Set(f.numerator*other.numerator,f.denominator*other.denominator)
}

func(f *Fraction) DividedBy(other Fraction) {
  f.Set(f.numerator*other.denominator,f.denominator*other.numerator)
}

func FractionPlusFraction(lhs Fraction,rhs Fraction) Fraction {
  var f Fraction = lhs
  f.Plus(rhs)
  return f
}

func FractionMinusFraction(lhs Fraction,rhs Fraction) Fraction {
  var f Fraction = lhs
  f.Minus(rhs)
  return f
}

func FractionTimesFraction(lhs Fraction,rhs Fraction) Fraction {
  var f Fraction = lhs
  f.Times(rhs)
  return f
}

func FractionDividedByFraction(lhs Fraction,rhs Fraction) Fraction {
  var f Fraction = lhs
  f.DividedBy(rhs)
  return f
}

func cmp(lhs Fraction,rhs Fraction) int {
  return lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator
}

func FractionEqFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) == 0;
}

func FractionNeFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) != 0;
}

func FractionLtFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) < 0;
}

func FractionLeFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) <= 0;
}

func FractionGtFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) > 0;
}

func FractionGeFraction(lhs Fraction,rhs Fraction) bool {
  return cmp(lhs,rhs) >= 0;
}

// Remove Loops here and in setfloat routine for production version
var Loops int

var epsilon float64 = 5e-6
func(f *Fraction) setfloat(d float64)  {
  var hm2,hm1,km2,km1,h,k int = 0,1,1,0,0,0
  var v float64 = d
  Loops=0
  for true {
    var a int = int(v)
    h=a*hm1 + hm2
    k=a*km1 + km2
    if math.Abs(d - float64(h)/float64(k)) < epsilon {
      break
    }
    v = 1.0/(v - float64(a))
    hm2=hm1
    hm1=h
    km2=km1
    km1=k
    Loops++
  }
  if k<0 {
    k=-k
    h=-h
  }
  f.numerator=h
  f.denominator=k

/*  var sign int64
  if d < 0 {
    sign = -1
  } else {
    sign = 1
  }
  var whole int64
  whole = int64(math.Abs(d))
  var fract float64
  fract=math.Abs(d)-float64(whole)
  var numerator int64 = 0
  var denominator int64 = 1
  Loops=0
  if fract > epsilon {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/17
    numerator=1;
    denominator=int64(math.Round(1.0/fract))
    for true {
      // End if it's close enough to fract
      var value float64
      value=float64(numerator)/float64(denominator)
      var diff float64
      diff=value-fract
      if math.Abs(diff) < epsilon {
        break;
      }
      Loops++
      // The desired fraction is current fraction (numerator/denominator) +/- the difference
      // Convert difference to fraction in the same manner as starting approximation
      // (numerator = 1 and denominator = 1/diff) and add to current fraction.
      // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
      var dd int64
      dd=int64(math.Round(math.Abs(1.0/diff)))  // Round to next whole number if very close to it.
      numerator*=dd
      if diff < 0 {
        numerator+=denominator
      } else {
        numerator-=denominator
      }
      denominator*=dd
    }
  }
  // Reduce fraction by dividing numerator and denominator by greatest common divisor
  f.numerator = sign*(whole*denominator+numerator)
  f.denominator = denominator*/
}

func(f Fraction) Abs() Fraction {
  if f.numerator < 0 {
    f.numerator = -f.numerator;
  }
  return f;
}

func(f Fraction) Round(denom int) Fraction {
  if int(f.denominator) > denom {
    f.Set(int(math.Round(float64(denom)*float64(f.numerator)/float64(f.denominator))),
        denom)
  }
  return f;
}

func(f Fraction) String() string {
  if f.denominator == 1 {
    return fmt.Sprintf("%v",f.numerator)
  }
  return fmt.Sprintf("%v/%v",f.numerator,f.denominator)
}

func(f Fraction) MixedString() string {
  if f.numerator < f.denominator {
    return f.String();
  }
  var w int
  var n int
  w = f.numerator / f.denominator
  n = f.numerator - w*f.denominator
  if n == 0 {
    return fmt.Sprintf("%v",w)
  }
  return fmt.Sprintf("%v %v/%v",w,n,f.denominator)
}
