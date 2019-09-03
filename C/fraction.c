#include <stdio.h>
#include <math.h>
#include "fraction.h"

// Euclid's algorithm to find greatest common divisor
int64_t fraction_gcd(int64_t a,int64_t b)
{
  int64_t t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/*
  Calculations are done with 64 bit integers. However, fraction uses 32 bit integers
  Reduces numerator and denominator.
  Assignes to fraction.
*/
static void fraction_adjust(fraction_t* f,int64_t n,int64_t d)
{
  if(d<0) {
    d=-d;
    n=-n;
  }
  int64_t divisor=fraction_gcd(abs(n),d);
  f->numerator_=n/divisor;
  f->denominator_=d/divisor;
}

fraction_t fraction_plus_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_adjust(&f,
        ((int64_t)a.numerator_)*((int64_t)b.denominator_) + ((int64_t)b.numerator_)*((int64_t)a.denominator_),
        ((int64_t)a.denominator_)*((int64_t)b.denominator_));
  return f;
}

fraction_t fraction_minus_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_adjust(&f,
        ((int64_t)a.numerator_)*((int64_t)b.denominator_) - ((int64_t)b.numerator_)*((int64_t)a.denominator_),
        ((int64_t)a.denominator_)*((int64_t)b.denominator_));
  return f;
}

fraction_t fraction_times_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_adjust(&f,
        ((int64_t)a.numerator_)*((int64_t)b.numerator_),
        ((int64_t)a.denominator_)*((int64_t)b.denominator_));
  return f;
}

fraction_t fraction_divided_by_fraction(fraction_t a,fraction_t b)
{
  fraction_t f;
  fraction_adjust(&f,
        ((int64_t)a.numerator_)*((int64_t)b.denominator_),
        ((int64_t)a.denominator_)*((int64_t)b.numerator_));
  return f;
}

int fraction_cmp(fraction_t lhs,fraction_t rhs)
{
  return ((int64_t)lhs.numerator_)*((int64_t)rhs.denominator_) - ((int64_t)rhs.numerator_)*((int64_t)lhs.denominator_);
}

double fraction_epsilon=5e-8;

#ifdef CALCULATE_LOOP_STATISTICS
int loops;
#endif

fraction_t fraction_from_double(double d)
{
  fraction_t f;
  int sign = d < 0 ? -1 : 1;
  int64_t whole = abs(d);
  double fract=fabs(d-whole);
  int64_t numerator=0;
  int64_t denominator=1; // Round to next whole number if very close to it
#ifdef CALCULATE_LOOP_STATISTICS
  loops=0;
#endif
  if(fract > fraction_epsilon) {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/16
    numerator=1;
    denominator=1/fract+fraction_epsilon; // Round to next whole number if very close to it
    while(1) {
      // End if it's close enough to fract
      double value=(double)numerator/(double)denominator;
      double diff=value-fract;
      if(fabs(diff) < fraction_epsilon)
        break;
#ifdef CALCULATE_LOOP_STATISTICS
      loops++;
#endif
      // The desired fraction is current fraction (numerator/denominator) +/- the difference
      // Convert difference to fraction in the same manner as starting approximation
      // (numerator = 1 and denominator = 1/diff) and add to current fraction.
      // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
      int64_t dd;
      dd=fabs(1.0/diff)+fraction_epsilon; // Round to next whole number if very close to it.
      numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
      denominator*=dd;
    }
  }
  // Reduce fraction by dividing numerator and denominator by greatest common divisor
  numerator=sign*(whole*denominator+numerator);
  fraction_adjust(&f,sign*numerator,denominator);

  return f;
}

// String shou
void fraction_to_s(fraction_t f,char* str,int n)
{
  int np=snprintf(str,n,"%d",f.numerator_);
  if(f.denominator_ != 1)
    snprintf(str+np,n-np,"/%d",f.denominator_);
}

// String shou
void fraction_as_mixed_fraction_to_s(fraction_t f,char* str,int n)
{
  int whole=f.numerator_/f.denominator_;
  if(whole != 0) {
    int np=snprintf(str,n,"%d",whole);
    f.numerator_-=whole*f.denominator_;
    if(f.numerator_ != 0) {
      f.numerator_=abs(f.numerator_);
      snprintf(str+np,n-np," %d/%d",f.numerator_,f.denominator_);
    }
  } else
    fraction_to_s(f,str,n);
}
