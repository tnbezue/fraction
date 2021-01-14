class Fraction {

  constructor(...args) {
    this.set(...args);
    this.epsilon = 5e-6;
  }

  get numerator() { return this.numerator_; }
  get denominator() { return this.denominator_; }

/*  set epsilon(eps) { this.epsilon = eps; }
  get epsilon() { return this.epsilon; }*/

  static epsilon = 5e-6;
  static loops = 0;
  static gcd(a,b) {
    while(b!= 0) {
      let t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static set_num_denom(f,n,d) {
    if(d < 0) {
      n=-n;
      d=-d;
    }
    let divisor=Fraction.gcd(Math.abs(n),d)
    f.numerator_=n/divisor;
    f.denominator_=d/divisor;
  }

  static set_real(f,d) {
    var hm2=0,hm1=1,km2=1,km1=0;
    var h,k;
    var v = d;
    Fraction.loops=0;
    while(true) {
      var a=Math.floor(v);
      h=a*hm1 + hm2;
      k=a*km1 + km2;
//      print(a,h,k);
      if(Math.abs(d - h/k) < Fraction.epsilon) {
        break;
      }
      v = 1.0/(v-a);
      hm2=hm1;
      hm1=h;
      km2=km1;
      km1=k;
      Fraction.loops++;
    }
    if(k<0) {
      k=-k;
      h=-h;
    }
    f.numerator_=h;
    f.denominator_=k;
  }

  /* # of arguments
    0 set to default values
    1 A number (int or float), string, or Fraction
    2 Two integers to set numerator and denominator
    3 Three integers to set as mixed fraction (whole, numerator, and denominator)
  */
  set(arg1,arg2,arg3)
  {
    if(arguments.length == 0) {
      this.numerator_=0; this.denominator_=1;
    } else if(arguments.length == 1) {
      if(typeof(arg1)=="object") { //has to be anoter fraction object
        this.numerator_=arg1.numerator_;
        this.denominator_=arg1.denominator_;
      } else { // a number
        Fraction.set_real(this,arg1);
      }
    } else if(arguments.length == 2) {
      Fraction.set_num_denom(this,arg1,arg2)
    } else if(arguments.length == 3) {
      Fraction.set_num_denom(this,arg1*arg3+(arg1 < 0 ? -1 : 1)*arg2,arg3);
    } else {
      /* Error */
    }
  }

  plus(b) {
    this.set(this.numerator_*b.denominator_ + this.denominator_*b.numerator_,this.denominator_*b.denominator_);
  }

  minus(b) {
    this.set(this.numerator_*b.denominator_ - this.denominator_*b.numerator_,this.denominator_*b.denominator_);
  }

  times(b) {
    this.set(this.numerator_*b.numerator_,this.denominator_*b.denominator_);
  }

  divided_by(b) {
    this.set(this.numerator_*b.denominator_,this.denominator_*b.numerator_);
  }

  static fraction_plus_fraction(a,b)
  {
    var c = new Fraction();
    c.numerator_=a.numerator_;
    c.denominator_=a.denominator_;
    c.plus(b);
    return c;
  }

  static fraction_minus_fraction(a,b)
  {
    var c = new Fraction();
    c.numerator_=a.numerator_;
    c.denominator_=a.denominator_;
    c.minus(b);
    return c;
  }

  static fraction_times_fraction(a,b)
  {
    var c = new Fraction();
    c.numerator_=a.numerator_;
    c.denominator_=a.denominator_;
    c.times(b);
    return c;
  }

  static fraction_divided_by_fraction(a,b)
  {
    var c = new Fraction();
    c.numerator_=a.numerator_;
    c.denominator_=a.denominator_;
    c.divided_by(b);
    return c;
  }

  equal(rhs)
  {
    return Fraction.cmp(this,rhs) == 0;
  }

  static fraction_equal_fraction(lhs,rhs) {
    return lhs.equal(rhs);
  }

  not_equal(rhs)
  {
    return Fraction.cmp(this,rhs) != 0;
  }

  static fraction_not_equal_fraction(lhs,rhs)
  {
    return lhs.not_equal(rhs);
  }

  less_than(rhs)
  {
    return Fraction.cmp(this,rhs) < 0;
  }

  static fraction_less_than_fraction(lhs,rhs)
  {
    return lhs.less_than(rhs);
  }

  less_than_equal(rhs)
  {
    return Fraction.cmp(this,rhs) <= 0;
  }

  static fraction_less_than_equal_fraction(lhs,rhs)
  {
    return lhs.less_than_equal(rhs);
  }

  greater_than(rhs)
  {
    return Fraction.cmp(this,rhs) > 0;
  }

  static fraction_greater_than_fraction(lhs,rhs)
  {
    return lhs.greater_than(rhs);
  }

  greater_than_equal(rhs)
  {
    return Fraction.cmp(this,rhs) >= 0;
  }

  static fraction_greater_than_equal_fraction(lhs,rhs)
  {
    return lhs.greater_than_equal(rhs);
  }

  static cmp(lhs,rhs) {
    return lhs.numerator_*rhs.denominator_ - rhs.numerator_*lhs.denominator_;
  }

  round(d)
  {
    if(d<this.denominator_) {
      this.set(Math.round(this.numerator_*d/this.denominator_),Math.round(d));
    }
    return this;
  }
  toString() {
    if(this.denominator_ == 1) {
      return this.numerator_.toString();
    }
    return this.numerator_ + "/" + this.denominator_;
  }

  toMixedString() {
    if(this.numerator_ <= this.denominator_) {
      return this.toString();
    }
    var whole=Math.floor(this.numerator_/this.denominator_);
    var n = Math.abs(this.numerator_) % this.denominator_;
    if(n==0) {
      return whole.toString();
    }
    return whole+" "+n+"/"+this.denominator_;
  }

  valueOf() {
    return this.numerator_/this.denominator_;
  }
}

module.exports = Fraction;
