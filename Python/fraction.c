#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <structmember.h>
#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>

#define CALCULATE_LOOP_STATISTICS 1
#ifdef FRACTION_USE_32_BIT
typedef int32_t fraction_numerator_denominator_t;
#define THREE_INTEGERS "iii"
#define TWO_INTEGERS "ii"
#define ONE_INTEGER "i"
#define PRIND  PRId32
#define PYLONG_AS_LONG PyLong_AsLong
#else
typedef int64_t fraction_numerator_denominator_t;
#define THREE_INTEGERS "LLL"
#define TWO_INTEGERS "LL"
#define ONE_INTEGER "L"
#define PRIND  PRId64
#define PYLONG_AS_LONG PyLong_AsLongLong
#endif

/*
  Internal methods
*/
typedef struct {
  PyObject_HEAD
  fraction_numerator_denominator_t numerator;
  fraction_numerator_denominator_t denominator;
//  double epsilon;
} FractionObject;

typedef struct {
  FractionObject super;
} MixedFractionObject;

static PyTypeObject FractionType;

// Fraction structure without the Python overhead
typedef struct {
  fraction_numerator_denominator_t numerator;
  fraction_numerator_denominator_t denominator;
} fraction_internal_t;

static inline void PyFraction_to_internal_fraction(FractionObject* fo,fraction_internal_t* fi)
{
  fi->numerator=fo->numerator;
  fi->denominator=fo->denominator;
}

static inline void internal_fraction_to_PyFraction(fraction_internal_t* fi,FractionObject* fo)
{
  fo->numerator=fi->numerator;
  fo->denominator=fi->denominator;
}

// Euclid's algorithm to find greatest common divisor
int64_t fraction_internal_gcd(register int64_t a,register int64_t b)
{
  register int64_t t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}

static int cmp_fraction(fraction_internal_t *lhs,fraction_internal_t *rhs,int op)
{
  int rc=0;
  int64_t a = lhs->numerator*rhs->denominator;
  int64_t b = rhs->numerator*lhs->denominator;
  switch(op) {
    case Py_LT: rc = a  < b; break;
    case Py_LE: rc = a <= b; break;
    case Py_EQ: rc = a == b; break;
    case Py_NE: rc = a != b; break;
    case Py_GT: rc = a  > b; break;
    case Py_GE: rc = a >= b; break;
  }
  return rc;
}
/*
static void fraction_internal_set_fraction(* self,FractionObject* other)
{
  self->numerator=other->numerator;
  self->denominator=other->denominator;
}
*/
static void fraction_internal_set_num_denom(fraction_internal_t* f,int64_t n,int64_t d)
{
  if( d < 0) {
    n = -n;
    d = -d;
  }
  int divisor = fraction_internal_gcd(llabs(n),d);
  if(divisor != 1) {
    n /= divisor;
    d /= divisor;
  }

#ifdef USE_32_BIT_FRACTION
  // Result should fit in an 32 bit value (only numerator should be negative)
  int64_t max = llabs(n) < d ? d : llabs(n);
  if(max > INT32_MAX) {
    double scale=(double)max/(double)INT32_MAX;
    // To ensure below integer max, truncate rather than round
    n=(int64_t)((double)n/scale);
    d=(int64_t)((double)d/scale);
    // May need to be reduced again
    if((divisor=fraction_gcd_private(llabs(n),d)) != 1) {
      n/=divisor;
      d/=divisor;
    }
  }
#endif
  f->numerator =  n;
  f->denominator = d;

}

static void fraction_internal_set_mixed(fraction_internal_t* f,int64_t w,int64_t n,int64_t d)
{
  int64_t sign=1;
  if(w<0) {
    w=-w;
    sign=-sign;
  }
  if(n<0) {
    n=-n;
    sign=-sign;
  }
  if(d<0) {
    d=-d;
    sign=-sign;
  }
  fraction_internal_set_num_denom(f,sign*(w*d + n),d);
}

#ifdef CALCULATE_LOOP_STATISTICS
static int nLoops=0;
#endif
static double epsilon=5e-6;

