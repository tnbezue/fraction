import re

class Fraction:
  'Fraction class'
  epsilon = 5e-6
  loops = 0
  __re_fraction = re.compile(r"^\s*([-+]?\d+?\s+)?([-+]?\d+)\/([-+]?\d+)\s*$")

  @staticmethod
  def isnumber(n):
    return isinstance(n,int) or isinstance(n,float)

  @staticmethod
  def isint(n):
    return (int(n) == n)

  @staticmethod
  def GCD(aa,bb):
    a=abs(aa)
    b=abs(bb)
    while b != 0:
      t = b
      b = a % b
      a = t

    return a

  @staticmethod
  def reduce(f):
    if f.__denominator < 0:
      f.__denominator = -f.__denominator
      f.__numerator = -f.__numerator
    gcd = Fraction.GCD(f.__numerator,f.__denominator)
    f.__denominator /= gcd
    f.__numerator /= gcd

  @staticmethod
  def from_mixed(f,w,n,d):
    sign = 1
    if w < 0:
      w=-w
      sign*=-1
    if n < 0:
      n=-n
      sign*=-1
    if d < 0:
      sign*=-1
      d = -d
    f.__numerator = sign*(w*d+n)
    f.__denominator = d
    Fraction.reduce(f)

  @staticmethod
  def from_number(f,value):
    hm2=0
    hm1=1
    h=0
    km2 = 1
    km1 = 0
    k=0
    Fraction.loops = 0
    v = value
    while True:
      a = int(v)
      h = a*hm1 + hm2
      k = a*km1 + km2
      if(abs(value - float(h)/float(k)) < Fraction.epsilon):
        break
      v = 1.0/(v - float(a))
      hm2 = hm1
      hm1 = h
      km2 = km1
      km1 = k
      Fraction.loops += 1
    if k < 0:
      k=-k
      h=-h
    f.__numerator = h
    f.__denominator = k

  @staticmethod
  def from_fraction_string(f,s):
    m =Fraction.__re_fraction.match(s)
    valid = False
    if isinstance(m,re.Match):
      valid = True
      if m.group(1) == None:
        f.__numerator = int(m.group(2))
        f.__denominator = int(m.group(3))
      else:
        Fraction.from_mixed(f,int(m.group(1)),int(m.group(2)),int(m.group(3)));
    return valid

  @staticmethod
  def from_number_string(f,s):
    valid=True
    try:
      Fraction.from_number(f,float(s))
    except ValueError:
      valid=False
    return valid

  @staticmethod
  def from_string(f,s):
    valid = Fraction.from_fraction_string(f,s)
    if not valid:
      valid = Fraction.from_number_string(f,s)
    return valid

  @staticmethod
  def value_to_fraction(value):
    if isinstance(value,Fraction):
      return value
    if Fraction.isnumber(value):
      return Fraction(value)
    return NotImplemented

  @staticmethod
  def fraction_to_value(value):
    if isinatance(value,Fraction):
      return float(value.__numerator)/float(value.__denominator)
    if Fraction.isnumber(value):
      return value
    return NotImplemented

  @classmethod
  def Loops(self):
    return Fraction.loops

  def __init__(self,*args):
    Fraction.epsilon=5e-6
    self.set(*args)

  @property
  def numerator(self):
    return self.__numerator

  @property
  def denominator(self):
    return self.__denominator

  def set(self,*args):
    nargs=len(args)
    self.__numerator = 0
    self.__denominator = 1
    if nargs == 0:
      self.__numerator = 0
      self.__denominator = 1
    elif nargs == 1:
      if isinstance(args[0],Fraction):
        self.__numerator = args[0].__numerator
        self.__denominator = args[0].__denominator
      elif isinstance(args[0],int):
        self.__numerator = args[0]
        self.__denominator = 1
      elif isinstance(args[0],float):
        Fraction.from_number(self,args[0])
      elif isinstance(args[0],str):
        if not Fraction.from_string(self,args[0]):
          print("Exception of invalid string")
      else:
        print("Exception")

    elif nargs == 2:
      if Fraction.isint(args[0]) and Fraction.isint(args[1]):
        self.__numerator = int(args[0])
        self.__denominator = int(args[1])
        Fraction.reduce(self)

    elif nargs == 3:
      if Fraction.isint(args[0]) and Fraction.isint(args[1]) and Fraction.isint(args[2]):
        Fraction.from_mixed(self,int(args[0]),int(args[1]),int(args[2]))

    else:
      print("Error")

  def __round__(self,denom=100):
    v = 0
    if denom < self.__denominator:
      v = type(self)(int(round(float(self.__numerator)*float(denom)/float(self.__denominator))),int(denom))
    else:
      v = type(self)(self)
    return v

  def __abs__(self):
    fnew = type(self)(self)
    fnew.__numerator = abs(fnew.__numerator)
    return fnew

  def __hash__(self):
    return hash((self.__numerator,self.__denominator))

  def __float__(self):
    return float(self.__numerator)/float(self.__denominator)

  def __int__(self):
    return int(Fraction.__float__(self))

  def __trunc__(self):
    return Fraction.__int__(self)

  def __floor__(self):
    return floor(Fraction.__float__(self))

  def __ceil__(self):
    return ceil(Fraction.__float__(self))

  def __str__(self):
    s= "%d" % (self.__numerator)
    if self.__denominator !=1:
      s+="/%d" % (self.__denominator)
    return s

  def __format__(self,format_spec):
    return format(str(self), format_spec)

  def __eq__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator == lhs.__denominator*rhs.__numerator

  def __ne__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator != lhs.__denominator*rhs.__numerator

  def __lt__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator < lhs.__denominator*rhs.__numerator

  def __le__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator <= lhs.__denominator*rhs.__numerator

  def __gt__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator > lhs.__denominator*rhs.__numerator

  def __ge__(self,other):
    lhs = Fraction.value_to_fraction(self)
    rhs = Fraction.value_to_fraction(other)
    return lhs.__numerator*rhs.__denominator >= lhs.__denominator*rhs.__numerator

  def __add__(self,other):
    if isinstance(other,Fraction) or Fraction.isnumber(other):
      rhs = Fraction.value_to_fraction(other)
      return type(self)(int(self.__numerator*rhs.__denominator + rhs.__numerator*self.__denominator),int(self.__denominator*rhs.__denominator))
    return NotImplemented

  def __radd__(self,other):
    if Fraction.isnumber(other):
      return other + float(self.__numerator)/float(self.denominator)
    return NotImplemented

  def __sub__(self,other):
    if isinstance(other,Fraction) or Fraction.isnumber(other):
      rhs = Fraction.value_to_fraction(other)
      return type(self)(int(self.__numerator*rhs.__denominator - rhs.__numerator*self.__denominator),int(self.__denominator*rhs.__denominator))
    return NotImplemented

  def __rsub__(self,other):
    if Fraction.isnumber(other):
      return other - float(self.__numerator)/float(self.denominator)
    return NotImplemented

  def __mul__(self,other):
    if isinstance(other,Fraction) or Fraction.isnumber(other):
      rhs = Fraction.value_to_fraction(other)
      return type(self)(int(self.__numerator*rhs.__numerator),int(self.__denominator*rhs.__denominator))
    return NotImplemented

  def __rmul__(self,other):
    if Fraction.isnumber(other):
      return other * float(self.__numerator)/float(self.denominator)
    return NotImplemented

  def __truediv__(self,other):
    if isinstance(other,Fraction) or Fraction.isnumber(other):
      rhs = Fraction.value_to_fraction(other)
      return type(self)(int(self.__numerator*rhs.__denominator),int(rhs.__numerator*self.__denominator))
    return NotImplemented

  def __rtruediv__(self,other):
    if Fraction.isnumber(other):
      return other*float(self.denominator) / float(self.__numerator)
    return NotImplemented

  def __pow__(self,other):
    if not Fraction.isnumber(other) and not isinstance(other,Fraction):
      return NotImplemented
    b = float(self)
    e = float(other)
    if b < 0 and not Fraction.isint(e):
      return NotImplemented
    r=pow(b,abs(e))
    if e<0:
      r=1.0/r
    return type(self)(r)

  def __rpow__(self,other):
    if not Fraction.isnumber(other):
      return NotImplemented
    b = float(other)
    e = float(self)
    if b < 0 and not Fraction.isint(e):
      return NotImplemented
    r=pow(b,abs(e))
    if e<0:
      r=1.0/r
    return r

class MixedFraction(Fraction):

  def __str__(self):
    if self.denominator == 1 or abs(self.numerator) < self.denominator:
      return Fraction.__str__(self)
    w = self.numerator / self.denominator
    n = abs(self.numerator) % self.denominator
    return "%d %d/%d" % (w,n,self.denominator)
