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

#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <iostream>
#include <string>

#ifdef USE_32_BIT_FRACTION
typedef int32_t fraction_numerator_denominator_t;
#else
typedef int64_t fraction_numerator_denominator_t;
#endif

class fraction_t {
  protected:
    fraction_numerator_denominator_t numerator_;
    fraction_numerator_denominator_t denominator_;

    static int64_t gcd_internal(int64_t,int64_t);
    void set_internal(int64_t,int64_t);

    bool set_number_string(const char*);
    bool set_fraction_string(const char*);
  public:

    /*
     * Create new fraction with default value of zero (numberator = 0, denominator = 1)
    */
    fraction_t() : numerator_(0), denominator_(1) { }

    /*
     *  Create new fraction by coping other fraction
    */
    fraction_t(const fraction_t& o) : numerator_(o.numerator_), denominator_(o.denominator_) { }

    /*

    */
    fraction_t(fraction_numerator_denominator_t n) : numerator_(n), denominator_(1) { }

    /*
     * Create new fraction using specified numerator and denominator
    */
    fraction_t(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { set(n,d); }

    /*
     * Create new fraction using specified numerator and denominator
    */
    fraction_t(fraction_numerator_denominator_t w,fraction_numerator_denominator_t n,
            fraction_numerator_denominator_t d) { set(w,n,d); }

    /*
     *  Create new fraction using double value
    */
    fraction_t(double d) { *this=d; }

    /*
     * Set fration from string
    */
    fraction_t(const char*str) { set(str); }

    /*
     * Set fraction equal to other fraction
    */
    fraction_t& operator=(const fraction_t& o)
        { numerator_=o.numerator_; denominator_=o.denominator_; return *this; }

    /*
     *  Set the numerator and denominator of fraction
    */
    void set(fraction_numerator_denominator_t n) { this->numerator_ = n; this->denominator_=1; }

    /*
     *  Set the numerator and denominator of fraction
    */
    void set(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) { set_internal(static_cast<int64_t>(n),static_cast<int64_t>(d)); }

    /*
     *  Set the numerator and denominator of fraction
    */
    void set(fraction_numerator_denominator_t w,fraction_numerator_denominator_t n,fraction_numerator_denominator_t d);

    /*
     *
    */
    void set(const char*);

    /*
     * Get the value of numerator
    */
    fraction_numerator_denominator_t numerator() const { return numerator_; }

    /*
     * Get the value of the denominator
    */
    fraction_numerator_denominator_t denominator() const { return denominator_; }

    /*
     * Return value of fraction as double value
    */
    operator double() const { return static_cast<double>(numerator_)/static_cast<double>(denominator_); }

    /*
     * Set fraction from double value
    */
    fraction_t& operator=(double);

    /*
     * Add fraction to this fraction
    */
    fraction_t& operator+=(const fraction_t& o) {
      set_internal(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
          + static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
          static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_));
      return *this;
    }

    /*
     * Subtract fraction from this fraction
    */
    fraction_t& operator-=(const fraction_t& o) {
      set_internal(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
          - static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
          static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_));
      return *this;
    }

    /*
     * Multiply this fraction by fraction
    */
    fraction_t& operator*=(const fraction_t& o) {
      set_internal(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.numerator_),
          static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_));
      return *this;
    }

    /*
     * Divide this fraction by fraction
    */
    fraction_t& operator/=(const fraction_t& o) {
      set_internal(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_),
          static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.numerator_));
      return *this;
    }

    /*
     * Round fraction.  Fraction is rounded such that new denominator is no larger than denom
    */
    fraction_t& round(fraction_numerator_denominator_t denom);
    fraction_t round(fraction_numerator_denominator_t denom) const { fraction_t f=*this; return f.round(denom); }

    /*
     * Reciprocal
    */
    fraction_t reciprocal() const;

    /*
     * Absolute value
    */
    fraction_t abs() const { return fraction_t(::llabs(numerator_),denominator_); }

    /*
     * Convert fraction to string
    */
    std::string to_s() const;

    /*
     * Convert fraction to string (mixed fraction)
    */