static void fraction_internal_set_float(fraction_internal_t* f,double d)
{
  register int64_t hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = d;
#ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
#endif
  while(1) {
    int a=v;
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
  f->numerator=(fraction_numerator_denominator_t)h;
  f->denominator=(fraction_numerator_denominator_t)k;
}


typedef struct {
  double value;
  int valid;
} double_result_t;

#define is_int(d) ((int64_t)d == d)
#define signof(d) ((d) < 0 ? -1 : 1)

/*
static double_result_t is_number(const char* str)
{
  double_result_t r={0,0};
  char* ptr;
  str+=whitespace(str);
  if(*str != 0) {
    r.value = strtod(str,&ptr);
    if(ptr) {
      ptr+=whitespace(ptr);
      r.valid = *ptr == 0;
    }
  }
  return r;
}
*/
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

static int fraction_set_fraction_string(fraction_internal_t* self,const char* str)
{
 int is_valid_fraction=0;
//  int64_t w=0,n=0,d=-1;
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
    fraction_internal_set_mixed(self,ptr_w ? atoll(ptr_w) : 0,atoll(ptr_n),atoll(ptr_d));
    is_valid_fraction = 1;
  }
  return is_valid_fraction;
}

#if 0
// (+=)? ( ( integer? integer/integer ) | ( integer (/ integer )? ) )
static fraction_result_t is_fraction(const char* str)
{
  fraction_result_t r;
  int is_valid_fraction=0;
  int64_t w=0,n=0,d=1;
  const char* ptr=str;
  ptr+=whitespace(ptr);
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
        ptr += whitespace(ptr);
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
  ptr += whitespace(ptr);
  r.valid = *ptr == 0 && is_valid_fraction;
  if(r.valid) {
    int sign = signof(w)*signof(n)*signof(d);
    w=llabs(w);
    n=llabs(n);
    d=llabs(d);
    r.numerator = sign*(w*d + n);
    r.denominator = d;
  }
  return r;
}
#endif

static int fraction_set_number_string(fraction_internal_t* f,const char* str)
{
  char* end_ptr;
  int valid=0;
  double value;
  if(*str != 0) {
    value = strtod(str,&end_ptr);
    if(end_ptr) {
      end_ptr+=space(end_ptr);
      valid = *end_ptr == 0;
      fraction_internal_set_float(f,value);
    }
  }
  return valid;
}

static PyObject* fraction_gcd(PyObject* self,PyObject *args[],int nargs)
{
  if(nargs == 2) {
    if(PyLong_Check(args[0]) && PyLong_Check(args[1])) {
      return PyLong_FromLongLong(fraction_internal_gcd((int64_t)PyLong_AsLong(args[0]),(int64_t)PyLong_AsLong(args[1])));
    }
  }
  return 0;
}

static int fraction_internal_set_string(fraction_internal_t* self,const char* str)
{
  if(fraction_set_number_string(self,str))
    return 1;
  return fraction_set_fraction_string(self,str);
}

