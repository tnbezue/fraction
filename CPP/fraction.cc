/*
		Copyright (C) 2019-2020  by Terry N Bezue

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include "fraction.hh"
#include <cmath>

double fraction_t::epsilon = 5e-6;

int64_t fraction_t::gcd_internal(int64_t a,int64_t b)
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
  Assignes to fraction.
*/
void fraction_t::set_internal(int64_t n,int64_t d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int64_t divisor;
  if((divisor=gcd_internal(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

  numerator_=n;
  denominator_=d;
}

#ifdef CALCULATE_LOOP_STATISTICS
int nLoops;
#endif

#if 0
fraction_t& fraction_t::operator=(double d)
{
  long hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = d;
#ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
#endif
  while(1) {
    long a=v;
    h=a*hm1 + hm2;
    k=a*km1 + km2;
//    printf("%lg %d %d %d %d %d %d %d\n",v,a,h,k,hm1,km1,hm2,km2);
    if(fabs(d - (double)h/(double)k) < fraction_t::epsilon)
      break;
    v = 1.0/(v -a);
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
  numerator_=h;
  denominator_=k;
  return *this;
}
#else
fraction_t& fraction_t::operator=(double d)
{
  int sign = d < 0 ? -1 : 1;
  int64_t whole = labs(d);
  double fract=fabs(d)-whole;
  int64_t numerator=0;
  int64_t denominator=1;
#ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
#endif
  if(fract > epsilon) {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/17
    numerator=1;
    denominator=::round(1.0/fract);
    while(true) {
      // End if it's close enough to fract
      double value=(double)numerator/(double)denominator;
      double diff=value-fract;
      if(fabs(diff) < epsilon)
        break;
#ifdef CALCULATE_LOOP_STATISTICS
      nLoops++;
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
  set_internal(sign*(whole*denominator+numerator),denominator);
  return *this;
}
#endif

fraction_t& fraction_t::round(int denom)
{
  if(denominator_ > denom)
    set_internal(static_cast<int64_t>(::round(static_cast<double>(numerator_)*static_cast<double>(denom)
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

int fraction_t::cmp(const fraction_t& lhs,const fraction_t& rhs)
{
  int64_t a = static_cast<int64_t>(lhs.numerator_)*static_cast<int64_t>(rhs.denominator_);
  int64_t b = static_cast<int64_t>(rhs.numerator_)*static_cast<int64_t>(lhs.denominator_);
  if(a<b) return -1;
  if(a>b) return 1;
  return 0;
}

int fraction_t::cmp(const fraction_t& lhs,double d)
{
  double value=static_cast<double>(lhs);
  if(fabs(value-d)<epsilon) return 0;
  if(value < d) return -1;
  return 0;
}

std::string mixed_fraction_t::to_s() const
{
  if (denominator_ > numerator_)
    return fraction_t::to_s();
  int whole=numerator_/denominator_;
  char str[64];
  int np=sprintf(str,"%d",whole);
  int numerator=numerator_-whole*denominator_;
  if(numerator != 0) {
    numerator=::abs(numerator);
    sprintf(str+np," %d/%d",numerator,denominator_);
  }
  return std::string(str);
}
