#pragma once

Type Fraction
  Declare Constructor()
  Declare Constructor(ByRef o as Fraction)
  Declare Constructor(n as LongInt)
  Declare Constructor(n as LongInt,d as LongInt)
  Declare Constructor(w as LongInt,n as LongInt,d as LongInt)
  Declare Constructor(v as Double)
  Declare Constructor(s as String)
  Declare Property numerator() as LongInt
  Declare Property denominator() as LongInt
  Declare Static Function GCD(a as LongInt, b as LongInt) as LongInt
  Declare Sub Set(n as LongInt)
  Declare Sub Set(n as LongInt,d as LongInt)
  Declare Sub Set(w as LongInt,n as LongInt,d as LongInt)
  Declare Sub Set(v as Double)
  Declare Sub Set(s as String)
  Declare Function Round(ByVal denom as LongInt) as Fraction
  Static Epsilon as Double
  Static Loops as Integer

  Declare Operator cast () as Double
  Declare Operator cast () as String

  Declare Operator Let (ByVal rhs as Double)

  Declare Operator += (ByRef lhs as Fraction)
  Declare Operator -= (ByRef lhs as Fraction)
  Declare Operator *= (ByRef lhs as Fraction)
  Declare Operator /= (ByRef lhs as Fraction)
  Declare Operator \= (ByRef lhs as Fraction)
  Declare Operator ^= (ByRef lhs as Fraction)

  Declare Operator += (ByVal lhs as Double)
  Declare Operator -= (ByVal lhs as Double)
  Declare Operator *= (ByVal lhs as Double)
  Declare Operator /= (ByVal lhs as Double)
  Declare Operator \= (ByVal rhs as Double)
  Declare Operator ^= (ByVal rhs as Double)

protected:
  as LongInt numerator_
  as LongInt denominator_
rem  Declare Sub SetPrivate(n as LongInt,d as LongInt)
End Type

Declare Operator - (ByRef rhs as Fraction ) as Fraction

Declare Operator + (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
Declare Operator - (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
Declare Operator * (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
Declare Operator / (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction

Declare Operator + (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
Declare Operator - (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
Declare Operator * (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
Declare Operator / (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction

Declare Operator + (ByVal lhs as Double, ByRef rhs as Fraction) as Double
Declare Operator - (ByVal lhs as Double, ByRef rhs as Fraction) as Double
Declare Operator * (ByVal lhs as Double, ByRef rhs as Fraction) as Double
Declare Operator / (ByVal lhs as Double, ByRef rhs as Fraction) as Double

Declare Operator \ (ByRef lhs as Fraction, ByRef rhs as Fraction) as Fraction
Declare Operator \ (ByRef lhs as Fraction, ByVal rhs as Double) as Fraction
Declare Operator \ (ByVal lhs as Double, ByRef rhs as Fraction) as Double

Type MixedFraction extends Fraction
  Declare Constructor()
  Declare Constructor(w as LongInt,n as LongInt)
  Declare Constructor(w as LongInt,n as LongInt,d as LongInt)
  Declare Constructor(v as Double)
  Declare Operator cast () as String
End Type

Declare Operator - (ByRef rhs as MixedFraction ) as MixedFraction