static PyObject* fraction_set(PyObject* self,PyObject* args)
{
  int nargs = PyTuple_Size(args);
  PyObject *arg1,*arg2,*arg3;
//  FractionObject* fself=(FractionObject*)self;
  fraction_internal_t f = { 0,1 };
  if(nargs == 0) { // default values
    f.numerator=0;
    f.denominator=1;
  } else if(nargs == 1) { // Can be number, floating point, string , or another fraction
    arg1 = PyTuple_GetItem(args,0);
    if(PyObject_IsInstance(arg1,(PyObject*)&FractionType)) {
//      FractionObject* other=(FractionObject*)arg1;
      PyFraction_to_internal_fraction((FractionObject*)arg1,&f);
/*      fself->numerator=other->numerator;
      fself->denominator=other->denominator;*/
    } else if(PyLong_Check(arg1)) {
      f.numerator=PyLong_AsLong(arg1);
      f.denominator=1;
    } else if(PyFloat_Check(arg1)) {
      fraction_internal_set_float(&f,PyFloat_AsDouble(arg1));
    } else if(PyUnicode_Check(arg1)) {
      if(!fraction_internal_set_string(&f,PyUnicode_AsUTF8AndSize(arg1,NULL))) {
        // error
      }
    } else {
      // Error
    }
  } else if(nargs == 2) { // Two integers
    arg1 = PyTuple_GetItem(args,0);
    arg2 = PyTuple_GetItem(args,1);
    if(PyLong_Check(arg1) && PyLong_Check(arg1)) {
      fraction_internal_set_num_denom(&f,PyLong_AsLong(arg1),PyLong_AsLong(arg2));
    } else {
      // Error
    }
  } else if(nargs == 3) { // Three integers
    arg1 = PyTuple_GetItem(args,0);
    arg2 = PyTuple_GetItem(args,1);
    arg3 = PyTuple_GetItem(args,2);
    if(PyLong_Check(arg1) && PyLong_Check(arg1) && PyLong_Check(arg2)) {
      fraction_internal_set_mixed(&f,PyLong_AsLong(arg1),PyLong_AsLong(arg2),PyLong_AsLong(arg3));
    } else {
      // Error
    }
  } else {
    // error
  }
  internal_fraction_to_PyFraction(&f,(FractionObject*)self);
  Py_RETURN_NONE;
}

#if 0
static PyObject* fraction_set(PyObject* self,PyObject* args)
{
  fraction_numerator_denominator_t num,denom,whole;
  double dbl;
  char* str;
  FractionObject* other;
  FractionObject* fself=(FractionObject*)self;
  if(PyTuple_Size(args) == 0) {
    fself->numerator = 0;
    fself->denominator = 1;
  } else if(PyArg_ParseTuple(args,THREE_INTEGERS,&whole,&num,&denom)) { // try 3 integers
    fraction_internal_set_mixed((FractionObject*)self,whole,num,denom);
  } else {
    PyErr_Clear();
    if(PyArg_ParseTuple(args,TWO_INTEGERS,&num,&denom)) {
      fraction_internal_set_num_denom((FractionObject*)self,(int64_t)num,(int64_t)denom);
    } else {
      PyErr_Clear();
      if(PyArg_ParseTuple(args,ONE_INTEGER,&num)) {
        fraction_internal_set_num_denom((FractionObject*)self,num,1);
      } else {
        PyErr_Clear();
        if(PyArg_ParseTuple(args,"d",&dbl)) {
          fraction_internal_set_float((FractionObject*)self,dbl);
        } else {
          PyErr_Clear();
          if(PyArg_ParseTuple(args,"s",&str)) {
            fraction_internal_set_string((FractionObject*)self,str);
          } else {
            PyErr_Clear();
            if(PyArg_ParseTuple(args,"O!",&FractionType,&other)) {
              fself->numerator=other->numerator;
              fself->denominator=other->denominator;
            }
          }
        }
      }
    }
  }
  Py_RETURN_NONE;
}
#endif

#define fraction_internal_add(lhs,rhs) \
    fraction_internal_set_num_denom(&lhs, \
        (int64_t)lhs.numerator*(int64_t)rhs.denominator + (int64_t)lhs.denominator*(int64_t)rhs.numerator, \
        (int64_t)rhs.denominator*(int64_t)lhs.denominator)

/*static void fraction_internal_add(fraction_internal_t* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator + (int64_t)lhs->denominator*(int64_t)rhs->numerator,
        (int64_t)rhs->denominator*(int64_t)lhs->denominator);
}
*/

#define fraction_internal_sub(lhs,rhs) \
    fraction_internal_set_num_denom(&lhs, \
        (int64_t)lhs.numerator*(int64_t)rhs.denominator - (int64_t)lhs.denominator*(int64_t)rhs.numerator, \
        (int64_t)rhs.denominator*(int64_t)lhs.denominator)

/*
static void fraction_internal_subtract(fraction_internal_t* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator - (int64_t)lhs->denominator*(int64_t)rhs->numerator,
        (int64_t)rhs->denominator*(int64_t)lhs->denominator);
}
*/

