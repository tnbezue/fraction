#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <structmember.h>
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

static int cmp_fraction(FractionObject *lhs,FractionObject *rhs,int op)
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

static void fraction_internal_set_fraction(FractionObject* self,FractionObject* other)
{
  self->numerator=other->numerator;
  self->denominator=other->denominator;
}

static void fraction_internal_set_num_denom(FractionObject* f,int64_t n,int64_t d)
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

static int whitespace(const char* str)
{
  const char *ptr = str;
  for(;isspace(*ptr); ptr++);
  return ptr - str;
}

static int digits(const char* str)
{
  const char* ptr =str;
  for(;isdigit(*ptr);ptr++);
  return (ptr - str) ;
}

typedef struct {
  double value;
  int valid;
} double_result_t;

#define is_int(d) ((int64_t)d == d)
#define signof(d) ((d) < 0 ? -1 : 1)

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

typedef struct {
  int64_t numerator;
  int64_t denominator;
  int valid;
} fraction_result_t;

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

static double epsilon=5e-6;
#ifdef CALCULATE_LOOP_STATISTICS
  int nLoops=0;
#endif

static void fraction_internal_set_float(FractionObject* f,double d)
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

static void fraction_internal_add(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator + (int64_t)lhs->denominator*(int64_t)rhs->numerator,
        (int64_t)rhs->denominator*(int64_t)lhs->denominator);
}

static void fraction_internal_subtract(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator - (int64_t)lhs->denominator*(int64_t)rhs->numerator,
        (int64_t)rhs->denominator*(int64_t)lhs->denominator);
}

static void fraction_internal_multiply(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->numerator,(int64_t)rhs->denominator*(int64_t)lhs->denominator);
}

static void fraction_internal_divide(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,
        (int64_t)lhs->numerator*(int64_t)rhs->denominator,(int64_t)lhs->denominator*(int64_t)rhs->numerator);
}

static PyObject* fraction_gcd(PyObject* self,PyObject *args)
{
  fraction_numerator_denominator_t n1,n2;
  if(PyArg_ParseTuple(args,TWO_INTEGERS,&n1,&n2))
    return PyLong_FromLongLong(fraction_internal_gcd((int64_t)n1,(int64_t)n2));
  return 0;
}

static PyObject* fraction_set(PyObject* self,PyObject* args)
{
  fraction_numerator_denominator_t num,denom,whole;
  double dbl;
  char* str;
  /* Try three integers. */
  if(PyArg_ParseTuple(args,THREE_INTEGERS,&whole,&num,&denom)) {
    fraction_internal_set_num_denom((FractionObject*)self,whole*denom+(whole < 0 ? -1 : 1)*num,denom);
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
            fraction_result_t fr = is_fraction(str);
            if(fr.valid) {
              fraction_internal_set_num_denom((FractionObject*)self,fr.numerator,fr.denominator);
            } else {
              double_result_t dr = is_number(str);
              if(dr.valid) {
                fraction_internal_set_float((FractionObject*)self,dr.value);
              } else { /* Error */
              }
            }
          }
        }
      }
    }
  }
  Py_RETURN_NONE;
}

static PyTypeObject FractionType;

static PyObject* fraction_round(PyObject* self,PyObject* args[],int nArgs)
{
  fraction_numerator_denominator_t denom=-1;
  char err_msg[256];
  err_msg[0]=0;
  FractionObject* result = PyObject_New(FractionObject,&FractionType);

  if(nArgs == 1) {
    if(PyFloat_CheckExact(args[0])) {
      denom = (fraction_numerator_denominator_t)round(PyFloat_AsDouble(args[0]));
    } else if(PyLong_CheckExact(args[0])) {
      denom = PYLONG_AS_LONG(args[0]);
    } else {
      sprintf(err_msg,"round() takes an integer or floating point argument - '%s' specified.",args[0]->ob_type->tp_name);
      PyErr_SetString(PyExc_TypeError,err_msg);
    }
  } else {
    sprintf(err_msg,"round() takes 1 argument (%d given)",nArgs);
    PyErr_SetString(PyExc_TypeError,err_msg);
  }
  if(denom > 0) {
    FractionObject* fself=(FractionObject*)self;
    if(denom < fself->denominator) {
      fraction_internal_set_num_denom(result,(int)round(((double)denom*(double)fself->numerator)/(double)fself->denominator),denom);
    } else
      fraction_internal_set_fraction(result,fself);
  } else if(err_msg[0] == 0) {
    sprintf(err_msg,"round expects a value greater than 1 (got % " PRIND ")",denom);
    PyErr_SetString(PyExc_ValueError,err_msg);
  }
  return (PyObject*)result;
}

