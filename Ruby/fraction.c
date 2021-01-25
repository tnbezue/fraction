#define CALCULATE_LOOP_STATISTICS

#include "ruby.h"
#include <time.h>
#include <ctype.h>

typedef struct {
  int64_t numerator;
  int64_t denominator;
} fraction_internal_t;

// Euclid's algorithm to find greatest common divisor
static int64_t private_fraction_gcd(int64_t a,int64_t b)
{
  a = llabs(a);
  b = llabs(b);
  int64_t t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}


static VALUE fraction_gcd(VALUE self, VALUE ra,VALUE rb)
{
  return LONG2NUM(private_fraction_gcd(FIX2LONG(ra),FIX2LONG(rb)));
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
  if((divisor=private_fraction_gcd(n,d)) != 1) {
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
    if((divisor=private_fraction_gcd(n,d)) != 1) {
      n/=divisor;
      d/=divisor;
    }
  }
#endif
  f->numerator=n;
  f->denominator=d;
}

static int fraction_from_mixed(fraction_internal_t* f,int64_t w,int64_t n,int64_t d)
{
  int64_t sign=1;
  if(w < 0) {
    sign=-sign;
    w=-w;
  }
  if(n < 0) {
    sign=-sign;
    n=-n;
  }
  if(d < 0) {
    sign=-sign;
    d=-d;
  }
  f->numerator=sign*(w*d+n);
  f->denominator=d;
  fraction_reduce(f);
  return 1; // This should always succeed
}

/* nodoc */
static int space(const char* str)
{
  const char *ptr = str;
  for(;*ptr == ' '; ptr++);
  return ptr - str;
}

/* nodoc */
static int digits(const char* str)
{
  const char* ptr =str;
  for(;isdigit(*ptr);ptr++);
  return (ptr - str) ;
}

#define is_int(d) ((int64_t)d == d)
#define signof(d) ((d) < 0 ? -1 : 1)

// Determine if value in string is a fraction
// ( (+-)? integer)? (+-)? integer/(+-)? integer
static int fraction_test_fraction(fraction_internal_t* f,const char* str)
{
  int is_valid_fraction=0;
  int64_t w=0,n=0,d=-1;
  const char* ptr=str;
  const char* ptr_w=NULL;
  const char* ptr_n=NULL;
  const char* ptr_d=NULL;
  ptr+=space(ptr);
  if(*ptr != 0) { // NOt all spaces
    ptr_w=ptr;
    if(*ptr == '+' || *ptr == '-')
      ptr++;
    int ndigits;
    if((ndigits=digits(ptr)) > 0) {
//      n=atoll(sign_ptr);
      ptr += ndigits;
      if(*ptr == '/') {
        ptr_n = ptr_w;
        ptr_w=NULL;
        ptr++;
        ptr_d=ptr;
        if(*ptr == '+' || *ptr == '-')
          ptr++;
        if((ndigits=digits(ptr))>0) {
          ptr+=ndigits;
        } else {
//          ptr_n=NULL;
          ptr_d=NULL;
        }
      } else { // mixed fraction
        ptr += space(ptr);
        ptr_n=ptr;
        if(*ptr == '+' || *ptr == '-')
          ptr++;
        if((ndigits=digits(ptr)) > 0) {
          ptr+=ndigits;
          if(*ptr == '/') {
            ptr++;
            ptr_d=ptr;
            if(*ptr == '+' || *ptr == '-')
              ptr++;
            if((ndigits=digits(ptr))>0) {
              ptr += ndigits;
            } else {
              ptr_d=NULL;
            }
          }
        }
      }
    }
  }
  ptr += space(ptr);
  if(*ptr == 0 && ptr_d != NULL) {
    fraction_from_mixed(f,ptr_w ? atoll(ptr_w) : 0,atoll(ptr_n),atoll(ptr_d));
    is_valid_fraction = 1;
  }
  return is_valid_fraction;
}