#define fraction_internal_mul(lhs,rhs) \
  fraction_internal_set_num_denom(&lhs, \
        (int64_t)lhs.numerator*(int64_t)rhs.numerator,(int64_t)rhs.denominator*(int64_t)lhs.denominator)

/*
static void fraction_internal_multiply(fraction_internal_t* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->numerator,(int64_t)rhs->denominator*(int64_t)lhs->denominator);
}
*/

#define fraction_internal_div(lhs,rhs) \
  fraction_internal_set_num_denom(&lhs, \
        (int64_t)lhs.numerator*(int64_t)rhs.denominator,(int64_t)lhs.denominator*(int64_t)rhs.numerator)

/*
static void fraction_internal_divide(fraction_internal_t* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator,(int64_t)lhs->denominator*(int64_t)rhs->numerator);
}
*/

static PyObject* fraction_round(PyObject* self,PyObject* args[],int nArgs)
{
  fraction_numerator_denominator_t denom=-1;
  char err_msg[256];
  err_msg[0]=0;
  fraction_internal_t f = { 0,1};
  FractionObject* result = NULL;

  if(nArgs == 1) {
    if(PyLong_CheckExact(args[0])) {
      denom = PYLONG_AS_LONG(args[0]);
      if(denom > 0) {
        PyFraction_to_internal_fraction((FractionObject*)self,&f);
        if(denom < f.denominator) {
          fraction_internal_set_num_denom(&f,(int)round(((double)denom*(double)f.numerator)/(double)f.denominator),denom);
        }
      } else if(err_msg[0] == 0) {
        sprintf(err_msg,"round expects a value greater than 1 (got % " PRIND ")",denom);
        PyErr_SetString(PyExc_ValueError,err_msg);
      }
    } else {
      sprintf(err_msg,"round() takes an integer argument - '%s' specified.",args[0]->ob_type->tp_name);
      PyErr_SetString(PyExc_TypeError,err_msg);
    }
  } else {
    sprintf(err_msg,"round() takes 1 argument (%d given)",nArgs);
    PyErr_SetString(PyExc_TypeError,err_msg);
  }
  if(err_msg[0] == 0) { // No errors
    result = PyObject_New(FractionObject,self->ob_type);
    internal_fraction_to_PyFraction(&f,result);
  }

  return (PyObject*)result;
}

static PyObject* fraction_abs(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,self->ob_type);

  FractionObject* fself=(FractionObject*)self;
  result->numerator = llabs(fself->numerator);
  result->denominator = fself->denominator;
  return (PyObject*)result;
}

static PyObject* fraction_negative(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,self->ob_type);
  FractionObject* fself=(FractionObject*)self;
  result->numerator = -fself->numerator;
  result->denominator = fself->denominator;
  return (PyObject*)result;
}

static PyObject* fraction_positive(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,self->ob_type);

  FractionObject* fself=(FractionObject*)self;
  result->numerator = fself->numerator;
  result->denominator = fself->denominator;
  return (PyObject*)result;
}

static PyObject* fraction_float(PyObject* self)
{
  FractionObject* fself=(FractionObject*)self;
  return (PyObject*)PyFloat_FromDouble((double)fself->numerator/(double)fself->denominator);
}

static PyObject* fraction_int(PyObject* self)
{
  FractionObject* fself=(FractionObject*)self;
  return (PyObject*)PyLong_FromLong((int64_t)((double)fself->numerator/(double)fself->denominator));
}

// Value has to be numerical (Int or Float) or a Fraction
static int PyValue_to_internal_fraction(PyObject* value,fraction_internal_t* f)
{
  int rc =1;
  if(PyObject_IsInstance(value,(PyObject*)&FractionType)) {
    PyFraction_to_internal_fraction((FractionObject*)value,f);
  } else if(PyLong_Check(value)) {
    f->numerator = PyLong_AsLong(value);
    f->denominator = 1;
  } else if(PyFloat_Check(value)) {
    fraction_internal_set_float(f,PyFloat_AsDouble(value));
  } else {
    rc=0;
  }
  return rc;
}