static PyObject* fraction_abs(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);

  FractionObject* fself=(FractionObject*)self;
  fraction_internal_set_num_denom(result,llabs(fself->numerator),fself->denominator);
  return (PyObject*)result;
}

static PyObject* fraction_negative(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);

  FractionObject* fself=(FractionObject*)self;
  fraction_internal_set_num_denom(result,-fself->numerator,fself->denominator);
  return (PyObject*)result;
}

static PyObject* fraction_positive(PyObject* self)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);

  FractionObject* fself=(FractionObject*)self;
  fraction_internal_set_num_denom(result,fself->numerator,fself->denominator);
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
  return (PyObject*)PyLong_FromLong(fself->numerator/fself->denominator);
}

static PyObject* fraction_add(PyObject* self,PyObject* other)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);
  FractionObject* f = PyObject_New(FractionObject,&FractionType);
  if(PyObject_TypeCheck(other,&FractionType)) {
    fraction_internal_set_fraction(f,(FractionObject*)other);
  } else if(PyFloat_CheckExact(other)) {
    fraction_internal_set_float(f,PyFloat_AsDouble(other));
  } else if(PyLong_CheckExact(other)) {
    fraction_internal_set_num_denom(f,PYLONG_AS_LONG(other),1);
  }
  fraction_internal_add(result,(FractionObject*)self,f);
  Py_DECREF(f);
  return (PyObject*)result;
}

static PyObject* fraction_subtract(PyObject* self,PyObject* other)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);
  FractionObject* f = PyObject_New(FractionObject,&FractionType);
  if(PyObject_TypeCheck(other,&FractionType)) {
    fraction_internal_set_fraction(f,(FractionObject*)other);
  } else if(PyFloat_CheckExact(other)) {
    fraction_internal_set_float(f,PyFloat_AsDouble(other));
  } else if(PyLong_CheckExact(other)) {
    fraction_internal_set_num_denom(f,PyLong_AsLong(other),1);
  }
  fraction_internal_subtract(result,(FractionObject*)self,f);
  Py_DECREF(f);
  return (PyObject*)result;
}

static PyObject* fraction_multiply(PyObject* self,PyObject* other)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);
  FractionObject* f = PyObject_New(FractionObject,&FractionType);
  if(PyObject_TypeCheck(other,&FractionType)) {
    fraction_internal_set_fraction(f,(FractionObject*)other);
  } else if(PyFloat_CheckExact(other)) {
    fraction_internal_set_float(f,PyFloat_AsDouble(other));
  } else if(PyLong_CheckExact(other)) {
    fraction_internal_set_num_denom(f,PyLong_AsLong(other),1);
  }
  fraction_internal_multiply(result,(FractionObject*)self,f);
  Py_DECREF(f);
  return (PyObject*)result;
}

static PyObject* fraction_divide(PyObject* self,PyObject* other)
{
  FractionObject* result = PyObject_New(FractionObject,&FractionType);
  FractionObject* f = PyObject_New(FractionObject,&FractionType);
  if(PyObject_TypeCheck(other,&FractionType)) {
    fraction_internal_set_fraction(f,(FractionObject*)other);
  } else if(PyFloat_CheckExact(other)) {
    fraction_internal_set_float(f,PyFloat_AsDouble(other));
  } else if(PyLong_CheckExact(other)) {
    fraction_internal_set_num_denom(f,PyLong_AsLong(other),1);
  }
  fraction_internal_divide(result,(FractionObject*)self,f);
  Py_DECREF(f);
  return (PyObject*)result;
}

