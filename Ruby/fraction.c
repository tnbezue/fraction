#include "ruby.h"
#include <time.h>
#include <ctype.h>

typedef struct {
  long numerator;
  long denominator;
} fraction_internal_t;

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

#define skip_ws(ptr)  for(;*ptr && isspace(*ptr);ptr++)
#define sign(ptr) if(*ptr == '+' || *ptr == '-') ptr++
#define decimal_point(ptr) if(*ptr == '.') ptr++
#define digits(ptr) for(;*ptr && isdigit(*ptr);ptr++)
// regex form: /^\s*\d+\s*$/
static int parse_int(const char* str,long* i)
{
  char* endptr;

  *i=strtoll(str,&endptr,0);
  skip_ws(endptr);
  if(*endptr == 0)
    return 1;

  return 0;
}

static int parse_double(const char* str,double  *d)
{
  char* endptr;

  *d=strtod(str,&endptr);
  skip_ws(endptr);
  if(*endptr == 0)
    return 1;

  return 0;
}

// regex form: /^ws
static int parse_fraction(const char* str,fraction_internal_t* f)
{
  skip_ws(str);
  if(*str) {
    const char *ptr_whole = str;
    sign(str);
    const char* ptr_num=NULL;
    const char* ptr_den=NULL;
    const char* temp=str;
    digits(str);
    if(*str && str > temp) {
      if(*str == '/') {
        ptr_num=ptr_whole;
        ptr_whole=NULL;
      } else {
        skip_ws(str);
        ptr_num=str;
        digits(str);
      }
      if(*str == '/') {
        str++;
        ptr_den=str;
        digits(str);
        if(str > ptr_den) {
          skip_ws(str);
          if(*str == 0) {
            int64_t whole = ptr_whole == NULL ? 0 : atol(ptr_whole);
            f->denominator = atol(ptr_den);
            f->numerator = whole*f->denominator + (whole < 0 ? -1 : 1 )*atol(ptr_num);
            return 1;
          }
        }
      }
    }
  }
  return 0;
}

static fraction_internal_t rb_fraction_get(VALUE self)
{
  fraction_internal_t f;
  f.numerator = NUM2LONG(rb_iv_get(self,"@numerator"));
  f.denominator = NUM2LONG(rb_iv_get(self,"@denominator"));
  return f;
}

static void rb_fraction_set(VALUE self,fraction_internal_t f)
{
  rb_iv_set(self,"@numerator",LONG2NUM(f.numerator));
  rb_iv_set(self,"@denominator",LONG2NUM(f.denominator));
}

static void fraction_reduce(fraction_internal_t* f)
{
  int64_t n = f->numerator;
  int64_t d = f->denominator;

  // Negative sign should be in numerator
  if(d < 0) {
    d = -d;
    n = -n;
  }

  // Reduce to lowest fraction
  int64_t divisor;
  if((divisor=private_fraction_gcd(labs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
  }

#if __WORDSIZE == 32
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
#endif
  f->numerator=n;
  f->denominator=d;
}

static fraction_internal_t fraction_plus_fraction(fraction_internal_t lhs,fraction_internal_t rhs)
{
  fraction_internal_t result;
  result.numerator = lhs.numerator*rhs.denominator + rhs.numerator*lhs.denominator;
  result.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&result);
  return result;
}

static fraction_internal_t fraction_minus_fraction(fraction_internal_t lhs,fraction_internal_t rhs)
{
  fraction_internal_t result;
  result.numerator = lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator;
  result.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&result);
  return result;
}

static fraction_internal_t fraction_times_fraction(fraction_internal_t lhs,fraction_internal_t rhs)
{
  fraction_internal_t result;
  result.numerator = lhs.numerator*rhs.numerator;
  result.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&result);
  return result;
}

