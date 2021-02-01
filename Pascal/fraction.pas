(*
		Copyright (C) 2019-2021  by Terry N Bezue

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
*)

unit fraction;
interface
uses sysutils,math;

type TFraction = object
  private
    _numerator,_denominator : longint;
//    _epsilon: real; static;
    procedure reduce();
  public
    function epsilon: real; static;
    procedure epsilon(e: real); static;
    function gcd(a,b: longint): longint; static;
    function numerator: longint;
    function denominator: longint;
(*    constructor create; overload;
    constructor create(n: longint); overload;
    constructor create(n,d: longint); overload;
    constructor create(w,n,d: longint); overload;
    constructor create(r: real); overload;
    constructor create(s: string); overload; *)
    procedure fset(num: longint ); overload;
    procedure fset(num,denom: longint); overload;
    procedure fset(whole,num,denom: longint); overload;
    procedure fset(d: real); overload;
    function Round(denom: longint): TFraction;
//    function ToStr: string;
//    function ToMixedStr: string;
end;

type TMixedFraction = object(TFraction)
end;

type
  PFraction = ^TFraction;
  PMixedFraction = ^TMixedFraction;

operator := (r: real) f:TFraction;
operator := (a: array of longint) f: TFraction;

operator := (r: real) mf: TMixedFraction;
operator := (a: array of longint) f: TMixedFraction;
operator := (f: TFraction) mf: TMixedFraction;

operator = (lhs,rhs: TFraction) b : boolean;
operator <> (lhs,rhs: TFraction) b : boolean;
operator < (lhs,rhs: TFraction) b : boolean;
operator <= (lhs,rhs: TFraction) b : boolean;
operator > (lhs,rhs: TFraction) b : boolean;
operator >= (lhs,rhs: TFraction) b : boolean;

operator = (lhs: TFraction; rhs: real) b : boolean;
operator <> (lhs: TFraction; rhs: real) b : boolean;
operator < (lhs: TFraction; rhs: real) b : boolean;
operator <= (lhs: TFraction; rhs: real) b : boolean;
operator > (lhs: TFraction; rhs: real) b : boolean;
operator >= (lhs: TFraction; rhs: real) b : boolean;

operator + (lhs,rhs: TFraction) f: TFraction;
operator - (lhs,rhs: TFraction) f: TFraction;
operator * (lhs,rhs: TFraction) f: TFraction;
operator / (lhs,rhs: TFraction) f: TFraction;
operator ** (lhs,rhs: TFraction) f: TFraction;

operator + (lhs: TFraction; rhs: real) f: TFraction;
operator - (lhs: TFraction; rhs: real) f: TFraction;
operator * (lhs: TFraction; rhs: real) f: TFraction;
operator / (lhs: TFraction; rhs: real) f: TFraction;
operator ** (lhs: TFraction; rhs: real) f: TFraction;

operator + (lhs: real; rhs: TFraction) r: real;
operator - (lhs: real; rhs: TFraction) r: real;
operator * (lhs: real; rhs: TFraction) r: real;
operator / (lhs: real; rhs: TFraction) r: real;
operator ** (lhs: real; rhs: TFraction) r: real;

operator explicit (f: TFraction) s: string;
operator explicit (mf: TMixedFraction) s: string;

var
  loops: longint;
  _epsilon: real = 5e-6;

Implementation

function TFraction.gcd(a,b: longint): longint; static;
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

function TFraction.epsilon: real; static;
  begin
    epsilon := _epsilon;
  end;

procedure TFraction.epsilon(e: real); static;
  begin
    _epsilon := e;
  end;

function TFraction.numerator: longint;
  begin
    numerator := _numerator;
  end;

function TFraction.denominator: longint;
  begin
     denominator := _denominator;
  end;