static int PyValue_to_double(PyObject* value,double* dbl)
{
  int rc = 1;
  if(PyObject_IsInstance(value,(PyObject*)&FractionType)) {
    *dbl = ((double)((FractionObject*)value)->numerator)/((double)((FractionObject*)value)->denominator);
  } else if(PyLong_Check(value)) {
    *dbl = PyLong_AsLong(value);
  } else if(PyFloat_Check(value)) {
    *dbl = PyFloat_AsDouble(value);
  } else {
    rc = 0;
  }
  return rc;
}

static PyObject* fraction_add(PyObject* self,PyObject* other)
{
  PyObject* result = NULL;
  if(PyObject_IsInstance(self,(PyObject*)&FractionType)) {
    fraction_internal_t lhs,rhs;
    PyValue_to_internal_fraction(self,&lhs);
    if(PyValue_to_internal_fraction(other,&rhs)) {
      fraction_internal_add(lhs,rhs);
      result = (PyObject*) PyObject_New(FractionObject,self->ob_type);
      internal_fraction_to_PyFraction(&lhs,(FractionObject*)result);
    } else {
      result = Py_NotImplemented;
    }
  } else {
    double temp;
    if(PyValue_to_double(self,&temp)) {
      result =  PyFloat_FromDouble(temp+((double)((FractionObject*)other)->numerator)/((double)((FractionObject*)other)->denominator));
    } else {
      result = Py_NotImplemented;
    }
  }
  return result;
}

static PyObject* fraction_subtract(PyObject* self,PyObject* other)
{
  PyObject* result = NULL;
  if(PyObject_IsInstance(self,(PyObject*)&FractionType)) {
    fraction_internal_t lhs,rhs;
    PyValue_to_internal_fraction(self,&lhs);
    if(PyValue_to_internal_fraction(other,&rhs)) {
      fraction_internal_sub(lhs,rhs);
      result = (PyObject*) PyObject_New(FractionObject,self->ob_type);
      internal_fraction_to_PyFraction(&lhs,(FractionObject*)result);
    } else {
      result = Py_NotImplemented;
    }
  } else {
    double temp;
    if(PyValue_to_double(self,&temp)) {
      result =  PyFloat_FromDouble(temp-((double)((FractionObject*)other)->numerator)/((double)((FractionObject*)other)->denominator));
    } else {
      result = Py_NotImplemented;
    }
  }
  return result;
}

static PyObject* fraction_multiply(PyObject* self,PyObject* other)
{
  PyObject* result = NULL;
  if(PyObject_IsInstance(self,(PyObject*)&FractionType)) {
    fraction_internal_t lhs,rhs;
    PyValue_to_internal_fraction(self,&lhs);
    if(PyValue_to_internal_fraction(other,&rhs)) {
      fraction_internal_mul(lhs,rhs);
      result = (PyObject*) PyObject_New(FractionObject,self->ob_type);
      internal_fraction_to_PyFraction(&lhs,(FractionObject*)result);
    } else {
      result = Py_NotImplemented;
    }
  } else {
    double temp;
    if(PyValue_to_double(self,&temp)) {
      result =  PyFloat_FromDouble(temp*((double)((FractionObject*)other)->numerator)/((double)((FractionObject*)other)->denominator));
    } else {
      result = Py_NotImplemented;
    }
  }
  return result;
}

static PyObject* fraction_divide(PyObject* self,PyObject* other)
{
  PyObject* result = NULL;
  if(PyObject_IsInstance(self,(PyObject*)&FractionType)) {
    fraction_internal_t lhs,rhs;
    PyValue_to_internal_fraction(self,&lhs);
    if(PyValue_to_internal_fraction(other,&rhs)) {
      fraction_internal_div(lhs,rhs);
      result = (PyObject*) PyObject_New(FractionObject,self->ob_type);
      internal_fraction_to_PyFraction(&lhs,(FractionObject*)result);
    } else {
      result = Py_NotImplemented;
    }
  } else {
    double temp;
    if(PyValue_to_double(self,&temp)) {
      result =  PyFloat_FromDouble(temp*((double)((FractionObject*)other)->denominator)/((double)((FractionObject*)other)->numerator));
    } else {
      result = Py_NotImplemented;
    }
  }
  return result;
}

