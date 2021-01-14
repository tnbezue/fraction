#include "Fraction.bi"

Constructor Fraction()
  numerator_ = 0
  denominator_ = 1
End Constructor

Constructor Fraction(ByRef o as Fraction)
  numerator_ = o.numerator_
  denominator_ = o.denominator_
end Constructor
Constructor Fraction(n as LongInt)
  numerator_ = n
  denominator_ = 1
End Constructor

Constructor Fraction(n as LongInt,d as LongInt)
  set(n,d)
End Constructor

Constructor Fraction(w as LongInt,n as LongInt,d as LongInt)
  set(w,n,d)
End Constructor

Constructor Fraction(v as Double)
  set(v)
End Constructor

Constructor Fraction(s as String)

End Constructor

Property Fraction.numerator() as LongInt
  Property = numerator_
End Property

Property Fraction.denominator() as LongInt
  Property = denominator_
End Property

dim as Double Fraction.Epsilon = 5e-6
dim as Integer Fraction.Loops = 0
Static Function Fraction.GCD(a as LongInt, b as LongInt) as LongInt
  Dim t as LongInt
  while b <> 0
    t = b
    b = a mod b
    a = t
  wend
  GCD = a
end Function

Sub Fraction.Set(n as longInt)
  numerator_=n
  denominator_=1
End Sub

Sub Fraction.Set(n as LongInt,d as LongInt)
  if d < 0 then
    d = -d
    n = -n
  end if

  dim divisor as longInt
  divisor = GCD(abs(n),d)
  if d <> 1 then
    n/=divisor
    d/=divisor
  end if

  numerator_=n
  denominator_=d
end Sub

Sub Fraction.Set(w as LongInt,n as LongInt,d as LongInt)
  dim sign as LongInt
  sign = 1
  if w < 0 then
    sign = -sign
    w=-w
  end if
  if n < 0 then
    sign = -sign
    n=-n
  end if
  if d < 0 then
    sign = -sign
    d=-d
  end if
  set(sign*(w*d+n),d)
end Sub

Sub Fraction.Set(v as Double)
  Loops = 0
  dim as LongInt hm2 = 0,hm1=1, h=0
  dim as LongInt km2 = 1,km1=0, k=0
  dim as Double val = v
  dim a as LongInt
  while true
    a=int(val)
    h=a*hm1 + hm2
    k=a*km1 + km2
    if abs(Cdbl(h)/Cdbl(k)-v) < Epsilon then
      exit while
    end if
    val=1.0/(val - Cdbl(a))
    hm2=hm1
    hm1=h
    km2=km1
    km1=k
    Loops += 1
  wend
  if k < 0 then
    k = -k
    h = -h
  end if
  numerator_=h
  denominator_=k
end Sub

Function Fraction.Round(ByVal denom as LongInt) as Fraction
  dim as Fraction f = this
  if denom < denominator_ then
    f.set(numerator_*denom/denominator_,denom)
  end if
  return f
end Function

Operator Fraction.Cast() as Double
  return Cdbl(numerator_)/Cdbl(denominator_)
end Operator

Operator Fraction.Let (ByVal rhs as Double)
  set(rhs)
End Operator

Operator Fraction.+= (ByRef rhs as Fraction)
  set(numerator_*rhs.denominator_ + denominator_*rhs.numerator_,denominator_*rhs.denominator_)
end Operator

Operator Fraction.-= (ByRef rhs as Fraction)
  set(numerator_*rhs.denominator_ - denominator_*rhs.numerator_,denominator_*rhs.denominator_)
end Operator

Operator Fraction.*= (ByRef rhs as Fraction)
  set(numerator_*rhs.numerator_,denominator_*rhs.denominator_)
end Operator

Operator Fraction./= (ByRef rhs as Fraction)
  set(numerator_*rhs.denominator_,denominator_*rhs.numerator_)
end Operator

Operator Fraction.\= (ByRef rhs as Fraction)
  this /= rhs
  set(fix(numerator_/denominator_),1)
end Operator