VALUE rb_cFraction;
VALUE rb_cMixedFraction;
static ID id_new;
static ID id_epsilon;

#define IS_FRACTION(v) rb_obj_is_kind_of(v,rb_cFraction)

static VALUE rb_new_fraction(VALUE klass,int argc,...)
{
  // 3 is the maximum arguments to Fraction.new
  VALUE varray[3];
  if(argc > 0) {
    va_list args;
    va_start(args,argc);
    int i;
    for(i=0;i<argc;i++)
      varray[i]=va_arg(args,VALUE);
    va_end(args);
  }
  VALUE f_new = rb_funcallv(klass, id_new, argc,varray);
  return f_new;
}

// Get numerator and denominator of fraction.  If type is not a fraction, create one
static int rb_fraction_get(VALUE self,fraction_internal_t* f)
{
  VALUE obj;
  if(IS_FRACTION(self)) {
    obj=self;
  } else if(rb_obj_is_kind_of(self,rb_cNumeric)) {
    obj=rb_new_fraction(rb_cFraction,1,self);
  } else {
    return 0;
  }
  f->numerator = NUM2LONG(rb_iv_get(obj,"@numerator"));
  f->denominator = NUM2LONG(rb_iv_get(obj,"@denominator"));
  return 1;
}

static void rb_fraction_set(VALUE self,fraction_internal_t f)
{
  fraction_reduce(&f);
  rb_iv_set(self,"@numerator",LONG2NUM(f.numerator));
  rb_iv_set(self,"@denominator",LONG2NUM(f.denominator));
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
static ID id_loops;
#endif

static int fraction_from_double(fraction_internal_t *f,double d)
{
  double epsilon = NUM2DBL(rb_cvar_get(rb_cFraction,id_epsilon));
  *f = (fraction_internal_t){0,1};
  long hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = d;
#ifdef CALCULATE_LOOP_STATISTICS
  int nLoops=0;
#endif
  while(1) {
    long a=v;
    h=a*hm1 + hm2;
    k=a*km1 + km2;
    if(fabs(d - (double)h/(double)k) < epsilon)
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
  f->numerator=h;
  f->denominator=k;

#ifdef CALCULATE_LOOP_STATISTICS
  rb_cvar_set(rb_cFraction,id_loops,INT2NUM(nLoops));
#endif
  return 1;
}

// Determine if value given in string is a number (integer or floating point)
// returns fraction if it is
static int fraction_test_number(fraction_internal_t* f,const char* str)
{
  char* end_ptr;
  int valid=0;
  double value;
  if(*str != 0) {
    value = strtod(str,&end_ptr);
    if(end_ptr) {
      end_ptr+=space(end_ptr);
      valid = *end_ptr == 0;
      fraction_from_double(f,value);
    }
  }
  return valid;
}

static int fraction_from_string(fraction_internal_t* f,const char* str)
{
  if(fraction_test_fraction(f,str))
    return 1;
  if(fraction_test_number(f,str))
    return 1;
  return 0;
}
/*
static void fraction_set_double(VALUE self,double d)
{
  rb_fraction_set(self,fraction_from_double(d));
}
*/


#define  rb_new_fraction_from_internal_fraction(klass,f) \
  rb_new_fraction(klass,2,LONG2NUM(f.numerator),LONG2NUM(f.denominator))

#define IS_NUMERIC(v) rb_obj_is_kind_of(v,rb_cNumeric)

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
          fraction_from_double(&f,NUM2DBL(a1));
          break;

        case T_STRING:
          if(!fraction_from_string(&f,strarg=StringValueCStr(a1))) {
            rb_raise(rb_eRuntimeError,"String \"%s\" could not be converted to Fraction",strarg);
          }
          break;

          case T_OBJECT:
            if(!rb_fraction_get(a1,&f)) {
              rb_raise(rb_eRuntimeError,"Invalid argument in Fraction.set");
            }
      }
      break;

    case 2: /* Two integers -- numerator and denominator */
      if(IS_NUMERIC(a1) && IS_NUMERIC(a2)) {
        f.numerator=FIX2LONG(a1);
        f.denominator=FIX2LONG(a2);
        fraction_reduce(&f);
      } else {
        rb_raise(rb_eRuntimeError, "Invalid value in set");
      }
      break;

    case 3: /* Three integers -- whole, numerator, denominator (mixed fraction) */
      if(IS_NUMERIC(a1) && IS_NUMERIC(a2) && IS_NUMERIC(a3)) {
        fraction_from_mixed(&f,FIX2LONG(a1),FIX2LONG(a2),FIX2LONG(a3));
      } else {
        rb_raise(rb_eRuntimeError, "Invalid value in set");
      }
      break;
  }
  rb_fraction_set(self,f);
  return self;
}