static PyObject* fraction_pow(PyObject* self,PyObject* other,PyObject* Py_UNUSED(ignored))
{
  double b=0,e=0;
  PyObject* ret = Py_NotImplemented;
  if(PyValue_to_double(self,&b) && PyValue_to_double(other,&e)) {
    if((b >= 0) || (b < 0 && ((int)e == e))) { // negative number can only be raise to integer power
      double result = pow(b,fabs(e));
      // Make return type same as base
      if(e < 0)
        result=1.0/result;
      if(PyObject_IsInstance(self,(PyObject*)&FractionType)) {
        fraction_internal_t f;
        fraction_internal_set_float(&f,result);
        ret=(PyObject*)PyObject_New(FractionObject,self->ob_type);
        internal_fraction_to_PyFraction(&f,(FractionObject*)ret);
      } else {
        ret=PyFloat_FromDouble(result);
      }
    } /* else b < 0 ... -- result will be complex, let it return not implemented for now */
  }
  return ret;
}
static PyObject* fraction_str(PyObject* self);
static PyObject* mixed_fraction_str(PyObject* self)
{
  FractionObject* fself=(FractionObject*)self;
  if(llabs(fself->numerator) < fself->denominator || fself->denominator == 1)
    return fraction_str(self);
  int64_t whole = fself->numerator / fself->denominator;
  int64_t num = llabs(fself->numerator) - llabs(whole)*fself->denominator;
  return PyUnicode_FromFormat("%d %d/%d",whole,abs(num),fself->denominator);
}


#ifdef CALCULATE_LOOP_STATISTICS
static PyObject *fraction_loops(PyObject* self,void* closure)
{
  return PyLong_FromLong(nLoops);
}
#endif
static PyObject* fraction_epsilon(PyObject* self,PyObject* args[],int nArgs)
{
  char err_msg[128];
  PyObject* rc = PyFloat_FromDouble(epsilon);
  double new_epsilon=0;
  if(nArgs <= 1) {
    if(nArgs == 1) {
      new_epsilon = PyFloat_AsDouble(args[0]);
      if(PyErr_Occurred() == NULL)
        epsilon = new_epsilon;
    }
  } else {
    sprintf(err_msg,"epsilon() takes 0 or 1 argument (%d given)",nArgs);
    PyErr_SetString(PyExc_TypeError,err_msg);
  }
  return rc;
}

static PyMethodDef Fraction_methods[] = {
  { "GCD", (PyCFunction) fraction_gcd, METH_STATIC|METH_FASTCALL, "Computes greatest common divisor"},
  { "set", fraction_set, METH_VARARGS, "Sets value of fraction"},
  { "__round__", (PyCFunction) fraction_round, METH_FASTCALL, "Rounds fraction" },
//  { "__abs__",  (PyCFunction) fraction_abs, METH_FASTCALL, "Absolute value of fraction" },
//  { "to_mixed_string", (PyCFunction) fraction_to_mixed_string,METH_NOARGS, "Fraction represented as mixed fraction"},
  { "epsilon", (PyCFunction) fraction_epsilon,METH_STATIC|METH_FASTCALL, "Gets/sets epsilon"},
#ifdef CALCULATE_LOOP_STATISTICS
  { "Loops", (PyCFunction) fraction_loops,METH_STATIC|METH_NOARGS, "Number of loops to convert floating point to fraction"},
#endif
  {NULL}  /* Sentinel */
};

static PyObject * fraction_richcmp(PyObject *obj1, PyObject *obj2, int op)
{
  PyObject* rc;
  fraction_internal_t lhs,rhs;
  PyValue_to_internal_fraction(obj1,&lhs);
  if(PyValue_to_internal_fraction(obj2,&rhs)) {
    rc = cmp_fraction(&lhs,&rhs,op) ? Py_True : Py_False;
    Py_INCREF(rc);
  } else {
    rc=Py_NotImplemented;
  }
  return rc;
}

