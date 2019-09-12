#include "fraction.hh"
#include <cmath>

double fraction_t::epsilon = 5e-6;

int64_t fraction_t::gcd(int64_t a,int64_t b)
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
void fraction_t::set(int64_t n,int64_t d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int64_t divisor;
  if((divisor=gcd(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

  // Result should fit in an integer value
  int64_t max = labs(n) < d ? d : labs(n);
  if(max > INT32_MAX) {
    double scale=static_cast<double>(max)/static_cast<double>(INT32_MAX);
    // To ensure below integer max, truncate rather than round
    n=static_cast<int64_t>(::round(static_cast<double>(n)/scale));
    d=static_cast<int64_t>(::round(static_cast<double>(d)/scale));
    // May need to be reduced again
    if((divisor=gcd(labs(n),d)) != 1) {
      n/=divisor;
      d/=divisor;
    }
  }

  numerator_=n;
  denominator_=d;
}

#ifdef CALCULATE_LOOP_STATISTICS
int loops;
#endif

fraction_t& fraction_t::operator=(double d)
{
  int sign = d < 0 ? -1 : 1;
  int64_t whole = labs(d);
  double fract=fabs(d)-whole;
  int64_t numerator=0;
  int64_t denominator=1;
#ifdef CALCULATE_LOOP_STATISTICS
  loops=0;
#endif
  if(fract > fraction_t::epsilon) {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/17
    numerator=1;
    denominator=::round(1/fract);
    while(1) {
      // End if it's close enough to fract
      double value=(double)numerator/(double)denominator;
      double diff=value-fract;
      if(fabs(diff) < fraction_t::epsilon)
        break;
#ifdef CALCULATE_LOOP_STATISTICS
      loops++;
#endif
      // The desired fraction is current fraction (numerator/denominator) +/- the difference
      // Convert difference to fraction in the same manner as starting approximation
      // (numerator = 1 and denominator = 1/diff) and add to current fraction.
      // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
      int64_t dd;
      dd=::round(fabs(1.0/diff));
      numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
      denominator*=dd;
    }
  }

  set(sign*(whole*denominator+numerator),denominator);
  return *this;
}

fraction_t& fraction_t::round(int denom)
{
  if(denominator_ > denom)
    set(static_cast<int64_t>(::round(static_cast<double>(numerator_)*static_cast<double>(denom)
          /static_cast<double>(denominator_))),static_cast<int64_t>(denom));
  return *this;
}

std::string fraction_t::to_s() const
{
  char str[64];
  int np=sprintf(str,"%d",numerator_);
  if(denominator_ != 1)
    sprintf(str+np,"/%d",denominator_);
  return std::string(str);
}

std::string fraction_t::to_mixed_s() const
{
  int whole=numerator_/denominator_;
  if(whole != 0) {
    char str[64];
    int np=sprintf(str,"%d",whole);
    int numerator=numerator_-whole*denominator_;
    if(numerator != 0) {
      numerator=abs(numerator);
      sprintf(str+np," %d/%d",numerator,denominator_);
    }
    return std::string(str);
  }
  return to_s();
}