static PyObject* fraction_str(PyObject* self);
static PyObject* fraction_to_mixed_string(PyObject* self,void* closure)
{
  FractionObject* fself=(FractionObject*)self;
  int whole = fself->numerator / fself->denominator;
  if(whole == 0)
    return fraction_str(self);
  int num = fself->numerator - whole*fself->denominator;
  if(num == 0)
    return PyUnicode_FromFormat("%d",whole);
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
  { "gcd", fraction_gcd, METH_STATIC|METH_VARARGS, "Computes greatest common divisor"},
  { "set", fraction_set, METH_VARARGS, "Sets value of fraction"},
  { "round", (PyCFunction) fraction_round, METH_FASTCALL, "Rounds fraction" },
  { "abs",  (PyCFunction) fraction_abs, METH_FASTCALL, "Absolute value of fraction" },
  { "to_mixed_string", (PyCFunction) fraction_to_mixed_string,METH_NOARGS, "Fraction represented as mixed fraction"},
  { "epsilon", (PyCFunction) fraction_epsilon,METH_STATIC|METH_FASTCALL, "Gets/sets epsilon"},
#ifdef CALCULATE_LOOP_STATISTICS
  { "Loops", (PyCFunction) fraction_loops,METH_STATIC|METH_NOARGS, "Number of loops to convert floating point to fraction"},
#endif
  {NULL}  /* Sentinel */
};


static PyObject * fraction_richcmp(PyObject *obj1, PyObject *obj2, int op)
{
  PyObject* rc;
  rc = cmp_fraction((FractionObject*)obj1,(FractionObject*)obj2,op) ? Py_True : Py_False;
  Py_INCREF(rc);
  return rc;
}

static PyObject* fraction_str(PyObject* self)
{
  if(((FractionObject*)self)->denominator == 1) {
    return PyUnicode_FromFormat("%d",((FractionObject*)self)->numerator);
  }
  return PyUnicode_FromFormat("%d/%d",((FractionObject*)self)->numerator,((FractionObject*)self)->denominator);
}

static int Fraction_init(FractionObject *self, PyObject *args, PyObject *kwds)
{
  if(PyTuple_Size(args) > 0) {
    fraction_set((PyObject*)self,args);
  } else {
    self->numerator = 0;
    self->denominator = 1;
  }
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
};

static PyTypeObject FractionType = {
    PyVarObject_HEAD_INIT(NULL, 0)
    .tp_name = "fraction.Fraction",
    .tp_doc = "Fraction munipulation",
    .tp_basicsize = sizeof(FractionObject),
    .tp_itemsize = 0,
    .tp_flags = Py_TPFLAGS_DEFAULT,
    .tp_new = PyType_GenericNew,
    .tp_init = (initproc) Fraction_init,
    .tp_members = fraction_members,
    .tp_methods = Fraction_methods,
    .tp_richcompare = fraction_richcmp,
    .tp_as_number = &fraction_number_methods,
    .tp_str = fraction_str,
//    .tp_getset = Fraction_getsetters,
};

static PyModuleDef fractionmodule = {
    PyModuleDef_HEAD_INIT,
    .m_name = "fraction",
    .m_doc = "Fraction.",
    .m_size = -1,
};

PyMODINIT_FUNC
PyInit_fraction(void)
{
//  FractionType.tp_as_number->nb_add = fraction_add;
//  printf("%p\n",FractionType.tp_as_number->nb_add);
    PyObject *m;
    if (PyType_Ready(&FractionType) < 0)
        return NULL;

    m = PyModule_Create(&fractionmodule);
    if (m != NULL) {
      Py_INCREF(&FractionType);
      if (PyModule_AddObject(m, "Fraction", (PyObject *) &FractionType) < 0) {
          Py_DECREF(&FractionType);
          Py_DECREF(m);
          return NULL;
      }
    }
    return m;
}
