-- Useful utilities
local function round(value)
  return math.floor(value + 0.5)
end

local function inherit(klass,parent,metamethods)
  if klass.mt ~= nil and parent.mt ~= nil then
    for _,k in ipairs(metamethods) do
      if parent.mt[k] ~= nil and klass.mt[k] == nil then
        klass.mt[k] = parent.mt[k]
      end
    end
    klass.mt.__index = parent.mt
  end
end

local function isa(obj,tbl_or_type)
--if (type(obj) == tbl_or_type)
  if type(obj) == "table" then
    mt = getmetatable(obj)
    if mt then
      while true do
        if rawequal(mt,tbl_or_type.mt) then
          return true
        end
        mt_index=mt.__index
        if(mt_index == nil) or (rawequal(mt_index,mt)) then
          return false
        end
        mt=mt_index
      end
    end
  end
  return false
end

local function to_i(value)
  local sign = 1
  if value < 0 then
    sign = -1
    value = -value
  end
  return sign*math.floor(value)
end

-- Fraction class
Fraction = {  epsilon = 5e-6 , loops = 0 , __name = "Fraction" }
Fraction.__index = Fraction
Fraction.mt = { }
Fraction.mt.__index=Fraction.mt

function Fraction:new(...)
  local o = { numerator = 0, denominator = 1}
  setmetatable(o,Fraction.mt)
  o:set(...)
  return o
end

-- Creates a fraction of the specified type (normal Fraction or Mixed Mraction)
-- Actually, create a table and assign the specified metatable
local function fraction_of_same_type(self,...)
  local mt = getmetatable(self)
  o = Fraction:new(...)
  setmetatable(o,mt)
  return o
end

function Fraction.gcd(a,b)
  a=math.abs(a)
  b=math.abs(b)
  while(b ~= 0) do
    local t = b
    b = a % b
    a = t
  end
  return a
end

function Fraction.mt:reduce()
  if (self.denominator < 0) then
    self.denominator = -self.denominator
    self.numerator = -self.numerator
  end
  local gcd=Fraction.gcd(self.numerator,self.denominator)
  if (gcd ~= 1) then
    self.denominator = self.denominator/gcd
    self.numerator = self.numerator/gcd
  end
  return self
end

function Fraction.mt:set_mixed(w,n,d)
  sign = 1
  w=to_i(w)
  n=to_i(n)
  d=to_i(d)
  if(w < 0) then
    sign = sign*-1
    w=-w
  end
  if(n < 0) then
    sign = sign*-1
    n=-n
  end
  if(d < 0) then
    sign = sign*-1
    d=-d
  end
  self.numerator=sign*(w*d+n)
  self.denominator=d
  self:reduce()
end

function Fraction.mt:set_fraction(value)
  local is_fraction = false
  local w,n,d
  w,n,d = value:match("^%s*([-+]?%d+)%s+([-+]?%d+)/([-+]?%d+)%s*$")
  if w and n and d then
    self:set_mixed(tonumber(w),tonumber(n),tonumber(d))
    is_fraction = true
  else
    n,d = value:match("^%s*([-+]?%d+)/([-+]?%d+)%s*$")
    if n and d then
      self.numerator=tonumber(n)
      self.denominator=tonumber(d)
      self:reduce()
      is_fraction = true
    end
  end
  return is_fraction
end

function Fraction.mt:set_number(value)
  local hm2=0
  local hm1=1
  local h=0
  local km2=1
  local km1=0
  local k=0
  local v = value
  Fraction.loops = 0
  while(true) do
    local a = to_i(v)
    h=a*hm1 + hm2
    k=a*km1 + km2
    if(math.abs(value - h/k) < Fraction.epsilon) then
      break
    end
    v = 1.0/(v -a)
    hm2=hm1
    hm1=h
    km2=km1
    km1=k
    Fraction.loops = Fraction.loops + 1
  end
  if(k < 0) then
    k=-k
    h=-h
  end
  self.numerator=h
  self.denominator=k
end

function Fraction.mt:set_string(value)
  local ok = false
  local value_as_number=tonumber(value)
  if value_as_number then
    ok = true
    self:set_number(value_as_number)
  else
    ok = self:set_fraction(value)
  end
  return ok
end

function Fraction.mt:set(...)
  local args = {...}
  local nargs = #args
  if(nargs == 0) then
    self.numerator=0
    self.denominator=1
  elseif(nargs == 1) then
    if isa(args[1],Fraction) then
      self.numerator=args[1].numerator
      self.denominator=args[1].denominator
    elseif type(args[1]) == "table"  then
      self:set(table.unpack(args[1]))
    elseif(type(args[1])=="number") then
      self:set_number(args[1])
    elseif(type(args[1])=="string") then
      if not self:set_string(args[1]) then
        -- error
      end
    end
  elseif(nargs==2) then
    self.numerator=to_i(args[1])
    self.denominator=to_i(args[2])
    self:reduce()
  elseif(nargs==3) then
    self:set_mixed(args[1],args[2],args[3])
  else
    -- error
  end
  return self
end

function Fraction.mt:round(d)
  local f_new = fraction_of_same_type(self,self.numerator,self.denominator)
--  setmetatable(f_new,mt)
  d=math.abs(d)
  if(d < self.denominator) then
    f_new.numerator = round((f_new.numerator*d/f_new.denominator))
    f_new.denominator = d
    f_new:reduce()
  end
  return f_new
