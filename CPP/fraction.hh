#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <iostream>
#include <string>

class fraction_t {
  protected:
    int32_t numerator_;
    int32_t denominator_;
  public:
    fraction_t() : numerator_(0), denominator_(1) { }
    fraction_t(const fraction_t& o) : numerator_(o.numerator_), denominator_(o.denominator_) { }
    fraction_t& operator=(const fraction_t& o)
        { numerator_=o.numerator_; denominator_=o.denominator_; return *this; }

    fraction_t(int32_t n,int32_t d) { set(n,d); }
    fraction_t(int32_t w,int32_t n,int32_t d) { set(w*d+n,d); }
    fraction_t(double d) { *this=d; }

    void set(int64_t,int64_t);
    void set_mixed(int64_t w,int64_t n,int64_t d) { set(w*d+(w<0 ? -1 : 1)*n,d); }

    void numerator(int32_t n) { set(n,denominator_); }
    int32_t numerator() const { return numerator_; }
    void denominator(int32_t d) { set(numerator_,d); }
    int32_t denominator() const { return denominator_; }

    operator double() const { return static_cast<double>(numerator_)/static_cast<double>(denominator_); }
    fraction_t& operator=(double);

    fraction_t& operator+=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
              + static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }
    fraction_t& operator-=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_)
              - static_cast<int64_t>(o.numerator_)*static_cast<int64_t>(denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }
    fraction_t& operator*=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.numerator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.denominator_)); return *this; }
    fraction_t& operator/=(const fraction_t& o)
          { set(static_cast<int64_t>(numerator_)*static_cast<int64_t>(o.denominator_),
              static_cast<int64_t>(denominator_)*static_cast<int64_t>(o.numerator_)); return *this; }

    fraction_t& round(int denom);
    std::string to_s() const;
    std::string to_mixed_s() const;
    static int64_t gcd(int64_t,int64_t);
    static double epsilon;
};

  inline fraction_t operator+(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t+=b; return t; }
  inline fraction_t operator-(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t-=b; return t; }
  inline fraction_t operator*(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t*=b; return t; }
  inline fraction_t operator/(const fraction_t& a,const fraction_t& b)
      { fraction_t t=a; t/=b; return t; }

  inline int fraction_cmp(const fraction_t& lhs,const fraction_t& rhs)
    { return static_cast<int64_t>(lhs.numerator())*static_cast<int64_t>(rhs.denominator())
            - static_cast<int64_t>(rhs.numerator())*static_cast<int64_t>(lhs.denominator()); }
  inline bool operator==(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)==0; }
  inline bool operator!=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)!=0; }
  inline bool operator< (const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)< 0; }
  inline bool operator<=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)<=0; }
  inline bool operator> (const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)> 0; }
  inline bool operator>=(const fraction_t& lhs,const fraction_t& rhs) { return fraction_cmp(lhs,rhs)>=0; }

  inline bool operator==(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))==0; }
  inline bool operator!=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))!=0; }
  inline bool operator< (const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))< 0; }
  inline bool operator<=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))<=0; }
  inline bool operator> (const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))> 0; }
  inline bool operator>=(const fraction_t& lhs,double rhs) { return fraction_cmp(lhs,fraction_t(rhs))>=0; }

  inline bool operator==(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)==0; }
  inline bool operator!=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)!=0; }
  inline bool operator< (double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)< 0; }
  inline bool operator<=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)<=0; }
  inline bool operator> (double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)> 0; }
  inline bool operator>=(double lhs,const fraction_t& rhs) { return fraction_cmp(fraction_t(lhs),rhs)>=0; }

  inline std::ostream& operator<<(std::ostream& o,const fraction_t& f) { o << f.to_s(); return o; }
#endif
