#define CALCULATE_LOOP_STATISTICS
#include "ruby.h"
#include <time.h>
#include <ctype.h>

typedef struct {
  int64_t numerator;
  int64_t denominator;
} fraction_internal_t;

// Utilities
static int space(const char* str)
{
  const char *ptr = str;
  for(;*ptr == ' '; ptr++);
  return ptr - str;
}

static int digits(const char* str)
{
  const char* ptr =str;
  for(;isdigit(*ptr);ptr++);
  return (ptr - str) ;
}

#define is_int(d) ((int64_t)d == d)
#define signof(d) ((d) < 0 ? -1 : 1)

// Determine if value given in string is a floating point number
static int is_number(const char* str,double* result)
{
  char* ptr;
  int valid=0;
  str+=space(str);
  if(*str != 0) {
    *result = strtod(str,&ptr);
    if(ptr) {
      ptr+=space(ptr);
      valid = *ptr == 0;
    }
  }
  return valid;
}

// Determine if value in string is a fraction
// ( (+-)? integer? (+-)? integer/(+-)? integer ) | ( (+-)? integer (/ (+-)? integer )? )
static int is_fraction(const char* str,fraction_internal_t* f)
{
  int is_valid_fraction=0;
  int64_t w=0,n=0,d=1;
  const char* ptr=str;
  ptr+=space(ptr);
  if(*ptr != 0) {
    const char* sign_ptr=ptr;
    if(*ptr == '+' || *ptr == '-')
      ptr++;
    int ndigits;
    if((ndigits=digits(ptr)) > 0) {
      is_valid_fraction = 1;
      n=atoll(sign_ptr);
      ptr += ndigits;
      if(*ptr == '/') {
        is_valid_fraction=0;
        ptr++;
        sign_ptr=ptr;
        if(*ptr == '+' || *ptr == '-')
          ptr++;
        if((ndigits=digits(ptr))>0) {
          d=atoll(sign_ptr);
          is_valid_fraction=1;
          ptr+= ndigits;
        }
      } else {
        ptr += space(ptr);
        sign_ptr=ptr;
        if(*ptr == '+' || *ptr == '-')
          ptr++;
        if((ndigits=digits(ptr)) > 0) {
          is_valid_fraction=0;
          w=n;
          n=atoll(sign_ptr);
          ptr+=ndigits;
          if(*ptr == '/') {
            ptr++;
            sign_ptr=ptr;
            if(*ptr == '+' || *ptr == '-')
              ptr++;
            if((ndigits=digits(ptr))>0) {
              d=atoll(sign_ptr);
              is_valid_fraction=1;
              ptr+= ndigits;
            }
          }
        }
      }
    }
  }
  ptr += space(ptr);
  is_valid_fraction &= *ptr == 0;
  if(is_valid_fraction) {
    int sign = signof(w)*signof(n)*signof(d);
    w=llabs(w);
    n=llabs(n);
    d=llabs(d);
    f->numerator = sign*(w*d + n);
    f->denominator = d;
  }
  return is_valid_fraction;
}

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
int nLoops;
#endif
static double fraction_epsilon=5e-6;
static fraction_internal_t fraction_from_double(double d)
{
  fraction_internal_t f = { 0, 1};
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
    if(fabs(d - (double)h/(double)k) < fraction_epsilon)
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
  f.numerator=h;
  f.denominator=k;

#ifdef CALCULATE_LOOP_STATISTICS
  loops=INT2FIX(nLoops);
#endif
  return f;
}

static void fraction_set_double(VALUE self,double d)
{
  rb_fraction_set(self,fraction_from_double(d));
}

VALUE rb_cFraction;
VALUE rb_cMixedFraction;
static VALUE cFraction;
static VALUE cMixedFraction;
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
  VALUE a1,a2,a3,klass;
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
            if(is_fraction(strarg,&f)) {
              fraction_reduce(&f);
            } else if(is_number(strarg,&d)) {
              f = fraction_from_double(d);
            } else {
              /*
                invalid arg
              */
            }
            break;

          case T_OBJECT:
            klass = RBASIC(a1)->klass;
            if(klass == rb_cFraction || klass == rb_cMixedFraction) {
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
  int np=sprintf(temp,"%ld",f.numerator);
  if(f.denominator!=1)
    np+=sprintf(temp+np,"/%ld",f.denominator);
  return rb_str_new2(temp);
}

VALUE mixed_fraction_to_s(VALUE self)
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

VALUE fraction_uplus(VALUE self)
{
  fraction_internal_t f = rb_fraction_get(self);
  f.numerator=f.numerator;
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

VALUE fraction_pow(VALUE self,VALUE other)
{
  fraction_internal_t f=rb_fraction_get(self);
  VALUE f_value=rb_fraction_new_value(other);
  fraction_internal_t fb=rb_fraction_get(f_value);
  return rb_fraction_new_fraction(fraction_divided_by_fraction(f,fb));
}

VALUE fraction_round_(VALUE self,VALUE denom)
{
  fraction_internal_t f=rb_fraction_get(self);
  long d = FIX2LONG(denom);
  if(d < f.denominator) {
    puts("Rounding");
    f.numerator = round((double)f.numerator*(double)d/(double)f.denominator);
    f.denominator = d;
    fraction_reduce(&f);
    rb_fraction_set(self,f);
  }
  return self;
}

VALUE fraction_round(VALUE self,VALUE denom)
{
  VALUE f=rb_fraction_new_value(self);
  return fraction_round_(f,denom);
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
  rb_define_method(rb_cFraction,"set",fraction_initialize,-1);
  rb_define_method(rb_cFraction,"+",fraction_plus,1);
  rb_define_method(rb_cFraction,"-",fraction_minus,1);
  rb_define_method(rb_cFraction,"*",fraction_mul,1);
  rb_define_method(rb_cFraction,"/",fraction_divide,1);
  rb_define_method(rb_cFraction,"**",fraction_pow,1);
  rb_define_method(rb_cFraction,"-@",fraction_uminus,0);
  rb_define_method(rb_cFraction,"+@",fraction_uplus,0);
  rb_define_method(rb_cFraction,"to_i",fraction_to_i,0);
  rb_define_method(rb_cFraction,"to_f",fraction_to_f,0);
  rb_define_method(rb_cFraction,"to_s",fraction_to_s,0);
  rb_define_method(rb_cFraction,"<=>",fraction_cmp,1);
  rb_define_method(rb_cFraction,"round",fraction_round,1);
  rb_define_method(rb_cFraction,"round!",fraction_round_,1);
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

  rb_cMixedFraction = rb_define_class("MixedFraction",rb_cFraction);
  rb_define_method(rb_cMixedFraction,"to_s",mixed_fraction_to_s,0);
}