end

function Fraction.mt:abs()
  local fnew = fraction_of_same_type(self,self)
  fnew.numerator = math.abs(fnew.numerator)
  return fnew
end

function Fraction.mt:tonumber()
  return self.numerator/self.denominator
end

local function value_to_fraction(value)
  if isa(value,Fraction) then
    -- Already a fraction
    return value
  end
  if type(value) == "number" then
    return Fraction:new(value)
  end
  return nil
end

function Fraction.mt:__add(o)
  local result = nil
  if isa(self,Fraction) then
    local rhs = value_to_fraction(o)
    if rhs then
      result = fraction_of_same_type(self,self.numerator*rhs.denominator+rhs.numerator*self.denominator,self.denominator*rhs.denominator)
    end
  elseif (type(self) == "number") then
    result = self + o.numerator/o.denominator
  end
  return result
end

function Fraction.mt:__sub(o)
  local result = nil
  if isa(self,Fraction) then
    local rhs = value_to_fraction(o)
    if rhs then
      result = fraction_of_same_type(self,self.numerator*rhs.denominator-rhs.numerator*self.denominator,self.denominator*rhs.denominator)
    end
  elseif (type(self) == "number") then
    result = self - o.numerator/o.denominator
  end
  return result
end

function Fraction.mt:__mul(o)
  local result = nil
  if isa(self,Fraction) then
    local rhs = value_to_fraction(o)
    if rhs then
      result = fraction_of_same_type(self,self.numerator*rhs.numerator,self.denominator*rhs.denominator)
    end
  elseif (type(self) == "number") then
    result = self * o.numerator/o.denominator
  end
  return result
end

function Fraction.mt:__div(o)
  local result = nil
  if isa(self,Fraction) then
    local rhs = value_to_fraction(o)
    if rhs then
      result = fraction_of_same_type(self,self.numerator*rhs.denominator,rhs.numerator*self.denominator)
    end
  elseif (type(self) == "number") then
    result = self / o.numerator/o.denominator
  end
  return result
end

function Fraction.mt:__idiv(o)
  local result = nil
  if isa(self,Fraction) then
    local rhs = value_to_fraction(o)
    if rhs then
      result = self / rhs
      result.numerator=math.floor(result.numerator/result.denominator)
      result.denominator=1
    end
  elseif (type(self) == "number") then
    result = self // (o.numerator/o.denominator)
  end
  return result
end

local function fraction_to_number(value)
  if isa(value,Fraction) then
    return value.numerator/value.denominator
  end
  if type(value) =="number" then
    return value
  end
  return nil
end

function Fraction.mt:__pow(o)
  local result = nil
  local b = fraction_to_number(self)
  local e = fraction_to_number(o)
  if b < 0 then
    if to_i(e) ~= e then
      -- error
    end
  end
  result = b ^ math.abs(e)
  if e < 0 then
    result = 1.0/result
  end
  if isa(self,Fraction) then
    local temp = fraction_of_same_type(self,self)
    result = temp:set(result)
  end
  return result
end

function Fraction.mt:__unm(o)
  result = fraction_of_same_type(self,self)
  result.numerator = -result.numerator
  return result
end

function Fraction.mt:__len()
  return self.numerator/self.denominator
end

local function fraction_cmp_fraction(lhs,rhs)
  local l = lhs.numerator*rhs.denominator
  local r = rhs.numerator*lhs.denominator
  if l < r then
    return -1
  end
  if l > r then
    return 1
  end
  return 0
end

function Fraction.mt:__eq(o)
  print(self.numerator,self.denominator,o)
  return fraction_cmp_fraction(value_to_fraction(self),value_to_fraction(o)) == 0
end

function Fraction.mt:__lt(o)
  return fraction_cmp_fraction(value_to_fraction(self),value_to_fraction(o)) < 0
end

function Fraction.mt:__le(o)
  return fraction_cmp_fraction(value_to_fraction(self),value_to_fraction(o)) <= 0
end

function Fraction.mt:__tostring()
  s=string.format("%d",self.numerator)
  if(self.denominator ~= 1) then
    s=s..string.format("/%d",self.denominator)
  end
  return s
end

MixedFraction = {  __name = "MixedFraction" , __index = Fraction }
MixedFraction.mt = {  }
MixedFraction.mt.__index = Fraction.mt

function MixedFraction.mt:__tostring()
  s=nil
  if(math.abs(self.numerator) > self.denominator and self.denominator ~= 1) then
    w = to_i(self.numerator/self.denominator)
    n = math.abs(self.numerator) - math.abs(w)*self.denominator
    s = string.format("%d %d/%d",w,n,self.denominator)
  else
    s=Fraction.mt.__tostring(self)
  end
  return s
end

local fraction_metamethods_to_inherit = {
      "__lt",
      "__div",
      "__mul",
      "__eq",
      "__tostring",
      "__len",
      "__le",
      "__unm",
      "__idiv",
      "__add",
      "__pow",
      "__sub"
}

inherit(MixedFraction,Fraction,fraction_metamethods_to_inherit)
setmetatable(MixedFraction,Fraction)

function MixedFraction.new(self,...)
  o = Fraction:new(...)
  setmetatable(o,MixedFraction.mt)
  return o
end