//    std::string to_mixed_s() const;

    /*
     * Greatest common divisor
    */
    static fraction_numerator_denominator_t gcd(fraction_numerator_denominator_t a,fraction_numerator_denominator_t b) {
      return static_cast<fraction_numerator_denominator_t>(gcd_internal(static_cast<int64_t>(a),static_cast<int64_t>(b)));
//      return gcd_internal(a,b);
    }

    /*
     * Tolerance
    */
    static double epsilon;

    /*
     * Compares two fractions.  Return < 0 if lhs < rhs; 0 if lhs==rhs; > 0 if lhs > rhs
    */
    static int cmp(const fraction_t& lhs,const fraction_t& rhs);
    /*
     * Compares two fractions.  Return < 0 if lhs < rhs; 0 if lhs==rhs; > 0 if lhs > rhs
    */
    static int cmp(const fraction_t &lhs,double rhs);
};


  /*
   * Create new fraction from sum of two fractions
  */
  inline fraction_t operator+(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t+=b; return t; }

  /*
   * Create new fraction from difference of two fractions
  */
  inline fraction_t operator-(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t-=b; return t; }

  /*
   * Create new fraction from product of two fractions
  */
  inline fraction_t operator*(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t*=b; return t; }

  /*
   * Create new fraction by dividing two fractions
  */
  inline fraction_t operator/(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t/=b; return t; }

  inline fraction_t operator+(const fraction_t& f,double d)
      { return fraction_t(static_cast<double>(f)+d); }

  inline fraction_t operator-(const fraction_t& f,double d)
      { return fraction_t(static_cast<double>(f)-d); }

  inline fraction_t operator*(const fraction_t& f,double d)
      { return fraction_t(static_cast<double>(f)*d); }

  inline fraction_t operator/(const fraction_t& f,double d)
      { return fraction_t(static_cast<double>(f)/d); }

  inline double operator+(double d,const fraction_t&f)
      { return static_cast<double>(operator+(f,d)); }

  inline double operator-(double d,const fraction_t&f)
      { return (d-static_cast<double>(f)); }

  inline double operator*(double d,const fraction_t&f)
      { return static_cast<double>(operator*(f,d)); }

  inline double operator/(double d,const fraction_t&f)
      { return (d/static_cast<double>(f)); }

  /*
   * Determines if lhs fraction equal to rhs fraction
  */
  inline bool operator==(const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)==0; }

  /*
   * Determines if lhs fraction not equal to rhs fraction
  */
  inline bool operator!=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)!=0; }

  /*
   * Determines if lhs fraction less than rhs fraction
  */
  inline bool operator< (const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)< 0; }

  /*
   * Determines if lhs fraction less than or equal to rhs fraction
  */
  inline bool operator<=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)<=0; }

  /*
   * Determines if lhs fraction greater than rhs fraction
  */
  inline bool operator> (const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)> 0; }

  /*
   * Determines if lhs fraction greater than or equal to rhs fraction
  */
  inline bool operator>=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_t::cmp(lhs,rhs)>=0; }

  /*
   * Determines if lhs fraction equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator==(const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)==0; }

  /*
   * Determines if lhs fraction not equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator!=(const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)!=0; }

  /*
   * Determines if lhs fraction less than rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator< (const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)< 0; }

  /*
   * Determines if lhs fraction less than or equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator<=(const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)<=0; }

  /*
   * Determines if lhs fraction greater than rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator> (const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)> 0; }

  /*
   * Determines if lhs fraction greater than or equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator>=(const fraction_t& lhs,double rhs) { return fraction_t::cmp(lhs,rhs)>=0; }

  /*
   * Determines if lhs double value equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator==(double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)==0; }

  /*
   * Determines if lhs double value not equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator!=(double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)!=0; }

  /*
   * Determines if lhs double value less than rhs fraction (double is converted to fraction for comparison)
   * Note: reverse of cmp(fraction_t,double)
  */
  inline bool operator< (double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)> 0; }

  /*
   * Determines if lhs double value less than or equal to rhs fraction (double is converted to fraction for comparison)
   * Note: reverse of cmp(fraction_t,double)
  */
  inline bool operator<=(double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)>=0; }

  /*
   * Determines if lhs double value greater than rhs fraction (double is converted to fraction for comparison)
   * Note: reverse of cmp(fraction_t,double)
  */
  inline bool operator> (double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)< 0; }

  /*
   * Determines if lhs double value greater than or equal to rhs fraction (double is converted to fraction for comparison)
   * Note: reverse of cmp(fraction_t,double)
  */
  inline bool operator>=(double lhs,const fraction_t& rhs) { return fraction_t::cmp(rhs,lhs)<=0; }


  /*
   * Power function for fractions
  **/
  fraction_t pow(const fraction_t&,const fraction_t&);
  fraction_t pow(const fraction_t&,double);
  double pow(double,const fraction_t&);
  /*
   * Output fraction to stream
  */
  inline std::ostream& operator<<(std::ostream& o,const fraction_t& f) { o << f.to_s(); return o; }

  /*
   * Mixed fraction
  */
  class mixed_fraction_t : public fraction_t {
    public:
      mixed_fraction_t() : fraction_t() { }
      mixed_fraction_t(fraction_numerator_denominator_t n) : fraction_t(n) { }
      mixed_fraction_t(fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) : fraction_t(n,d) { }
      mixed_fraction_t(fraction_numerator_denominator_t w,fraction_numerator_denominator_t n,fraction_numerator_denominator_t d) : fraction_t(w,n,d) { }
      mixed_fraction_t(double d) : fraction_t(d) { }
      mixed_fraction_t(const char* str) : fraction_t(str) { }
      mixed_fraction_t(const mixed_fraction_t& f) { numerator_=f.numerator(); denominator_=f.denominator(); }
      mixed_fraction_t(const fraction_t& f) { numerator_=f.numerator(); denominator_=f.denominator(); }

    std::string to_s() const;
  };

  inline std::ostream& operator<<(std::ostream& o,const mixed_fraction_t& f) { o << f.to_s(); return o; }

#endif
