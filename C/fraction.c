#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "fraction.h"

// Euclid's algorithm to find greatest common divisor
int fraction_gcd(register int a,register int b)
{
  register int t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/*
  Reduces numerator and denominator.
  Assignes to fraction.
*/
void fraction_set(fraction_t* f,int n,int d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int divisor;
  if((divisor=fraction_gcd(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

  f->numerator_=n;
  f->denominator_=d;
}

fraction_t fraction_plus_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_set(&f,a.numerator_*b.denominator_ + b.numerator_*a.denominator_,a.denominator_*b.denominator_);
  return f;
}

fraction_t fraction_minus_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_set(&f,a.numerator_*b.denominator_ - b.numerator_*a.denominator_,a.denominator_*b.denominator_);
  return f;
}

fraction_t fraction_times_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_set(&f,a.numerator_*b.numerator_,a.denominator_*b.denominator_);
  return f;
}

fraction_t fraction_divided_by_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_set(&f,a.numerator_*b.denominator_,a.denominator_*b.numerator_);
  return f;
}

int fraction_cmp(fraction_t lhs,fraction_t rhs)
{
  return lhs.numerator_*rhs.denominator_ - rhs.numerator_*lhs.denominator_;
}

fraction_t fraction_abs(fraction_t f)
{
  fraction_t f_abs;
  fraction_set(&f_abs,abs(f.numerator_),f.denominator_);
  return f_abs;
}

double fraction_epsilon=5e-7;

fraction_t fraction_from_double(double d)
{
  fraction_t f;
  fraction_set_double(&f,d);
  return f;
}

#ifdef CALCULATE_LOOP_STATISTICS
int nLoops;
#endif

// Continued fraction algorithm for converting floating point to fraction
// https://en.wikipedia.org/wiki/Continued_fraction
void fraction_set_double(fraction_t* f,double value)
{
  register int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = value;
#ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
#endif
  while(1) {
    int a=v;
    h=a*hm1 + hm2;
    k=a*km1 + km2;
    if(fabs(value - (double)h/(double)k) < fraction_epsilon)
      break;
    v = 1.0/(v - a);
    hm2=hm1;
    hm1=h;
    km2=km1;
    km1=k;
#ifdef CALCULATE_LOOP_STATISTICS
    nLoops++;
#endif
  }
  if(k<0) {
    k=-k;
    h=-h;
  }
  f->numerator_=h;
  f->denominator_=k;
}

#if 0
void fraction_set_double(fraction_t* f,double d)
 {
  int sign = d < 0 ? -1 : 1;
  int64_t whole = labs(d);
  double fract=fabs(d)-whole;
  int64_t numerator=0;
  int64_t denominator=1; // Round to next whole number if very close to it
 #ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
 #endif
  if(fract > fraction_epsilon) {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/17
    numerator=1;
    denominator=round(1/fract); // Round to next whole number if very close to it
    while(1) {
      // End if it's close enough to fract
      double value=(double)numerator/(double)denominator;
      double diff=value-fract;
      if(fabs(diff) < fraction_epsilon)
        break;
 #ifdef CALCULATE_LOOP_STATISTICS
      nLoops++;
 #endif
      // The desired fraction is current fraction (numerator/denominator) +/- the difference
      // Convert difference to fraction in the same manner as starting approximation
      // (numerator = 1 and denominator = 1/diff) and add to current fraction.
      // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
      int64_t dd;
      dd=round(fabs(1.0/diff)); // Round to next whole number if very close to it.
      numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
      denominator*=dd;
    }
   }
  // Reduce fraction by dividing numerator and denominator by greatest common divisor
//  fraction_set(f,sign*(whole*denominator+numerator),denominator);
  f->numerator_ = sign*(whole*denominator+numerator);
  f->denominator_ = denominator;

 }
#endif
double fraction_to_double(fraction_t f)
{
  return ((double)f.numerator_)/((double)f.denominator_);
}

// If denominator is greater than specified denom, then fraction is adjusted to use
// new denominator.
void fraction_round(fraction_t* f,int denom)
{
  if(f->denominator_ > denom) {
    fraction_set(f,(int)round((double)denom*(double)f->numerator_/(double)f->denominator_),denom);
  }
}

// String shou
void fraction_to_s(fraction_t f,char* str,int n)
{
  int np=snprintf(str,n,"%d",f.numerator_);
  if(f.denominator_ != 1)
    snprintf(str+np,n-np,"/%d",f.denominator_);
}

// String shou
void fraction_to_mixed_s(fraction_t f,char* str,int n)
{
  int whole=f.numerator_/f.denominator_;
  if(whole != 0) {
    int np=snprintf(str,n,"%d",whole);
    int num = f.numerator_ - whole*f.denominator_;
    if(num != 0) {
      num=abs(num);
      snprintf(str+np,n-np," %d/%d",num,f.denominator_);
    }
  } else
    fraction_to_s(f,str,n);
}