static VALUE fraction_to_i(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  return LONG2NUM((int64_t)(((double)f.numerator)/((double)f.denominator)));
}

static VALUE fraction_to_f(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  return DBL2NUM((double)f.numerator/(double)f.denominator);
}

static VALUE fraction_to_s(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  char temp[64];
  int np=sprintf(temp,"%ld",f.numerator);
  if(f.denominator!=1)
    np+=sprintf(temp+np,"/%ld",f.denominator);
  return rb_str_new2(temp);
}

static VALUE mixed_fraction_to_s(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  if(f.denominator > llabs(f.numerator) || f.denominator == 1)
    return fraction_to_s(self);
  int32_t whole = f.numerator/f.denominator;
  int32_t rem = llabs(f.numerator) % f.denominator;
  char temp[64];
  sprintf(temp,"%d %d/%d",whole,rem,f.denominator);
  return rb_str_new2(temp);
}

static VALUE fraction_cmp(VALUE self,VALUE other)
{
  fraction_internal_t lhs;
  if(!rb_fraction_get(self,&lhs)) {
    rb_raise(rb_eRuntimeError,"Invalid object in comparison");
  }
  fraction_internal_t rhs;
  if(!rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid object in comparison");
  }
  return INT2NUM(fraction_cmp_private(lhs,rhs));
}

static VALUE fraction_uminus(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  f.numerator=-f.numerator;
  return rb_new_fraction_from_internal_fraction(RBASIC(self)->klass,f);
}

static VALUE fraction_uplus(VALUE self)
{
  return rb_new_fraction(RBASIC(self)->klass,1,self);
}

// Conver
static VALUE convert_internal_fraction_to_type_of(VALUE self,fraction_internal_t f)
{
  if(IS_FRACTION(self)) {
    return rb_new_fraction_from_internal_fraction(RBASIC(self)->klass,f);
  }
  if(rb_obj_is_kind_of(self,rb_cInteger)) {
    return LONG2NUM((long)f.numerator/f.denominator);
  }
  // return everything else as floating poing
  return rb_float_new((double)f.numerator/f.denominator);
}

static VALUE fraction_plus(VALUE self,VALUE other)
{
  fraction_internal_t lhs,rhs;
  if(!rb_fraction_get(self,&lhs) || !rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid type in fraction addition");
  }
  lhs.numerator = lhs.numerator*rhs.denominator + rhs.numerator*lhs.denominator;
  lhs.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&lhs);
  return convert_internal_fraction_to_type_of(self,lhs);
}

static VALUE fraction_minus(VALUE self,VALUE other)
{
  fraction_internal_t lhs,rhs;
  if(!rb_fraction_get(self,&lhs) || !rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid type in fraction subraction");
  }
  lhs.numerator = lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator;
  lhs.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&lhs);
  return convert_internal_fraction_to_type_of(self,lhs);
}

static VALUE fraction_mul(VALUE self,VALUE other)
{
  fraction_internal_t lhs,rhs;
  if(!rb_fraction_get(self,&lhs) || !rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid type in fraction multiplication");
  }
  lhs.numerator = lhs.numerator*rhs.numerator;
  lhs.denominator = lhs.denominator*rhs.denominator;
  fraction_reduce(&lhs);
  return convert_internal_fraction_to_type_of(self,lhs);
}