static fraction_internal_t fraction_divided_by_fraction(fraction_internal_t lhs,fraction_internal_t rhs)
{
  fraction_internal_t result;
  if(rhs.numerator == 0)
    rb_raise(rb_eZeroDivError, "divided by 0");
  result.numerator = lhs.numerator*rhs.denominator;
  result.denominator = lhs.denominator*rhs.numerator;
  fraction_reduce(&result);
  return result;
}

static int fraction_cmp_private(fraction_internal_t lhs,fraction_internal_t rhs)
{
  int64_t lhs_product = (int64_t)lhs.numerator*(int64_t)rhs.denominator;
  int64_t rhs_product = (int64_t)lhs.denominator*(int64_t)rhs.numerator;
  if(lhs_product < rhs_product)
    return -1;
  if(rhs_product < lhs_product)
    return 1;
  return 0;
}

#ifdef CALCULATE_LOOP_STATISTICS
VALUE loops;
int fraction_loops;
#endif
static double fraction_epsilon=5e-6;
static fraction_internal_t fraction_from_double(double d)
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

  fraction_internal_t f = { sign*(whole*denominator+numerator),denominator };
  fraction_reduce(&f);
  return f;

#ifdef CALCULATE_LOOP_STATISTICS
  loops=INT2FIX(fraction_loops);
#endif
}

static void fraction_set_double(VALUE self,double d)
{
  rb_fraction_set(self,fraction_from_double(d));
}

VALUE rb_cFraction;
static VALUE cFraction;
static ID id_new;

VALUE rb_fraction_new_fraction(fraction_internal_t f)
{
  VALUE f_new = rb_funcall(cFraction, id_new, 0);
  rb_fraction_set(f_new,f);
  return f_new;
}

VALUE rb_fraction_new_value(VALUE value)
{
  return rb_funcall(cFraction,id_new,1,value);
}

VALUE fraction_gcd(VALUE self, VALUE ra,VALUE rb)
{
  return INT2NUM(private_fraction_gcd(FIX2LONG(ra),FIX2LONG(rb)));
}

static VALUE fraction_initialize(int argc, VALUE *argv, VALUE self)
{
  fraction_internal_t f={0,1};
  VALUE a1,a2,a3;
  int n_args = rb_scan_args(argc,argv,"03",&a1,&a2,&a3);
  const char* strarg;
  switch (n_args) {
    case 1: /* Integer, floating point, or string */
      switch(TYPE(a1)) {
        case T_FIXNUM:
          f.numerator=FIX2LONG(a1);
          f.denominator=1;
          break;

        case T_FLOAT:
          f = fraction_from_double(NUM2DBL(a1));
          break;

        case T_STRING:
            strarg=StringValueCStr(a1);
            double d;
            if(parse_int(strarg,&f.numerator)) {
              f.denominator=1;
            } else if(parse_double(strarg,&d)) {
              f=fraction_from_double(d);
            } else if(!parse_fraction(strarg,&f)) {
              /* Invalid args */
            }
            break;

          case T_OBJECT:
            if(RBASIC(a1)->klass == rb_cFraction) {
              f=rb_fraction_get(a1);
            }
//        default: /* Invalid arg */
      }
      break;

    case 2: /* Two integers -- numerator and denominator */
      if(TYPE(a1) == T_FIXNUM && TYPE(a2) == T_FIXNUM) {
        f.numerator=FIX2LONG(a1);
        f.denominator=FIX2LONG(a2);
      } else {
        /* Invalid arguments */
      }
      break;

    case 3: /* Three integers -- whole, numerator, denominator (mixed fraction) */
      if(TYPE(a1) == T_FIXNUM && TYPE(a2) == T_FIXNUM && TYPE(a3) == T_FIXNUM) {
        int64_t w=FIX2LONG(a1);
        int64_t d=FIX2LONG(a3);
        f.numerator=w*d+(w<0 ? -1 : 1)*FIX2LONG(a2);
        f.denominator=d;
      } else {
        /* Invalid arguments */
      }
      break;
  }
  fraction_reduce(&f);
  rb_fraction_set(self,f);
  return self;
}

