#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <structmember.h>
#include <stdlib.h>

#define CALCULATE_LOOP_STATISTICS 1
/*
  Internal methods
*/
typedef struct {
  PyObject_HEAD
  int numerator;
  int denominator;
} FractionObject;

// Euclid's algorithm to find greatest common divisor
int fraction_internal_gcd(register int a,register int b)
{
  register int t;
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
  int temp = lhs->numerator*rhs->denominator - rhs->numerator*lhs->denominator;
  switch(op) {
    case Py_LT: rc = temp < 0; break;
    case Py_LE: rc = temp <= 0; break;
    case Py_EQ: rc = temp == 0; break;
    case Py_NE: rc = temp != 0; break;
    case Py_GT: rc = temp > 0; break;
    case Py_GE: rc = temp >= 0; break;
  }
  return rc;
}

static void fraction_internal_set_fraction(FractionObject* self,FractionObject* other)
{
  self->numerator=other->numerator;
  self->denominator=other->denominator;
}

static void fraction_internal_set_num_denom(FractionObject* f,int n,int d)
{
  if( d < 0) {
    n = -n;
    d = -d;
  }
  int divisor = fraction_internal_gcd(abs(n),d);
  f->numerator =  n/divisor;
  f->denominator = d/divisor;

}

static int fraction_internal_whitespace(const char* ptr)
{
  int n=0;
  for(;*ptr && isspace(*ptr);ptr++,n++);
  return n;
}

static int fraction_internal_digits(const char *ptr)
{
  int n=0;
  for(;*ptr && isdigit(*ptr);ptr++,n++);
  return n;
}

static int fraction_internal_is_fraction(const char* ptr,int test_for_sign)
{
  int n=fraction_internal_whitespace(ptr);
  ptr+=n;
  if(test_for_sign) {
    if(*ptr == '+' || *ptr == '-')
      ptr++;
  }
  if((n=fraction_internal_digits(ptr))>0) {
    ptr+=n;
    if(*ptr == '/') {
      ptr++;
      if((n=fraction_internal_digits(ptr))>0) {
        ptr+=n;
        n=fraction_internal_whitespace(ptr);
        if(*(ptr + n)==0)
          return 1;
      }
    }
  }
  return 0;
}

static int fraction_internal_is_mixed_fraction(const char* ptr)
{
  int n =fraction_internal_whitespace(ptr);
  ptr+=n;
  if(*ptr == '+' || *ptr == '-')
    ptr++;
  if((n=fraction_internal_digits(ptr))>0) {
    ptr+=n;
    return fraction_internal_is_fraction(ptr,0);
  }
  return 0;
}

static double epsilon=5e-7;
#ifdef CALCULATE_LOOP_STATISTICS
  int nLoops=0;
#endif

static void fraction_internal_set_float(FractionObject* f,double d)
{
  register int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
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
  f->numerator=h;
  f->denominator=k;

}

static void fraction_internal_add(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,lhs->numerator*rhs->denominator + lhs->denominator*rhs->numerator,
        rhs->denominator*lhs->denominator);
}

static void fraction_internal_subtract(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,lhs->numerator*rhs->denominator - lhs->denominator*rhs->numerator,
        rhs->denominator*lhs->denominator);
}

static void fraction_internal_multiply(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,lhs->numerator*rhs->numerator,rhs->denominator*lhs->denominator);
}

static void fraction_internal_divide(FractionObject* result,FractionObject* lhs,FractionObject* rhs)
{
  fraction_internal_set_num_denom(result,lhs->numerator*rhs->denominator,lhs->denominator*rhs->numerator);
}

static PyObject* fraction_gcd(PyObject* self,PyObject *args)
{
  int n1,n2;
  if(PyArg_ParseTuple(args,"ii",&n1,&n2))
    return PyLong_FromLong(fraction_internal_gcd(n1,n2));
  return 0;
}

static PyObject* fraction_set(PyObject* self,PyObject* args)
{
  int num,denom,whole;
  double dbl;
  char* str;
  char* endptr;
  /* Try three integers. */
  if(PyArg_ParseTuple(args,"iii",&whole,&num,&denom)) {
    fraction_internal_set_num_denom((FractionObject*)self,whole*denom+(whole < 0 ? -1 : 1)*num,denom);
  } else {
    PyErr_Clear();
    if(PyArg_ParseTuple(args,"ii",&num,&denom)) {
      fraction_internal_set_num_denom((FractionObject*)self,num,denom);
    } else {
      PyErr_Clear();
      if(PyArg_ParseTuple(args,"i",&num)) {
        fraction_internal_set_num_denom((FractionObject*)self,num,1);
      } else {
        PyErr_Clear();
        if(PyArg_ParseTuple(args,"d",&dbl)) {
          fraction_internal_set_float((FractionObject*)self,dbl);
        } else {
          PyErr_Clear();
          if(PyArg_ParseTuple(args,"s",&str)) {
            if(fraction_internal_is_mixed_fraction(str)) {
              sscanf(str,"%d %d/%d",&whole,&num,&denom);
              fraction_internal_set_num_denom((FractionObject*)self,whole*denom+(whole < 0 ? -1 : 1)*num,denom);
            } else if(fraction_internal_is_fraction(str,1)) {
              sscanf(str,"%d/%d",&num,&denom);
              fraction_internal_set_num_denom((FractionObject*)self,num,denom);
            } else {
              dbl = strtod(str,&endptr);
              num=fraction_internal_whitespace(endptr);
              if(*(endptr+num)==0) {
                fraction_internal_set_float((FractionObject*)self,dbl);
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
  int denom=-1;
  char err_msg[256];
  err_msg[0]=0;
  FractionObject* result = PyObject_New(FractionObject,&FractionType);

  if(nArgs == 1) {
    if(PyFloat_CheckExact(args[0])) {
      denom = (int)round(PyFloat_AsDouble(args[0]));
    } else if(PyLong_CheckExact(args[0])) {
      denom = PyLong_AsLong(args[0]);
    } else {
      sprintf(err_msg,"round takes an integer or floating point argument - '%s' specified.",args[0]->ob_type->tp_name);
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
    sprintf(err_msg,"round expects a value greater than 1 (got %d)",denom);
    PyErr_SetString(PyExc_ValueError,err_msg);
  }
  return (PyObject*)result;
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
    fraction_internal_set_num_denom(f,PyLong_AsLong(other),1);
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
    .m_doc = "Example module that creates an extension type.",
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
    if (m == NULL)
        return NULL;

    Py_INCREF(&FractionType);
    if (PyModule_AddObject(m, "Fraction", (PyObject *) &FractionType) < 0) {
        Py_DECREF(&FractionType);
        Py_DECREF(m);
        return NULL;
    }
    return m;
}
