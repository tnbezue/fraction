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

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <inttypes.h>
#include <ctype.h>

#if defined (__cplusplus)
extern "C"
{
#endif

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#if defined (__cplusplus)
}
#endif

#include "utils.h"

typedef struct fraction_s fraction_t;
struct fraction_s
{
  lua_Integer numerator_;
  lua_Integer denominator_;
};

// Euclid's algorithm to find greatest common divisor
static int64_t fraction_gcd_private(register int64_t a,register int64_t b)
{
  register int64_t t;
  while(b!=0) {
    t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/*
  Reduces numerator and denominator.
  Assignes to fraction.
*/
static void fraction_set_private(fraction_t* f,int64_t n,int64_t d)
{
  // Negative sign should be in numerator
  if(d<0) {
    d=-d;
    n=-n;
  }

  // Reduce to lowest fraction
  int64_t divisor;
  if((divisor=fraction_gcd_private(llabs(n),d)) != 1) {
    n/=divisor;
    d/=divisor;
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

  f->numerator_=(lua_Integer)n;
  f->denominator_=(lua_Integer)d;
}

// Add fraction b to fraction a -- result is a
#define fraction_plus_fraction(a,b) \
  fraction_set_private(&a,(int64_t)a.numerator_*(int64_t)b.denominator_ + \
        (int64_t)b.numerator_*(int64_t)a.denominator_,(int64_t)a.denominator_*(int64_t)b.denominator_)

// Subtractract fraction b from fraction a -- result is a
#define fraction_minus_fraction(a,b) \
  fraction_set_private(&a,(int64_t)a.numerator_*(int64_t)b.denominator_ - \
        (int64_t)b.numerator_*(int64_t)a.denominator_,(int64_t)a.denominator_*(int64_t)b.denominator_)

// Multiply fraction a by fraction b -- result is a
#define fraction_times_fraction(a,b) \
  fraction_set_private(&a,(int64_t)a.numerator_*(int64_t)b.numerator_,(int64_t)a.denominator_*(int64_t)b.denominator_)

// Divide fraction a by fraction b -- result is a
#define fraction_divided_by_fraction(a,b) \
  fraction_set_private(&a,(int64_t)a.numerator_*(int64_t)b.denominator_,(int64_t)a.denominator_*(int64_t)b.numerator_)


static int fraction_cmp(fraction_t lhs,fraction_t rhs)
{
  int64_t nd = (int64_t)lhs.numerator_*(int64_t)rhs.denominator_;
  int64_t dn = (int64_t)rhs.numerator_*(int64_t)lhs.denominator_;
  if(nd < dn) return -1;
  if(nd > dn) return 1;
  return 0;
}

#ifdef CALCULATE_LOOP_STATISTICS
static int nLoops;
#endif

// Continued fraction algorithm for converting floating point to fraction
// https://en.wikipedia.org/wiki/Continued_fraction
void fraction_set_double(fraction_t* f,double value,double fraction_epsilon)
{
  register int hm2=0,hm1=1,km2=1,km1=0,h=0,k=0;
  double v = value;
#ifdef CALCULATE_LOOP_STATISTICS
  nLoops=0;
#endif
  while(1) {
    int a=v;
    h=a*hm1 + hm2;
    k=a*km1 + km2;
    if(fabs(value - (double)h/(double)k) < fraction_epsilon)
      break;
    v = 1.0/(v - a);
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
  f->numerator_=h;
  f->denominator_=k;
}


// Lua interface

static const char* Fraction_metatable="Fraction_metatable";
static const char* MixedFraction_metatable="MixedFraction_metatable";
static const char* fraction_type = "Fraction";
static const char* mixedfraction_type = "MixedFraction";

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

typedef struct {
  double value;
  int valid;
} double_result_t;

#define is_int(d) ((int64_t)d == d)
#define signof(d) ((d) < 0 ? -1 : 1)

// Determine if value given in string is a floating point number
static double_result_t is_number(const char* str)
{
  double_result_t r={0,0};
  char* ptr;
  str+=space(str);
  if(*str != 0) {
    r.value = strtod(str,&ptr);
    if(ptr) {
      ptr+=space(ptr);
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

// Determine if value in string is a fraction
// ( (+-)? integer? (+-)? integer/(+-)? integer ) | ( (+-)? integer (/ (+-)? integer )? )
static fraction_result_t is_fraction(const char* str)
{
  fraction_result_t r;
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

static double get_epsilon(lua_State *L)
{
  double epsilon;
  lua_getglobal(L,fraction_type);
  lua_getfield(L,-1,"epsilon");
  epsilon = lua_tonumber(L,-1);
  lua_pop(L,2);
  return epsilon;
}

static int Fraction_gcd(lua_State* L)
{
  int top=lua_gettop(L);
  // If top == 2, assume called as Fraction.gcd(a,b)
  // If top == 3, assume called as Fraction:gcd(a,b)
  // Otherwise error
  if(top == 2 || top == 3) {
    lua_pushinteger(L,fraction_gcd_private(luaL_checkinteger(L,-2),luaL_checkinteger(L,-1)));
  } else
    luaL_error(L,"Improper arguments to 'Fraction:gcd'");
  return 1;
}

// Determines if value at index is a standard fraction or mixed fraction
fraction_t* testfraction(lua_State* L,int index)
{
  fraction_t* f = NULL;
  if((f=(fraction_t*)luaL_testudata(L,index,Fraction_metatable)) == NULL)
    f=(fraction_t*)luaL_testudata(L,index,MixedFraction_metatable);
  if(!f)
    puts("Not a fraction");
  return f;
}

// Checks if fraction or mixed fraction
// If either, puts appropriate metatable on the stack and return 1
// If neither, push nothing and return 0
static int get_fraction_metatable(lua_State* L,int index)
{
  if(lua_type(L,index) == LUA_TUSERDATA &&
        (luaL_testudata(L,index,Fraction_metatable) ||  luaL_testudata(L,index,MixedFraction_metatable))) {
    lua_getmetatable(L,1);
    return 1;
  }
  return 0;
}

// Create a fraction and assign the metatable on top of stack. Remove metatable from stack
// and return newly created fraction on top of stack.
// If from is defined, then copy numerator and denominator from it
static fraction_t* create_fraction(lua_State* L,fraction_t* from)
{
  fraction_t *f = (fraction_t *)lua_newuserdata(L, sizeof(fraction_t));
  if(from == NULL) {
    f->numerator_=0;
    f->denominator_=1;
  } else {
    f->numerator_=from->numerator_;
    f->denominator_=from->denominator_;
  }
  lua_pushvalue(L,-2); // Duplicate table provided
  lua_setmetatable(L, -2);
  lua_remove(L,-2);
  return f;
}

// Copy fraction from index
static fraction_t* copy_fraction(lua_State* L,int index)
{
  fraction_t* from = testfraction(L,index);
  fraction_t* fnew=NULL;
  if(from) {
    lua_getmetatable(L,index);
    fnew = create_fraction(L,from);
  }
  return fnew;
}

// Convert value (number or other fraction) to fraction
// return denominator of 0 if not converted
static fraction_t value_to_fraction(lua_State* L, int index)
{
  fraction_t f = {0,0};
  // 1 argument -- could be a number or another fraction
  int arg_type;
  if((arg_type = lua_type(L,index)) == LUA_TUSERDATA) {
    fraction_t* other =testfraction(L,index);
    if(other) {
      f.numerator_ = other->numerator_;
      f.denominator_ = other->denominator_;
    }
  } else if(arg_type == LUA_TNUMBER) {
    fraction_set_double(&f,lua_tonumber(L,index),get_epsilon(L));
  }
  return f;
}

// Convert fraction to a number
static double fraction_to_value(lua_State* L,int index)
{
  double d=0;
  int arg_type;
  if((arg_type = lua_type(L,index)) == LUA_TUSERDATA) {
    fraction_t* other =testfraction(L,index);
    if(other) {
      d=(double)other->numerator_/(double)other->denominator_;
    }
  } else if(arg_type == LUA_TNUMBER) {
    d = lua_tonumber(L,index);
  } /* else { // Error
  }
  */
  return d;
}

// set the value of the fraction
// Arguments can be:
//     nothing -- set's default values, i.e. Fraction:new()
//     a single number -- converted to a fraction, i.e Fraction:new(12.7)
//     a single string -- can be floating point or fraction, i.e Fraction("1 1/2")
//     another fraction -- numerator and denominators , i.e. Fraction:new(otherFraction)
//     two integers -- specifies numerator and denominator, i.e. Fraction:new(3,7)
//     three integer -- specifies mixed fraction (whole, numerator, denominator), i.e. Fraction:new(3,1,2)
//     a table containing any of the above. i.e Fraction:new({3,7})
static int Fraction_set(lua_State* L)
{
  // Check if fraction
  stackTrace(L,"Set -- Begin");
  fraction_t* f = testfraction(L,1);
  if(f) {
    fraction_t* other;
    int64_t sign,w,n,d;
    double wd,nd,dd;
    int i,arg_type;
    const char* str_arg;
    fraction_result_t fr;
    double_result_t dr;
    static int table_level=0; // to avoid table inside a table, inside a table, ...
    switch(lua_gettop(L)-1) {

      case 0: // Do nothing
        break;

      case 1:
        // if 1 argument, could be table, a string, or a number
        switch(arg_type = lua_type(L,-1)) {
          case LUA_TTABLE: // For table
            if(table_level == 0) {
              // Recurse Fraction_set with elements of table as arguments
              table_level++;
              lua_len(L,-1);
              lua_Integer len=luaL_checkinteger(L,-1);
              lua_pop(L,1);
              len = len > 3 ? 3 : len; // At max first three elements
              lua_pushcfunction(L,Fraction_set); // function to call
              lua_pushvalue(L,1); // Duplicate userdata
              for(i=1;i<=len;i++)
                lua_geti(L,-(2+i),i);
              lua_call(L,len+1,0);
              table_level--;
            } else {
              luaL_error(L,"Nested tables not allowed in set Fraction:set");
            }
            break;

          case LUA_TSTRING: // string arg. could be floating point ("11.2345") or fraction ("1 3/5")
            str_arg = lua_tostring(L,-1);
            fr = is_fraction(str_arg); // check for valid fraction
            if(fr.valid) {
              fraction_set_private(f,fr.numerator,fr.denominator);
            } else {
              dr=is_number(str_arg); // check for floating point number
              if(dr.valid) {
                fraction_set_double(f,dr.value,get_epsilon(L));
              } else {
                luaL_error(L,"Invalid string argument (\"%s\") to Fraction:set",str_arg);
              }
            }
            break;

          case LUA_TNUMBER:
            fraction_set_double(f,lua_tonumber(L,-1),get_epsilon(L));
            break;

          case LUA_TUSERDATA:
            other = testfraction(L, -1);
            if(other) {
              f->numerator_=other->numerator_;
              f->denominator_=other->denominator_;
            } else {
              luaL_error(L,"Invalid argument type (%d) to fraction set method",arg_type);
            }
            break;

          default: // error
            luaL_error(L,"Invalid argument type (%d) to fraction set method",arg_type);
        }
        break;

      case 2: // Two integers -- numerator and denominator
        if(lua_type(L,-1) == LUA_TNUMBER && lua_type(L,-2) == LUA_TNUMBER) {
          nd=lua_tonumber(L,-2);
          dd=lua_tonumber(L,-1);
          if(is_int(nd) && is_int(dd)) {
            fraction_set_private(f,(int64_t)nd,(int64_t)dd);
          } else {
            luaL_error(L,"When 2 arguments to Fraction:set, both must be integers");
          }
        } else {
          luaL_error(L,"When 2 arguments to Fraction:set, both must be integers");
        }
        break;

      case 3: // Three integers -- mixed fraction (whole, numerator, denominator)
        if(lua_type(L,-1) == LUA_TNUMBER && lua_type(L,-2) == LUA_TNUMBER && lua_type(L,-3) == LUA_TNUMBER) {
          wd=lua_tonumber(L,-3);
          nd=lua_tonumber(L,-2);
          dd=lua_tonumber(L,-1);
          if(is_int(wd) && is_int(nd) && is_int(dd)) {
            sign = signof(wd)*signof(nd)*signof(dd);
            w = llabs((int64_t)wd);
            n = llabs((int64_t)nd);
            d = llabs((int64_t)dd);
            fraction_set_private(f,sign*(w*d+n),d);
          } else {
            luaL_error(L,"When 3 arguments to Fraction:set, all must be integers");
          }
        } else {
          luaL_error(L,"When 3 arguments to Fraction:set, all must be integers");
        }
        break;
    }
  } else {
      luaL_error(L,"Expected Fraction as self argument in Fraction:set");
  }
  return 0;
}

// Absolute value of fraction
static int Fraction_abs(lua_State* L)
{
  fraction_t *fnew = copy_fraction(L,1);
  if(fnew) {
    fnew->numerator_=llabs(fnew->numerator_);
//    fnew->denominator_=f->denominator_;
  } else {
    // Error
  }
  return 1;
}

// Round fraction to new denominator
static int Fraction_round(lua_State* L)
{
  fraction_t *fnew = copy_fraction(L,1);
  if(fnew) {
    lua_Integer new_d = llabs(luaL_checkinteger(L,2)); // Just in case it was negative
    if(new_d < fnew->denominator_) {
      fraction_set_private(fnew,(int64_t)round((double)fnew->numerator_*(double)new_d/(double)fnew->denominator_),
        (int64_t)new_d);
    }
  } else {
    // Error
  }
  return 1;
}

// Add two fractions or one fraction to number
// Whichever is specified first will be the type returned
static int Fraction_add(lua_State *L)
{
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  fraction_plus_fraction(a,b);
  // return the type of the first argument
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushnumber(L,(double)a.numerator_/(double)a.denominator_);
  } else { // Assume its a fraction
    lua_getmetatable(L,1);
    create_fraction(L,&a);
  }
  return 1;
}

// Subtract fractions
static int Fraction_sub(lua_State *L)
{
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  fraction_minus_fraction(a,b);
  // return the type of the first argument
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushnumber(L,(double)a.numerator_/(double)a.denominator_);
  } else { // Assume its a fraction
    lua_getmetatable(L,1);
    create_fraction(L,&a);
  }
  return 1;
}

// Multiply fractions
static int Fraction_mul(lua_State *L)
{
  // one of these has to be a fraction. Get the type of one of them
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  fraction_times_fraction(a,b);
  // return the type of the first argument
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushnumber(L,(double)a.numerator_/(double)a.denominator_);
  } else { // Assume its a fraction
    lua_getmetatable(L,1);
    create_fraction(L,&a);
  }
  return 1;
}

// Divide fractions
static int Fraction_div(lua_State *L)
{
  // one of these has to be a fraction. Get the type of one of them
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  fraction_divided_by_fraction(a,b);
  // return the type of the first argument
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushnumber(L,(double)a.numerator_/(double)a.denominator_);
  } else { // Assume its a fraction
    lua_getmetatable(L,1);
    create_fraction(L,&a);
  }
  return 1;
}

// Integer (or floor) division
static int Fraction_idiv(lua_State *L)
{
  // one of these has to be a fraction. Get the type of one of them
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  fraction_divided_by_fraction(a,b);
  a.numerator_=a.numerator_/a.denominator_;
  a.denominator_=1;
  // return the type of the first argument
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushinteger(L,a.numerator_);
  } else { // Assume its a fraction
    lua_getmetatable(L,1);
    create_fraction(L,&a);
  }
  return 1;
}

// Raise fraction to a power -- either base or exponent can be a fraction
// Type of base is the return type
static int Fraction_pow(lua_State *L)
{
  double result;
  double b=fraction_to_value(L,1);
  double e=fraction_to_value(L,2);
  // Can only raise a negative value to an integer value
  if(b < 0) {
    if(!is_int(e)) {
      luaL_error(L,"Base cannot be negative for non integer power");
    }
  }
  result=pow(b,fabs(e));
  if(e < 0) {
    result = 1.0/result;
  }
  // Return the type of the base
  if(lua_type(L,1) == LUA_TNUMBER) {
    lua_pushnumber(L,result);
  } else { // It's a fraction
    get_fraction_metatable(L,1);
    fraction_t* f = create_fraction(L,NULL);
    fraction_set_double(f,result,get_epsilon(L));
  }
  return 1;
}

// Unary minus
static int Fraction_unm(lua_State *L)
{
  fraction_t* f=copy_fraction(L,1);
  f->numerator_ = -f->numerator_;
  return 1;
}

// equality
static int Fraction_eq(lua_State *L)
{
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  lua_pushboolean(L,fraction_cmp(a,b) == 0);
  return 1;
}

// less than comparison
static int Fraction_lt(lua_State *L)
{
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  lua_pushboolean(L,fraction_cmp(a,b) < 0);
  return 1;
}

// less than or equal
static int Fraction_le(lua_State *L)
{
  fraction_t a = value_to_fraction(L,1);
  fraction_t b = value_to_fraction(L,2);
  lua_pushboolean(L,fraction_cmp(a,b) <= 0);
  return 1;
}

// Convert fraction to string
static int Fraction_tostring(lua_State *L)
{
  fraction_t *f = (fraction_t *)luaL_checkudata(L, 1,Fraction_metatable );
  char str[256];
  int np=sprintf(str,LUA_INTEGER_FMT,f->numerator_);
  if(f->denominator_ != 1)
    sprintf(str+np,"/" LUA_INTEGER_FMT,f->denominator_);
  lua_pushstring(L,str);
  return 1;
}

// Convert fraction to number
static int Fraction_tonumber(lua_State *L)
{
  fraction_t* f = testfraction(L,1);
  lua_pushnumber(L,(double)f->numerator_/(double)f->denominator_);
  return 1;
}

// Convert a mixed fraction to a string
static int MixedFraction_tostring(lua_State *L)
{
  fraction_t *f = (fraction_t *)luaL_checkudata(L, 1,MixedFraction_metatable );
  char str[256];
  if(llabs(f->numerator_)>f->denominator_ && f->denominator_ != 1) {
    lua_Integer whole = f->numerator_/f->denominator_;
    lua_Integer n = llabs(f->numerator_)-llabs(whole)*f->denominator_;
    sprintf(str,LUA_INTEGER_FMT " " LUA_INTEGER_FMT "/" LUA_INTEGER_FMT,whole,n,f->denominator_);
  } else {
    // Normal fraction
    int np=sprintf(str,LUA_INTEGER_FMT,f->numerator_);
    if(f->denominator_ != 1)
      sprintf(str+np,"/" LUA_INTEGER_FMT,f->denominator_);
  }
  lua_pushstring(L,str);
  return 1;
}

// Fraction index method
static int Fraction_index(lua_State *L)
{
  fraction_t* f=testfraction(L,1);
  const char* key = lua_tostring(L,2);

  if(strcmp(key,"numerator")==0) {
    lua_pushinteger(L,f->numerator_);
  } else if(strcmp(key,"denominator")==0) {
    lua_pushinteger(L,f->denominator_);
  } else {
    luaL_getmetatable(L,Fraction_metatable);
    lua_getfield(L,-1,key);
    lua_remove(L,-2);  // remove the metatable
  }
  return 1;
}

// LUA interface
/*
  Should be called as Fraction:new(args)
  if zero args, it was called as Fraction.new()
  if one args,
*/
static int Fraction_new(lua_State *L) {
  // Must be called with (Mixed)Fraction:new(args)
  // First argument will be Fraction lib
  stackTrace(L,"New -- Begin");
  int nargs = lua_gettop(L);
  luaL_getmetatable(L,Fraction_metatable);
  stackTrace(L,"New -- After getmetatable");
  create_fraction(L,NULL);
  if(nargs > 1) {
    // Call set with same arguments to set numerator, denominator
    nargs--;
    int arg_pos=2;
    if(nargs > 0) {
      lua_pushcfunction(L,Fraction_set);
      lua_pushvalue(L,-2); // Duplicate fraction created
      int i;
      for(i=0;i<nargs;i++,arg_pos++)
        lua_pushvalue(L,arg_pos);
      lua_call(L,nargs+1,0);
    }
  }
  return 1;
}

static int MixedFraction_new (lua_State *L) {
  // Create a normal fraction ...
  Fraction_new(L);
  // ... and change metatable to MixedFraction
  luaL_getmetatable(L,MixedFraction_metatable);
  lua_setmetatable(L, -2);
  return 1;
}

#ifdef CALCULATE_LOOP_STATISTICS
static int Fraction_loops(lua_State *L)
{
  lua_pushinteger(L,nLoops);
  return 1;
}
#endif

static const struct luaL_Reg fractionlib_f [] = {
//  { "__index",Fraction_mt_mt_index},
  {"new", Fraction_new},
  {"gcd", Fraction_gcd},
  {"__call", Fraction_new},  // so Fraction() is same as Fraction:new()
#ifdef CALCULATE_LOOP_STATISTICS
  {"loops", Fraction_loops},
#endif
  {NULL, NULL}
};

static const struct luaL_Reg fractionlib_m [] = {
  {"set", Fraction_set},
  {"abs", Fraction_abs},
  {"round", Fraction_round},
  {"tonumber", Fraction_tonumber},
  {NULL, NULL}
};

// Special metamethods -- these are not "inherited"
static const struct luaL_Reg fractionlib_special_m [] = {
      {"__index", Fraction_index},
      {"__add",   Fraction_add},
      {"__sub",   Fraction_sub},
      {"__mul",   Fraction_mul},
      {"__div",   Fraction_div},
      {"__idiv", Fraction_idiv},
      {"__pow",  Fraction_pow},
      {"__unm",  Fraction_unm},
      {"__len",  Fraction_tonumber},
      {"__eq",   Fraction_eq},
      {"__lt",   Fraction_lt},
      {"__le",   Fraction_le},
      {"__tostring",   Fraction_tostring},
  {NULL, NULL}
};

static const struct luaL_Reg mixedfractionlib_f [] = {
  {"new", MixedFraction_new},
  {"__call", MixedFraction_new},
  {NULL, NULL}
};

LUAMOD_API int luaopen_Fraction (lua_State *L) {
  // Create the metatable instances of Fraction
  luaL_newmetatable(L, Fraction_metatable);
  luaL_setfuncs(L,fractionlib_m,0);
  luaL_setfuncs(L,fractionlib_special_m,0);

  // Create metatable for instances of MixedFraction
  luaL_newmetatable(L, MixedFraction_metatable);
  luaL_setfuncs(L,fractionlib_special_m,0);
  // Change the __tostring method
  lua_pushcfunction(L,MixedFraction_tostring);
  lua_setfield(L,-2,"__tostring");
  // MixedFraction_metatable.__index=Fraction_metatable
  lua_pushvalue(L,-2);
  lua_setfield(L,-2,"__index");

  lua_pop(L,2); // Don't need metatables on stack

  // Create Fraction Library
  luaL_newlib(L,fractionlib_f);
  // Create Fraction.epsilon
  lua_pushnumber(L,5e-6);
  lua_setfield(L,-2,"epsilon");
  lua_pushvalue(L,-1);
  lua_setmetatable(L, -2);
  // Create global name
  lua_pushvalue(L, -1);
  lua_setglobal(L,fraction_type);

  // Mixed fraction lib
  luaL_newlib(L,mixedfractionlib_f);
  lua_pushvalue(L,-1);
  lua_setmetatable(L, -2);
  lua_pushvalue(L,-2);
  lua_setfield(L,-2,"__index");

  // Create global name
  lua_setglobal(L,mixedfraction_type);

  return 1;
}