procedure TFraction.reduce();
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
(*
constructor TFraction.create();
  begin
    self._numerator := 0;
    self._denominator := 1;
  end;

constructor TFraction.create(n: longint);
  begin
    _numerator := n;
    _denominator := 1;
  end;


constructor TFraction.create(n,d: longint);
  begin
    fset(n,d);
  end;

constructor TFraction.create(w,n,d: longint);
  begin
    fset(w,n,d);
  end;

constructor TFraction.create(r: real);
  begin
    fset(r);
  end;

constructor TFraction.create(s:string);
  begin;
  end;
*)
procedure TFraction.fset(num: longint);
begin
  _numerator := num;
  _denominator := 1;
end;

procedure TFraction.fset(num,denom: longint);
begin
  _numerator := num;
  _denominator := denom;
  Reduce();
end;

procedure TFraction.fset(whole,num,denom: longint);
  var
    sign: longint;
begin
  sign := 1;
  if whole < 0 then
  begin
    sign := -sign;
    whole := -whole;
  end;
  if num < 0 then
  begin
    sign := -sign;
    num := -num;
  end;
  if denom < 0 then
  begin
    sign := -sign;
    denom := -denom;
  end;
  fset(sign*(whole*denom+num),denom);
end;

procedure TFraction.fset(d: real);
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
    if (abs(d - h/k) < _epsilon) then
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

function TFraction.Round(denom: longint): TFraction;
begin
  Round.fset(trunc(denom*_numerator/_denominator + 0.5),denom);
end;

operator + (lhs,rhs: TFraction) f: TFraction;
  begin
    f.fset(lhs._numerator*rhs._denominator + rhs._numerator*lhs._denominator,lhs._denominator*rhs._denominator);
  end;

operator - (lhs,rhs: TFraction) f: TFraction;
  begin
    f.fset(lhs._numerator*rhs._denominator - rhs._numerator*lhs._denominator,lhs._denominator*rhs._denominator);
  end;


operator * (lhs,rhs: TFraction) f: TFraction;
  begin
    f.fset(lhs._numerator*rhs._numerator,lhs._denominator*rhs._denominator);
  end;


operator / (lhs,rhs: TFraction) f: TFraction;
  begin
    f.fset(lhs._numerator*rhs._denominator,lhs._denominator*rhs._numerator);
  end;

operator ** (lhs,rhs: TFraction) f: TFraction;
  begin
    f := (lhs._numerator/lhs._denominator)**(rhs._numerator/rhs._denominator);
  end;

operator + (lhs: TFraction; rhs: real) f: TFraction;
  var
    frhs: TFraction;
  begin
    frhs.fset(rhs);
    f := lhs + frhs;
  end;

operator - (lhs: TFraction; rhs: real) f: TFraction;
  var
    frhs: TFraction;
  begin
    frhs.fset(rhs);
    f := lhs - frhs;
  end;

operator * (lhs: TFraction; rhs: real) f: TFraction;
  var
    frhs: TFraction;
  begin
    frhs.fset(rhs);
    f := lhs * frhs;
  end;

operator / (lhs: TFraction; rhs: real) f: TFraction;
  var
    frhs: TFraction;
  begin
    frhs.fset(rhs);
    f := lhs / frhs;
  end;

operator ** (lhs: TFraction; rhs: real) f: TFraction;
  var
    frhs: TFraction;
  begin
    frhs.fset(rhs);
    f := lhs ** frhs;
  end;

operator + (lhs: real; rhs: TFraction) r: real;
  begin
    r := lhs + rhs.numerator/rhs.denominator;
  end;

operator - (lhs: real; rhs: TFraction) r: real;
  begin
    r := lhs - rhs.numerator/rhs.denominator;
  end;

operator * (lhs: real; rhs: TFraction) r: real;
  begin
    r := lhs * rhs.numerator/rhs.denominator;
  end;

operator / (lhs: real; rhs: TFraction) r: real;
  begin
    r := lhs*rhs.denominator/rhs.numerator;
  end;

operator ** (lhs: real; rhs: TFraction) r: real;
  begin
    r := lhs ** (rhs.numerator/rhs.denominator);
  end;

