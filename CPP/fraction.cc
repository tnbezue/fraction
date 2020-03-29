#include "fraction.hh"
#include <cmath>

double fraction_t::epsilon = 5e-6;

int fraction_t::gcd(int a,int b)
{
  int t;
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
void fraction_t::set(int n,int d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int divisor;
  if((divisor=gcd(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

  numerator_=n;
  denominator_=d;
}

#ifdef CALCULATE_LOOP_STATISTICS
int nLoops;
#endif

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

fraction_t& fraction_t::round(int denom)
{
  if(denominator_ > denom)
    set(static_cast<int>(::round(static_cast<double>(numerator_)*static_cast<double>(denom)
          /static_cast<double>(denominator_))),static_cast<int>(denom));
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
      numerator=::abs(numerator);
      sprintf(str+np," %d/%d",numerator,denominator_);
    }
    return std::string(str);
  }
  return to_s();
}
