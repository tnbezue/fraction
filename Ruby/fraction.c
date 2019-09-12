#include "ruby.h"
#include <time.h>
// Euclid's algorithm to find greatest common divisor
//int64_t fraction_gcd(int64_t a,int64_t b)
static int64_t private_fraction_gcd(int64_t a,int64_t b)
{
  int64_t t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}

typedef struct {
  int32_t numerator;
  int32_t denominator;
} fraction_private_t;

fraction_private_t rb_get_fraction(VALUE self)
{
  fraction_private_t f;
  f.numerator = rb_iv_get(self,"@numerator");
  f.denominator = rb_iv_get(self,"@denominator");
}

void rb_set_fraction(VALUE self,fraction_private_t f)
{
  rb_iv_set(self,"@numerator",INT2FIX(f.numerator));
  rb_iv_set(self,"@denominator",INT2FIX(f.denominator));
}

static void fraction_set_long_long(VALUE self,int64_t n,int64_t d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int64_t divisor;
  if((divisor=private_fraction_gcd(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

  // Result should fit in an integer value
  int64_t max = labs(n) < d ? d : labs(n);
  if(max > INT32_MAX) {
    double scale=(double)max/((double)INT32_MAX);
    // To ensure below integer max, truncate rather than round
    n=(int64_t)((double)n/scale);
    d=(int64_t)((double)d/scale);
    // May need to be reduced again
    if((divisor=private_fraction_gcd(labs(n),d)) != 1) {
      n/=divisor;
      d/=divisor;
    }
  }

  rb_iv_set(self,"@numerator",INT2FIX(n));
  rb_iv_set(self,"@denominator",INT2FIX(d));
}

#ifdef CALCULATE_LOOP_STATISTICS
VALUE loops;
int fraction_loops;
#endif
static double fraction_epsilon=5e-6;
static void fraction_set_double(VALUE self,double d)
{
  int sign = d < 0 ? -1 : 1;
  int64_t whole = labs(d);
  double fract=fabs(d)-whole;
  int64_t numerator=0;
  int64_t denominator=1; // Round to next whole number if very close to it
#ifdef CALCULATE_LOOP_STATISTICS
  fraction_loops=0;
#endif
  if(fract > fraction_epsilon) {
    // Starting approximation is 1 for numerator and 1/fract for denominator
    // For example, if converting 0.06 to fraction, 1/0.06 = 16.666666667
    // So starting fraction is 1/17
    numerator=1;
    denominator=round(1.0/fract);
    while(1) {
      // End if it's close enough to fract
      double value=(double)numerator/(double)denominator;
      double diff=value-fract;
      if(fabs(diff) < fraction_epsilon)
        break;
#ifdef CALCULATE_LOOP_STATISTICS
      fraction_loops++;
#endif
      // The desired fraction is current fraction (numerator/denominator) +/- the difference
      // Convert difference to fraction in the same manner as starting approximation
      // (numerator = 1 and denominator = 1/diff) and add to current fraction.
      // numerator/denominator + 1/dd = (numerator*dd + denominator)/(denominator*dd)
      int64_t dd;
      dd=round(fabs(1.0/diff));
      numerator=numerator*dd+(diff < 0 ? 1 : -1)*denominator;
      denominator*=dd;
    }
  }
  // Reduce fraction by dividing numerator and denominator by greatest common divisor
  fraction_set_long_long(self,sign*(whole*denominator+numerator),denominator);

#ifdef CALCULATE_LOOP_STATISTICS
  loops=INT2FIX(fraction_loops);
#endif
}

VALUE rb_cFraction;


VALUE fraction_gcd(VALUE self, VALUE ra,VALUE rb)
{
  return INT2FIX(private_fraction_gcd(FIX2INT(ra),FIX2INT(rb)));
}

static VALUE fraction_initialize(int argc, VALUE *argv, VALUE self)
{
  rb_iv_set(self,"@numerator",INT2FIX(0));
  rb_iv_set(self,"@denominator",INT2FIX(1));
  VALUE a1,a2,a3;
  int n_args = rb_scan_args(argc,argv,"03",&a1,&a2,&a3);
  switch (n_args) {
    case 1: /* Integer, floating point, or string */
      switch(TYPE(a1)) {
        case T_FIXNUM:
          fraction_set_long_long(self,FIX2INT(a1),1);
          break;

        case T_FLOAT:
          fraction_set_double(self,NUM2DBL(a1));
          break;

        case T_STRING:
          break;

//        default: /* Invalid arg */
      }
      break;

    case 2: /* Two integers -- numerator and denominator */
      if(TYPE(a1) == T_FIXNUM && TYPE(a2) == T_FIXNUM) {
        fraction_set_long_long(self,FIX2INT(a1),FIX2INT(a2));
      } else {
        /* Invalid arguments */
      }
      break;

    case 3: /* Three integers -- whole, numerator, denominator (mixed fraction) */
      if(TYPE(a1) == T_FIXNUM && TYPE(a2) == T_FIXNUM && TYPE(a3) == T_FIXNUM) {
        int64_t w=FIX2INT(a1);
        int64_t d=FIX2INT(a3);
        fraction_set_long_long(self,w*d+(w<0 ? -1 : 1)*FIX2INT(a2),d);
      } else {
        /* Invalid arguments */
      }
      break;
  }
  return self;
}

VALUE fraction_to_i(VALUE self)
{
  int32_t n=FIX2INT(rb_iv_get(self,"@numerator"));
  int32_t d=FIX2INT(rb_iv_get(self,"@denominator"));
  return INT2FIX((int)(((double)n)/((double)d)));
}

VALUE fraction_to_f(VALUE self)
{
  int32_t n=FIX2INT(rb_iv_get(self,"@numerator"));
  int32_t d=FIX2INT(rb_iv_get(self,"@denominator"));
  return DBL2NUM((double)n/(double)d);
}

VALUE fraction_to_s(VALUE self)
{
  int32_t n=FIX2INT(rb_iv_get(self,"@numerator"));
  int32_t d=FIX2INT(rb_iv_get(self,"@denominator"));
  char temp[64];
  int np=sprintf(temp,"(%d",n);
  if(d!=1)
    np+=sprintf(temp+np,"/%d",d);
  sprintf(temp+np,")");
  return rb_str_new2(temp);
}

VALUE fraction_to_mixed_s(VALUE self)
{
  int32_t n=FIX2INT(rb_iv_get(self,"@numerator"));
  int32_t d=FIX2INT(rb_iv_get(self,"@denominator"));
  if(d > n)
    return fraction_to_s(self);
  int32_t whole = n/d;
  int32_t rem = n % d;
  char temp[64];
  int np=sprintf(temp,"(%d",whole);
  if(rem > 0)
    np+=sprintf(temp+np," %d/%d",rem,d);
  sprintf(temp+np,")");
  return rb_str_new2(temp);
}

#define __fraction_cmp__(n,d,on,od)
VALUE fraction_cmp(VALUE self,VALUE other)
{
  int32_t n=FIX2INT(rb_iv_get(self,"@numerator"));
  int32_t d=FIX2INT(rb_iv_get(self,"@denominator"));
  int32_t on=FIX2INT(rb_iv_get(other,"@numerator"));
  int32_t od=FIX2INT(rb_iv_get(other,"@denominator"));
  int64_t nod = (int64_t)n*(int64_t)(od);
  int64_t don = (int64_t)d*(int64_t)(on);
  if(nod < don)
    return INT2FIX(-1);
  if(don < nod)
    return INT2FIX(1);
  return INT2FIX(0);
}
/*
static VALUE fraction_numerator(VALUE self)
{
  return rb_iv_get(self,"@numerator");
}

static VALUE fraction_denominator(VALUE self)
{
  return rb_iv_get(self,"@denominator");
}
*/
void Init_fraction()
{

  rb_cFraction = rb_define_class("Fraction",rb_cNumeric);
  rb_define_method(rb_cFraction, "initialize",fraction_initialize , -1);
  rb_define_attr(rb_cFraction,"numerator",1,0);
  rb_define_attr(rb_cFraction,"denominator",1,0);
  rb_define_singleton_method(rb_cFraction,"gcd",fraction_gcd,2);
  rb_define_method(rb_cFraction,"to_i",fraction_to_i,0);
  rb_define_method(rb_cFraction,"to_f",fraction_to_f,0);
  rb_define_method(rb_cFraction,"to_s",fraction_to_s,0);
  rb_define_method(rb_cFraction,"to_mixed_s",fraction_to_mixed_s,0);
  rb_define_method(rb_cFraction,"<=>",fraction_cmp,1);
/*  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);*/

#ifdef CALCULATE_LOOP_STATISTICS
  rb_define_variable("$fraction_loops",&loops);
#endif

}