(*
function TFraction.ToStr: string;
begin
  if _denominator = 1 then
    ToStr := Format('%d',[_numerator])
  else
    ToStr := Format('%d/%d',[_numerator,_denominator]);
end;
*)
operator explicit(f: TFraction) s: string;
  begin
    if f.denominator = 1 then
      s := Format('%d',[f.numerator])
    else
      s := Format('%d/%d',[f.numerator,f.denominator]);
  end;
(*
function TFraction.ToMixedStr: string;
var
  whole,num: longint;
begin
  if (_denominator <> 1) or (abs(_numerator) > _denominator) then
  begin
    whole := trunc(_numerator/_denominator);
    num := abs(_numerator) - abs(whole)*_denominator;
    ToMixedStr := format('%d %d/%d',[whole,num,_denominator]);
  end
  else
    ToMixedStr := ToStr();
end;
*)
function cmp(lhs,rhs: TFraction): integer;
begin
  cmp := lhs.numerator*rhs.denominator - rhs.numerator*lhs.denominator;
end;

operator = (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) = 0;
  end;

operator <> (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) <> 0;
  end;

operator < (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) < 0;
  end;

operator <= (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) <= 0;
  end;

operator > (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) > 0;
  end;

operator >= (lhs,rhs : TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) >= 0;
  end;

function cmp(lhs: TFraction; rhs:real): integer;
  var
    frhs: TFraction;
  begin
    frhs := rhs;
    cmp := cmp(lhs,frhs);
  end;

operator = (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) = 0;
  end;

operator <> (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) <> 0;
  end;

operator < (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) < 0;
  end;

operator <= (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) <= 0;
  end;

operator > (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) > 0;
  end;

operator >= (lhs: TFraction; rhs: real) b: boolean;
  begin
    b := cmp(lhs,rhs) >= 0;
  end;

function cmp(lhs: real; rhs:TFraction): integer;
  var
    rrhs: real;
begin
  rrhs := rhs.numerator/rhs.denominator;
  if abs(lhs - rrhs) < _epsilon then
    cmp := 0
  else
    if lhs < rrhs then
      cmp := -1
    else
      cmp := 1;
end;

operator = (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) = 0;
  end;

operator <> (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) <> 0;
  end;

operator < (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) < 0;
  end;

operator <= (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) <= 0;
  end;

operator > (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) > 0;
  end;

operator >= (lhs: real; rhs: TFraction) b: boolean;
  begin
    b := cmp(lhs,rhs) >= 0;
  end;

operator := (r: real) f:TFraction;
  begin
    f.fset(r);
  end;

operator := (a: array of longint) f: TFraction;
  var
    alen: longint;
    ilow: longint;
  begin
    alen := length(a);
    ilow := low(a);
    case alen of
      0: f.fset(0,1);
      1: f.fset(a[ilow]);
      2: f.fset(a[ilow],a[ilow+1]);
    else
      f.fset(a[ilow],a[ilow+1],a[ilow+2]);
    end;
  end;

operator := (r: real) mf:TMixedFraction;
  begin
    mf.fset(r);
  end;

operator := (a: array of longint) f: TMixedFraction;
  var
    alen: longint;
    ilow: longint;
  begin
    alen := length(a);
    ilow := low(a);
    case alen of
      0: f.fset(0,1);
      1: f.fset(a[ilow]);
      2: f.fset(a[ilow],a[ilow+1]);
    else
      f.fset(a[ilow],a[ilow+1],a[ilow+2]);
    end;
  end;

operator := (f: TFraction) mf: TMixedFraction;
  begin
    mf.fset(f.numerator,f.denominator);
  end;

operator explicit(mf: TMixedFraction) s: string;
  var
    whole,num: longint;
  begin
    if mf.denominator = 1 then
      s := Format('%d',[mf.numerator])
    else
      if abs(mf.numerator) < mf.denominator then
        s:= Format('%d/%d',[mf.numerator,mf.denominator])
      else
        begin
          whole := trunc(mf.numerator/mf.denominator);
          num := abs(mf.numerator) - abs(whole)*mf.denominator;
          s := format('%d %d/%d',[whole,num,mf.denominator]);
        end;
    end;
end.