static Py_hash_t fraction_hash(PyObject* self)
{
  PyObject* tuple = PyTuple_Pack(2,PyLong_FromLong(((FractionObject*)self)->numerator),
        PyLong_FromLong(((FractionObject*)self)->denominator));
  Py_hash_t h = PyObject_Hash(tuple);
  Py_DECREF(tuple);
  return h;
}


static PyObject* fraction_str(PyObject* self)
{
  if(((FractionObject*)self)->denominator == 1) {
    return PyUnicode_FromFormat("%d",((FractionObject*)self)->numerator);
  }
  return PyUnicode_FromFormat("%d/%d",((FractionObject*)self)->numerator,((FractionObject*)self)->denominator);
}

static int Fraction_init(FractionObject *self, PyObject *args, PyObject *Py_UNUSED(ignored))
{
  fraction_set((PyObject*)self,args);
  return 0;
}

static PyMemberDef fraction_members[] = {
  { "numerator", T_INT, offsetof(FractionObject, numerator),READONLY,"numerator"},
  { "denominator", T_INT, offsetof(FractionObject, denominator),READONLY,"denominator"},
  {NULL}
};

static PyNumberMethods fraction_number_methods = {
  .nb_add = fraction_add,
  .nb_subtract = fraction_subtract,
  .nb_multiply = fraction_multiply,
  .nb_true_divide = fraction_divide,
  .nb_absolute = fraction_abs,
  .nb_negative = fraction_negative,
  .nb_positive = fraction_positive,
  .nb_float = fraction_float,
  .nb_int = fraction_int,
  .nb_power = fraction_pow,
};

static PyTypeObject FractionType = {
  PyVarObject_HEAD_INIT(NULL, 0)
  .tp_name = "fraction.Fraction",
  .tp_doc = "Fraction munipulation",
  .tp_basicsize = sizeof(FractionObject),
  .tp_itemsize = 0,
  .tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  .tp_new = PyType_GenericNew,
  .tp_init = (initproc) Fraction_init,
  .tp_members = fraction_members,
  .tp_methods = Fraction_methods,
  .tp_richcompare = fraction_richcmp,
  .tp_as_number = &fraction_number_methods,
  .tp_str = fraction_str,
  .tp_hash = fraction_hash,
//    .tp_getset = Fraction_getsetters,
};

static PyModuleDef fractionmodule = {
    PyModuleDef_HEAD_INIT,
    .m_name = "fraction",
    .m_doc = "Fraction Module",
    .m_size = -1,
};

static PyTypeObject MixedFractionType = {
  PyVarObject_HEAD_INIT(NULL, 0)
  .tp_name = "fraction.MixedFraction",
  .tp_doc = "Mixed Fraction",
  .tp_basicsize = sizeof(MixedFractionObject),
  .tp_itemsize = 0,
  .tp_base = &FractionType,
  .tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  .tp_str = mixed_fraction_str,
};

PyMODINIT_FUNC
PyInit_fraction(void)
{
    PyObject *m;
    if (PyType_Ready(&FractionType) < 0)
        return NULL;

    if (PyType_Ready(&MixedFractionType) < 0)
      return NULL;

    m = PyModule_Create(&fractionmodule);
    if (m != NULL) {
      Py_INCREF(&FractionType);
      if (PyModule_AddObject(m, "Fraction", (PyObject *) &FractionType) < 0) {
          Py_DECREF(&FractionType);
          Py_DECREF(m);
          return NULL;
      }
      Py_INCREF(&MixedFractionType);
      if (PyModule_AddObject(m, "MixedFraction", (PyObject *) &MixedFractionType) < 0) {
          Py_DECREF(&FractionType);
          Py_DECREF(&MixedFractionType);
          Py_DECREF(m);
          return NULL;
      }
    }
    return m;
}

#ifdef __cplusplus
}
#endif