static VALUE fraction_divide(VALUE self,VALUE other)
{
  fraction_internal_t lhs,rhs;
  if(!rb_fraction_get(self,&lhs) || !rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid type in fraction division");
  }
  lhs.numerator = lhs.numerator*rhs.denominator;
  lhs.denominator = lhs.denominator*rhs.numerator;
  fraction_reduce(&lhs);
  return convert_internal_fraction_to_type_of(self,lhs);
}

static VALUE fraction_pow(VALUE self,VALUE other)
{
  fraction_internal_t lhs,rhs;
  if(!rb_fraction_get(self,&lhs) || !rb_fraction_get(other,&rhs)) {
    rb_raise(rb_eRuntimeError,"Invalid type in fraction power");
  }
  double b=(double)lhs.numerator/(double)lhs.denominator;
  double e=(double)rhs.numerator/(double)rhs.denominator;
  // Can only raise a negative value to an integer value
  if(b < 0) {
    if(!is_int(e)) {
      rb_raise(rb_eRuntimeError,"Base cannot be negative for non integer power");
    }
  }
  double result=pow(b,fabs(e));
  if(e < 0) {
    result = 1.0/result;
  }
  fraction_from_double(&lhs,result);
  return convert_internal_fraction_to_type_of(self,lhs);
}

static VALUE fraction_abs(VALUE self)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  f.numerator = llabs(f.numerator);
  return rb_new_fraction_from_internal_fraction(RBASIC(self)->klass,f);
}

static VALUE fraction_round_(VALUE self,VALUE denom)
{
  fraction_internal_t f;
  rb_fraction_get(self,&f);
  long d = FIX2LONG(denom);
  if(d < f.denominator) {
    f.numerator = round((double)f.numerator*(double)d/(double)f.denominator);
    f.denominator = d;
    fraction_reduce(&f);
    rb_fraction_set(self,f);
  }
  return self;
}

static VALUE fraction_round(VALUE self,VALUE denom)
{
  VALUE f_new=rb_new_fraction(RBASIC(self)->klass,1,self);
  fraction_round_(f_new,denom);
  return f_new;
}

static VALUE fraction_epsilon_get(VALUE self)
{
  return rb_cvar_get(rb_cFraction,id_epsilon);
}

static VALUE fraction_epsilon_set(VALUE self,VALUE eps)
{
  rb_cvar_set(rb_cFraction,id_epsilon,eps);
  return eps;
}

#ifdef CALCULATE_LOOP_STATISTICS
static VALUE fraction_loops_get(VALUE self)
{
  return rb_cvar_get(rb_cFraction,id_loops);
}
#endif
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
  rb_define_singleton_method(rb_cFraction,"GCD",fraction_gcd,2);
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
  rb_define_method(rb_cFraction,"abs",fraction_abs,0);
  rb_define_method(rb_cFraction,"round",fraction_round,1);
  rb_define_method(rb_cFraction,"round!",fraction_round_,1);
  rb_define_class_variable(rb_cFraction,"@@epsilon",rb_float_new(5e-6));
  id_epsilon=rb_intern("@@epsilon");
  rb_define_singleton_method(rb_cFraction,"epsilon",fraction_epsilon_get,0);
  rb_define_singleton_method(rb_cFraction,"epsilon=",fraction_epsilon_set,1);
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
  rb_define_class_variable(rb_cFraction,"@@loops",INT2NUM(0));
  rb_define_singleton_method(rb_cFraction,"loops",fraction_loops_get,0);
  id_loops=rb_intern("@@loops");
#endif

  rb_cMixedFraction = rb_define_class("MixedFraction",rb_cFraction);
  rb_define_method(rb_cMixedFraction,"to_s",mixed_fraction_to_s,0);

}