Operator Fraction.^= (ByRef rhs as Fraction)
  dim as Double b = this
  dim as Double e = rhs
  if b < 0 and fix(e) <> e then

  end if
  dim as Double r = b^e
  if e < 0 then
    r = 1.0/r
  end if
  set(r)
end Operator

Operator + (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
  dim as Fraction f = lhs
  f+=rhs
  return f
end Operator

Operator Fraction.+= (ByVal rhs as Double)
  dim as Fraction f
  f:set(rhs)
  this+=f
end Operator

Operator Fraction.-= (ByVal rhs as Double)
  dim as Fraction f
  f:set(rhs)
  this-=f
end Operator

Operator Fraction.*= (ByVal rhs as Double)
  dim as Fraction f
  f:set(rhs)
  this*=f
end Operator

Operator Fraction./= (ByVal rhs as Double)
  dim as Fraction f
  f:set(rhs)
  this/=f
end Operator

Operator Fraction.\= (ByVal rhs as Double)
  dim as Fraction f
  f:set(rhs)
  this\=f
end Operator

Operator - (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
  dim as Fraction f = lhs
  f-=rhs
  return f
end Operator

Operator * (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
  dim as Fraction f = lhs
  f*=rhs
  return f
end Operator

Operator / (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
  dim as Fraction f = lhs
  f/=rhs
  return f
end Operator

Operator + (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
  dim as Fraction temp = rhs
  return lhs+temp
End Operator

Operator - (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
  dim as Fraction temp = rhs
  return lhs-temp
End Operator

Operator * (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
  dim as Fraction temp = rhs
  return lhs*temp
End Operator

Operator / (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
  dim as Fraction temp = rhs
  return lhs/temp
End Operator

Operator + (ByVal lhs as Double, ByRef rhs as Fraction) as Double
  return lhs+CDbl(rhs)
End Operator

Operator - (ByVal lhs as Double, ByRef rhs as Fraction) as Double
  return lhs-CDbl(rhs)
End Operator

Operator * (ByVal lhs as Double, ByRef rhs as Fraction) as Double
  return lhs*CDbl(rhs)
End Operator

Operator / (ByVal lhs as Double, ByRef rhs as Fraction) as Double
  return lhs/CDbl(rhs)
End Operator

Operator \ (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
  dim as Fraction f = lhs/rhs
  return Fraction(f.numerator \ f.denominator, 1)
end Operator

Operator \ (ByRef lhs as Fraction, ByVal rhs as double) as Fraction
  dim as Fraction f = lhs/rhs
  return Fraction(f.numerator \ f.denominator, 1)
end Operator

Operator \ (ByVal rhs as Double, ByRef lhs as Fraction) as Double
  return fix(lhs/rhs)
end Operator

Operator Fraction.Cast() as String
  if denominator_ = 1 then
    return str(numerator_)
  end if
  return str(numerator_)+"/"+str(denominator_)
end Operator

Operator - (ByRef rhs as Fraction) as Fraction
  return Fraction(-rhs.numerator,rhs.denominator)
end Operator

Constructor MixedFraction()
  numerator_=0
  denominator_=1
end Constructor

Constructor MixedFraction(n as LongInt,d as LongInt)
  set(n,d)
End Constructor

Constructor MixedFraction(w as LongInt,n as LongInt,d as LongInt)
  set(w,n,d)
End Constructor

Constructor MixedFraction(v as Double)
  set(v)
End Constructor

Operator MixedFraction.Cast() as String
  dim as LongInt whole
  whole = numerator_ \ denominator_
  dim as String fstr = ""
  if whole <> 0 then
    dim as LongInt n = abs(numerator) - abs(whole)*denominator_
    fstr = str(whole)
    if n <> 0 then
      fstr += " "+str(n)+"/"+str(denominator_)
    end if
  else
    fstr = str(Fraction(numerator_,denominator_))
  end if
  return fstr
end Operator

Operator - (ByRef rhs as MixedFraction) as MixedFraction
  return MixedFraction(-rhs.numerator,rhs.denominator)
end Operator