VALUE fraction_to_i(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  return INT2NUM((int)(((double)f.numerator)/((double)f.denominator)));
}

VALUE fraction_to_f(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  return DBL2NUM((double)f.numerator/(double)f.denominator);
}

VALUE fraction_to_s(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  char temp[64];
  int np=sprintf(temp,"(%ld",f.numerator);
  if(f.denominator!=1)
    np+=sprintf(temp+np,"/%ld",f.denominator);
  sprintf(temp+np,")");
  return rb_str_new2(temp);
}

VALUE fraction_to_mixed_s(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  if(f.denominator > f.numerator)
    return fraction_to_s(self);
  int32_t whole = f.numerator/f.denominator;
  int32_t rem = f.numerator % f.denominator;
  char temp[64];
  int np=sprintf(temp,"(%d",whole);
  if(rem > 0)
    np+=sprintf(temp+np," %d/%d",rem,f.denominator);
  sprintf(temp+np,")");
  return rb_str_new2(temp);
}

VALUE fraction_cmp(VALUE self,VALUE other)
{
  fraction_internal_t self_fraction=rb_fraction_get(self);
  fraction_internal_t other_fraction;
  switch (TYPE(other)) {
    case T_FIXNUM:
      other_fraction.numerator=FIX2LONG(other);
      other_fraction.denominator=1;
      break;
    case T_FLOAT:
      other_fraction=fraction_from_double(NUM2DBL(other));
      break;

    default:
      other_fraction=rb_fraction_get(other);
  }
  return INT2NUM(fraction_cmp_private(self_fraction,other_fraction));
}

VALUE fraction_uminus(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  f.numerator=-f.numerator;
  VALUE f_new = rb_fraction_new_fraction(f);
  return f_new;
}

VALUE fraction_plus(VALUE self,VALUE other)
{
  fraction_internal_t f=rb_fraction_get(self);
  VALUE f_value=rb_fraction_new_value(other);
  fraction_internal_t fb=rb_fraction_get(f_value);
  return rb_fraction_new_fraction(fraction_plus_fraction(f,fb));
}

VALUE fraction_minus(VALUE self,VALUE other)
{
  fraction_internal_t f=rb_fraction_get(self);
  VALUE f_value=rb_fraction_new_value(other);
  fraction_internal_t fb=rb_fraction_get(f_value);
  return rb_fraction_new_fraction(fraction_minus_fraction(f,fb));
}

VALUE fraction_mul(VALUE self,VALUE other)
{
  fraction_internal_t f=rb_fraction_get(self);
  VALUE f_value=rb_fraction_new_value(other);
  fraction_internal_t fb=rb_fraction_get(f_value);
  return rb_fraction_new_fraction(fraction_times_fraction(f,fb));
}

VALUE fraction_divide(VALUE self,VALUE other)
{
  fraction_internal_t f=rb_fraction_get(self);
  VALUE f_value=rb_fraction_new_value(other);
  fraction_internal_t fb=rb_fraction_get(f_value);
  return rb_fraction_new_fraction(fraction_divided_by_fraction(f,fb));
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
  id_new=rb_intern("new");
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
  rb_define_method(rb_cFraction,"-@",fraction_uminus,0);
  rb_define_method(rb_cFraction,"+",fraction_plus,1);
  rb_define_method(rb_cFraction,"-",fraction_minus,1);
  rb_define_method(rb_cFraction,"*",fraction_mul,1);
  rb_define_method(rb_cFraction,"/",fraction_divide,1);
/*  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);
  rb_define_method(rb_cFraction,"",fraction_,);*/

#ifdef CALCULATE_LOOP_STATISTICS
  rb_define_variable("$fraction_loops",&loops);
#endif
  cFraction = rb_const_get(rb_cFraction, rb_intern("Fraction"));
}
