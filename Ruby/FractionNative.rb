
class Fraction < Numeric

  attr_reader :numerator,:denominator

  @@epsilon = 5e-6

  def self.epsilon
    @@epsilon
  end

  def self.epsilon=(value)
    # Can't be negative and not too small
    value = value.abs
    if value < 5e-20
      value = 5e-20;
    end
    @@epsilon = value
  end

  def self.loops
    @@loops
  end

  def self.gcd(a,b)
    a=a.abs()
    b=b.abs()
    while b != 0
      t = b
      b = a % b
      a = t
    end
    a
  end

  def self.reduce(n,d)
    if d < 0
      d=-d
      n=-n
    end
    gcd = Fraction::gcd(n.abs(),d)
    if gcd > 1
      n /= gcd
      d /= gcd
    end
    [n,d]
  end

  def self.from_number(value)
    hm2 = 0
    hm1 = 1
    h = 0
    km2 = 1
    km1 = 0
    k = 0
    v = value
    @@loops = 0
    while true
      a = v.to_i
      h=a*hm1 + hm2
      k=a*km1 + km2
      if((value - h.to_f/k.to_f).abs() < @@epsilon)
        break
      end
      v = 1.0/(v -a.to_f)
      hm2=hm1
      hm1=h
      km2=km1
      km1=k
      @@loops += 1
    end
    if k < 0
      k=-k
      h=-h
    end
    [h,k] # h and k are already reduced
  end

  def self.from_mixed(w,n,d)
    sign = 1
    if(w < 0)
      sign=-sign
      w=-w
    end
    if(n < 0)
      sign=-sign
      n=-n
    end
    if(d < 0)
      sign=-sign
      d=-d
    end
    Fraction::reduce(sign*(w*d + n),d)
  end

  def self.try_fraction(str)
    n = 0
    d = -1
    if str =~ /^\s*([-+]?\d+?\s+)?([-+]?\d+)\/([-+]?\d+)\s*$/
      if $1 == nil
        n,d = Fraction::reduce($2.to_i,$3.to_i)
      else
        n,d = from_mixed($1.to_i,$2.to_i,$3.to_i)
      end
    end
    [n, d]
  end

  def self.try_number(str)
    value = 0
    n = 0
    d = -1
    if str =~ /^\s*([-+]?(\d+)(\.\d*)?([eE][-+]?\d+)?)\s*$/ or str  =~ /^\s*([-+]?(\d*)(\.\d+)([eE][-+]?\d+)?)\s*$/
      n,d = self.from_number(str.to_f)
    end
    [n,d]
  end

  def self.from_string(str)
    n,d = Fraction::try_number(str)
    if d == -1
      n,d = Fraction::try_fraction(str)
    end
    [n,d ]
  end

  def initialize(*args)
    set(*args)
  end

  def set(*args)
    n=0
    d=1
    case(args.size)
      when 0
        n = 0
        d = 1

      when 1
        if args[0].is_a?(Fraction)  # May be a fraction ..
          n = args[0].numerator
          d = args[0].denominator
        elsif args[0].is_a?(Numeric)  # .. a integer or floating point number ..
          n,d = Fraction::from_number(args[0].to_f)
        elsif args[0].is_a?(String) # .. or string containing number or fraction
          n,d = Fraction::from_string(args[0])
          if d == -1
            put("Invalid argument to set")
            exit 0
          end
        else
          puts("Invalid option to set")
          exit 0
        end

      when 2 # 2 integer
        n,d = Fraction::reduce(args[0].to_i,args[1].to_i)
      when 3
        n,d = Fraction::from_mixed(args[0].to_i,args[1].to_i,args[2].to_i)
      else
        puts ("Too many arguments to set")
        exit(0)
    end
    @numerator = n
    @denominator = d
  end

  # if value is not a fraction, make it one
  def self.makeFraction(value)
    v = value
    if not value.is_a?(Fraction)
      v = Fraction.new(value)
    end
    v
  end

  # For the operators +,-,*,/, and **, return the type of the self parameter
  def +(o)
    lhs=Fraction::makeFraction(self)
    rhs=Fraction::makeFraction(o)
    self.class.new(lhs.numerator*rhs.denominator + rhs.numerator*lhs.denominator,lhs.denominator*rhs.denominator)
  end

  def -(o)
    lhs=Fraction::makeFraction(self)
    rhs=Fraction::makeFraction(o)
    self.class.new(lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator,lhs.denominator*rhs.denominator)
  end

  def *(o)
    lhs=Fraction::makeFraction(self)
    rhs=Fraction::makeFraction(o)
    self.class.new(lhs.numerator*rhs.numerator,lhs.denominator*rhs.denominator)
  end

  def /(o)
    lhs=Fraction::makeFraction(self)
    rhs=Fraction::makeFraction(o)
    self.class.new(lhs.numerator*rhs.denominator,lhs.denominator*rhs.numerator)
  end

  def **(o)
    self.class.new(self.to_f**o.to_f)
  end

  def -@
    self.class.new(-@numerator,@denominator)
  end

  def +@
    self.class.new(self)
  end

  def <=> (o)
    lhs=Fraction::makeFraction(self)
    rhs=Fraction::makeFraction(o)
    lhs.numerator*rhs.denominator <=> lhs.denominator*rhs.numerator
  end

  def abs()
    self.class.new(@numerator.abs(),@denominator)
  end

  def round!(denom)
    if denom < @denominator
      @numerator,@denominator = Fraction::reduce((@numerator.to_f*denom.to_f/@denominator.to_f).round.to_i,denom.to_i)
    end
    self
  end

  def round(denom)
    self.class.new(self).round!(denom)
  end

  def to_i
    self.to_f.to_i
  end

  def to_f
    @numerator.to_f/@denominator.to_f
  end

  def to_s
    "#{@numerator}"+(@denominator != 1 ? "/#{@denominator}" : "")
  end
end

class MixedFraction < Fraction

  def to_s
    if @numerator.abs <= @denominator || @denominator == 1
      super.to_s()
    else
      w = (@numerator.to_f / @denominator.to_f).to_i
      n = @numerator.abs % @denominator
      "#{w} #{n}/#{@denominator}"
    end
  end
end
