#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <iostream>
#include <string>

class fraction_t {
  protected:
    int32_t numerator_;
    int32_t denominator_;
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
     * Set fraction equal to other fraction
    */
    fraction_t& operator=(const fraction_t& o)
        { numerator_=o.numerator_; denominator_=o.denominator_; return *this; }

    /*
     * Create new fraction using specified numerator and denominator
    */
    fraction_t(int32_t n,int32_t d) { set(n,d); }

    /*
     * Create new fraction from mixed fraction values
    */
    fraction_t(int32_t w,int32_t n,int32_t d) { set(w*d+n,d); }

    /*
     *  Create new fraction using double value
    */
    fraction_t(double d) { *this=d; }

    /*
     *  Set the numerator and denominator of fraction
    */
    void set(int64_t,int64_t);

    /*
     * Set the fraction value from mixed fraction
    */
    void set_mixed(int64_t w,int64_t n,int64_t d) { set(w*d+(w<0 ? -1 : 1)*n,d); }

    /*
     * Get the value of numerator
    */
    int32_t numerator() const { return numerator_; }

    /*
     * Get the value of the denominator
    */
    int32_t denominator() const { return denominator_; }

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
    fraction_t& operator+=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
              + static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }

    /*
     * Subtract fraction from this fraction
    */
    fraction_t& operator-=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
              - static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }

    /*
     * Multiply this fraction by fraction
    */
    fraction_t& operator*=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.numerator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }

    /*
     * Divide this fraction by fraction
    */
    fraction_t& operator/=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.numerator_)); return *this; }

    /*
     * Round fraction.  Fraction is rounded such that new denominator is no larger than denom
    */
    fraction_t& round(int denom);

    /*
     * Absolute value
    */
    fraction_t round() { return fraction_t(abs(numerator_),denominator_); }

    /*
     * Convert fraction to string
    */
    std::string to_s() const;

    /*
     * Convert fraction to string (mixed fraction)
    */
    std::string to_mixed_s() const;

    /*
     * Greatest common divisor
    */
    static int64_t gcd(int64_t,int64_t);

    /*
     * Tolerance
    */
    static double epsilon;
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


  /*
   * Compares two fractions.  Return < 0 if lhs < rhs; 0 if lhs==rhs; > 0 if lhs > rhs
  */
  inline int fraction_cmp(const fraction_t& lhs,const fraction_t& rhs)
    { return static_cast<int64_t>(lhs.numerator())*static_cast<int64_t>(rhs.denominator())
            - static_cast<int64_t>(rhs.numerator())*static_cast<int64_t>(lhs.denominator()); }

  /*
   * Determines if lhs fraction equal to rhs fraction
  */
  inline bool operator==(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)==0; }

  /*
   * Determines if lhs fraction not equal to rhs fraction
  */
  inline bool operator!=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)!=0; }

  /*
   * Determines if lhs fraction less than rhs fraction
  */
  inline bool operator< (const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)< 0; }

  /*
   * Determines if lhs fraction less than or equal to rhs fraction
  */
  inline bool operator<=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)<=0; }

  /*
   * Determines if lhs fraction greater than rhs fraction
  */
  inline bool operator> (const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)> 0; }

  /*
   * Determines if lhs fraction greater than or equal to rhs fraction
  */
  inline bool operator>=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)>=0; }

  /*
   * Determines if lhs fraction equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator==(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))==0; }

  /*
   * Determines if lhs fraction not equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator!=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))!=0; }

  /*
   * Determines if lhs fraction less than rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator< (const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))< 0; }

  /*
   * Determines if lhs fraction less than or equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator<=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))<=0; }

  /*
   * Determines if lhs fraction greater than rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator> (const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))> 0; }

  /*
   * Determines if lhs fraction greater than or equal to rhs double value (double is converted to fraction for comparison)
  */
  inline bool operator>=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))>=0; }

  /*
   * Determines if lhs double value equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator==(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)==0; }

  /*
   * Determines if lhs double value not equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator!=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)!=0; }

  /*
   * Determines if lhs double value less than rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator< (double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)< 0; }

  /*
   * Determines if lhs double value less than or equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator<=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)<=0; }

  /*
   * Determines if lhs double value greater than rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator> (double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)> 0; }

  /*
   * Determines if lhs double value greater than or equal to rhs fraction (double is converted to fraction for comparison)
  */
  inline bool operator>=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)>=0; }


  /*
   * Output fraction to stream
  */
  inline std::ostream& operator<<(std::ostream& o,const fraction_t& f) { o << f.to_s(); return o; }

#endif
