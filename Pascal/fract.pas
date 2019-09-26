unit fract;
interface
uses sysutils;

type
  Fraction = object
  private
    _numerator,_denominator : longint;
    procedure reduce();
  public
    function numerator: longint;
    function denominator: longint;
    constructor new;
    procedure setNum(num: longint );
    procedure setNumDenom(num,denom: longint);
    procedure setMixed(whole,num,denom: longint);
    procedure setReal(d: real);
    procedure plus(f: Fraction);
    procedure minus(f: Fraction);
    procedure times(f: Fraction);
    procedure divided_by(f: Fraction);
    function Round(denom: longint): Fraction;
    function ToStr: string;
    function ToMixedStr: string;
end;

function gcd(a,b: longint): longint;
function fraction_plus_fraction(lhs,rhs: Fraction): Fraction;
function fraction_minus_fraction(lhs,rhs: Fraction): Fraction;
function fraction_times_fraction(lhs,rhs: Fraction): Fraction;
function fraction_divided_by_fraction(lhs,rhs: Fraction): Fraction;
function fraction_eq_fraction(lhs,rhs : Fraction): boolean;
function fraction_ne_fraction(lhs,rhs : Fraction): boolean;
function fraction_lt_fraction(lhs,rhs : Fraction): boolean;
function fraction_le_fraction(lhs,rhs : Fraction): boolean;
function fraction_gt_fraction(lhs,rhs : Fraction): boolean;
function fraction_ge_fraction(lhs,rhs : Fraction): boolean;
var
  loops: longint;
Implementation

var
  epsilon: real = 5e-7;

function Fraction.numerator: longint;
  begin
    numerator := _numerator;
  end;

function Fraction.denominator: longint;
  begin
     denominator := _denominator;
  end;

procedure Fraction.reduce();
  var
    divisor: longint;
begin
  if _denominator < 0 then
  begin
    _numerator := -_numerator;
    _denominator := -_denominator;
  end;

  divisor := gcd(abs(_numerator),_denominator);
  if divisor <> 1  then
  begin
    _numerator := _numerator div divisor;
    _denominator := _denominator div divisor;
  end;
end;

function gcd(a,b: longint): longint;
  var
    t: longint;
begin
  while (b <> 0) do
  begin
    t := b;
    b := a mod b;
    a := t;
  end;
  gcd := a;
end;

constructor Fraction.new();
begin
  _numerator := 0;
  _denominator := 1;
end;

procedure Fraction.setNum(num: longint);
begin
  _numerator := num;
  _denominator := 1;
end;

procedure Fraction.setNumDenom(num,denom: longint);
begin
  _numerator := num;
  _denominator := denom;
  Reduce();
end;

procedure Fraction.setMixed(whole,num,denom: longint);
begin
  if whole < 0 then
    _numerator := whole*denom-num
  else
    _numerator := whole*denom+num;
  _denominator := denom;
  Reduce();
end;

procedure Fraction.setReal(d: real);
var
  a,hm2,hm1,h,km2,km1,k: longint;
  v: real;
begin
  hm2:=0; hm1:=1; km2:=1; km1:=0;
  v:=d;
  loops := 0;
  while true do
  begin
    a:=trunc(v);
    h:= a*hm1 + hm2;
    k:=a*km1 + km2;
    if (abs(d - h/k) < epsilon) then
      break;
    loops := loops + 1;
    v := 1.0/(v - a);
    hm2:=hm1;
    hm1:=h;
    km2:=km1;
    km1:=k;
  end;
  if(k<0) then
  begin
    k := -k;
    h := -h;
  end;
  _numerator:=h;
  _denominator:=k;
end;

function Fraction.Round(denom: longint): Fraction;
begin
  Round.setNumDenom(trunc(denom*_numerator/_denominator + 0.5),denom);
end;

function fraction_plus_fraction(lhs,rhs: Fraction): Fraction;
  begin
    fraction_plus_fraction := lhs;
    fraction_plus_fraction.plus(rhs);
  end;

function fraction_minus_fraction(lhs,rhs: Fraction): Fraction;
  begin
    fraction_minus_fraction := lhs;
    fraction_minus_fraction.minus(rhs);
  end;

function fraction_times_fraction(lhs,rhs: Fraction): Fraction;
  begin
    fraction_times_fraction := lhs;
    fraction_times_fraction.times(rhs);
  end;

function fraction_divided_by_fraction(lhs,rhs: Fraction): Fraction;
  begin
    fraction_divided_by_fraction := lhs;
    fraction_divided_by_fraction.divided_by(rhs);
  end;

procedure Fraction.plus(f: Fraction);
  begin
    SetNumDenom(_numerator*f._denominator + f._numerator*_denominator,_denominator*f._denominator);
  end;

procedure Fraction.minus(f: Fraction);
  begin
    SetNumDenom(_numerator*f._denominator - f._numerator*_denominator,_denominator*f._denominator);
  end;

procedure Fraction.times(f: Fraction);
  begin
    SetNumDenom(_numerator*f._numerator,_denominator*f._denominator);
  end;

procedure Fraction.divided_by(f: Fraction);
  begin
    SetNumDenom(_numerator*f._denominator,f._numerator*_denominator);
  end;

function Fraction.ToStr: string;
begin
  if _denominator = 1 then
    ToStr := Format('%d',[_numerator])
  else
    ToStr := Format('%d/%d',[_numerator,_denominator]);
end;

function Fraction.ToMixedStr: string;
var
  whole,num: longint;
begin
  whole := trunc(_numerator/_denominator);
  if whole = 0 then
    ToMixedStr := ToStr
  else
    begin
      num := _numerator - whole*_denominator;
      if num = 0 then
        ToMixedStr := format('%d',[whole])
      else
        ToMixedStr := format('%d %d/%d',[whole,num,_denominator]);
    end;
end;

function cmp(lhs,rhs: Fraction): integer;
begin
  cmp := lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator;
end;

function fraction_eq_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_eq_fraction := cmp(lhs,rhs) = 0;
  end;

function fraction_ne_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_ne_fraction := cmp(lhs,rhs) <> 0;
  end;

function fraction_lt_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_lt_fraction := cmp(lhs,rhs) < 0;
  end;

function fraction_le_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_le_fraction := cmp(lhs,rhs) <= 0;
  end;

function fraction_gt_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_gt_fraction := cmp(lhs,rhs) > 0;
  end;

function fraction_ge_fraction(lhs,rhs : Fraction): boolean;
  begin
    fraction_ge_fraction := cmp(lhs,rhs) >= 0;
  end;

end.
