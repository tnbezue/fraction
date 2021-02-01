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

(*
  To compile using normal fractions:
    fpc -MObjFPC test_fraction.pas

  To compile using mixed fractions:
    fpc -MObjFPC -dMIXED test_fraction.pas
*)
program HelloWorld;
uses fraction,crt,test_harness,sysutils;

{$ifdef MIXED}
type
  fraction_type = TMixedFraction;
{$else}
type
  fraction_type = TFraction;
{$endif}

procedure test_gcd;
  type
    III = record
      a,b,r: longint;
    end;
  var
    td: III;
    msg: string;
    rc: boolean;
    test_data: array of III = (
      ( a:0;b:2;r:2),
      ( a:10;b:1;r:1),
      ( a:105;b:15;r:15),
      ( a:10;b:230;r:10),
      ( a:28;b:234;r:2),
      ( a:872452914;b:78241452;r:6 )
    );

  begin
    TestCase('Greatest Common Divisor');
    for td in test_data do
    begin
      msg := Format('gcd(%d,%d)=%d',[td.a,td.b,td.r]);
      rc := fraction_type.gcd(td.a,td.b)=td.r;
      Test(msg,rc);
    end;
  end;

function R(f: fraction_type; n,d: longint): boolean;
  begin
    R := (f.numerator = n) and (f.denominator = d);
  end;

procedure test_set_num;
  type
    III = record
      n1,n2,d2: longint;
    end;
  var
    msg: string;
    rc: boolean;
    td: III;
    test_data: array of III = (
        ( n1:0;n2:0;d2:1 ),
        (n1:1;n2:1;d2:1),
        (n1:-2;n2:-2;d2:1),
        (n1:-12;n2:-12;d2:1),
        (n1:12;n2:12;d2:1)
    );
    f: fraction_type;

  begin
    TestCase('Set Numerator');
    for td in test_data do
    begin
      msg := Format('fset(%d) = (%d/%d)',[td.n1,td.n2,td.d2]);
      f.fset(td.n1);
      rc := R(f,td.n2,td.d2);
      Test(msg,rc);
    end;
  end;

type
  IIII = record
    n1,d1,n2,d2: longint;
  end;

procedure test_set_num_denom;
  var
    msg: string;
    rc: boolean;
    test_data: array of IIII = (
        (n1:0;d1:1;n2:0;d2:1),
        (n1:1;d1:1;n2:1;d2:1),
        (n1:-2;d1:3;n2:-2;d2:3),
        (n1:2;d1:-3;n2:-2;d2:3),
        (n1:-2;d1:-3;n2:2;d2:3),
        (n1:-12;d1:3;n2:-4;d2:1),
        (n1:100;d1:200;n2:1;d2:2)
    );
    f: fraction_type;
    td: IIII;
  begin
    TestCase('Set Numerator and Denominator');
    for td in test_data do
    begin
      msg := Format('fset(%d,%d) = (%d/%d)',[td.n1,td.d1,td.n2,td.d2]);
      f.fset(td.n1,td.d1);
      rc := R(f,td.n2,td.d2);
      Test(msg,rc);
    end
  end;

  type
    IIIII = record
      w,n1,d1,n2,d2: longint;
    end;

  procedure test_set_mixed;
  var
    msg: string;
    rc: boolean;
    test_data: array of IIIII = (
        ( w:-10;n1:-2;d1:-3;n2:-32;d2:3 ),
        (w:0;n1:-2;d1:3;n2:-2;d2:3),
        (w:0;n1:0;d1:1;n2:0;d2:1),
        (w:0;n1:2;d1:3;n2:2;d2:3),
        (w:10;n1:2;d1:3;n2:32;d2:3)
    );
    f: fraction_type;
    td: IIIII;

  begin
    TestCase('Set Mixed');
    for td in test_data do
    begin
      msg := Format('fset(%d,%d,%d) = (%d/%d)',[td.w,td.n1,td.d1,td.n2,td.d2]);
      f.fset(td.w,td.n1,td.d1);
      rc := R(f,td.n2,td.d2);
      Test(msg,rc);
    end
  end;

  type
    RII = record
      r: real;
      n,d: longint;
    end;
  procedure test_set_real;
  var
    msg: string;
    rc: boolean;
    test_data: array of RII = (
        ( r:-12.25;n:-49;d:4),
        ( r:-10.0;n:-10;d:1),
        ( r:-1.0;n:-1;d:1),
        ( r:-0.25;n:-1;d:4),
        ( r:0.0;n:0;d:1),
        ( r:0.25;n:1;d:4),
        ( r:1.0;n:1;d:1),
        ( r:10.0;n:10;d:1),
        ( r:12.25;n:49;d:4),
        ( r:0.3;n:3;d:10),
        ( r:0.33;n:33;d:100),
        ( r:0.33333333;n:1;d:3)
    );
    f: fraction_type;
    td: RII;
  begin
    TestCase('Set Real');
    for td in test_data do
    begin
      msg := Format('fset(%.6g) = (%d/%d)',[td.r,td.n,td.d]);
      f.fset(td.r);
      rc := R(f,td.n,td.d);
      Test(msg,rc);
    end
  end;

  procedure test_assign_real;
  var
    msg: string;
    rc: boolean;
    test_data: array of RII = (
        ( r:-12.25;n:-49;d:4),
        ( r:-10.0;n:-10;d:1),
        ( r:-1.0;n:-1;d:1),
        ( r:-0.25;n:-1;d:4),
        ( r:0.0;n:0;d:1),
        ( r:0.25;n:1;d:4),
        ( r:1.0;n:1;d:1),
        ( r:10.0;n:10;d:1),
        ( r:12.25;n:49;d:4),
        ( r:0.3;n:3;d:10),
        ( r:0.33;n:33;d:100),
        ( r:0.33333333;n:1;d:3)
    );
    f: fraction_type;
    td: RII;
  begin
    TestCase('Assign Real');
    for td in test_data do
    begin
      msg := Format('f := %.6g : result = (%d/%d)',[td.r,td.n,td.d]);
      f := td.r;
      rc := R(f,td.n,td.d);
      Test(msg,rc);
    end
  end;

  procedure test_assign_array_with_one_element;
  type
    AII = record
      a: array[0..0] of longint;
      n,d: longint;
    end;
  var
    test_data: array of AII = (
      ( a:(0);n:0;d:1 ),
      ( a:(1);n:1;d:1),
      ( a:(-2);n:-2;d:1),
      ( a:(-12);n:-12;d:1),
      ( a:(12);n:12;d:1)
    );
    td: AII;
    msg: string;
    rc: boolean;
    f: fraction_type;
  begin
    TestCase('Assing array with one member');
    for td in test_data do
    begin
      msg := Format('f := (%d) : result = (%d/%d)',[td.a[0],td.n,td.d]);
      f := td.a;
      rc := R(f,td.n,td.d);
      Test(msg,rc);
    end;
  end;

  procedure test_assign_array_with_two_elements;
  type
    AII = record
      a: array[0..1] of longint;
      n,d: longint;
    end;
  var
    test_data: array of AII = (
      ( a:(0,1);n:0;d:1 ),
      ( a:(1,1);n:1;d:1),
      ( a:(-2,3);n:-2;d:3),
      ( a:(2,-3);n:-2;d:3),
      ( a:(-2,-3);n:2;d:3),
      ( a:(-12,3);n:-4;d:1),
      ( a:(100,200);n:1;d:2)
    );
    td: AII;
    msg: string;
    rc: boolean;
    f: fraction_type;
  begin
    TestCase('Assing array with two members');
    for td in test_data do
    begin
      msg := Format('f := (%d,%d) : result = (%d/%d)',[td.a[0],td.a[1],td.n,td.d]);
      f := td.a;
      rc := R(f,td.n,td.d);
      Test(msg,rc);
    end;
  end;

procedure test_assign_array_with_three_elements;
  type
    AII = record
      a: array[3..5] of longint;
      n,d: longint;
    end;
  var
    test_data: array of AII = (
      ( a:(-10,-2,-3);n:-32;d:3 ),
      ( a:(0,-2,3);n:-2;d:3),
      ( a:(0,0,1);n:0;d:1),
      ( a:(0,2,3);n:2;d:3),
      ( a:(10,2,3);n:32;d:3)
    );
    td: AII;
    msg: string;
    rc: boolean;
    f: fraction_type;
  begin
    TestCase('Assign array with three members');
    for td in test_data do
    begin
      msg := Format('f := (%d,%d,%d) : result = (%d/%d)',[td.a[3],td.a[4],td.a[5],td.n,td.d]);
      f := td.a;
      rc := R(f,td.n,td.d);
      Test(msg,rc);
    end;
  end;

  procedure test_cast_to_string;
    type
      IAS = record
        ia: array[0..1] of longint;
        s: string;
      end;
    var
{$ifdef MIXED}
      test_data: array of IAS = (
        ( ia:(3,1);s:'3' ),
        ( ia:(3,5);s:'3/5' ),
        ( ia:(-3,5);s:'-3/5' ),
        ( ia:(20,7);s:'2 6/7' ),
        ( ia:(-15,2);s:'-7 1/2' ),
        ( ia:(2,3);s:'2/3' )
      );
{$else}
      test_data: array of IAS = (
        ( ia:(3,1);s:'3' ),
        ( ia:(3,5);s:'3/5' ),
        ( ia:(-3,5);s:'-3/5' ),
        ( ia:(20,7);s:'20/7' ),
        ( ia:(-15,2);s:'-15/2' ),
        ( ia:(2,3);s:'2/3' )
      );
{$endif}
      td: IAS;
      msg: string;
      rc: boolean;
      f: fraction_type;
    begin
      TestCase('Fraction to string');
      for td in test_data do
      begin
        msg := Format('string((%d/%d)) = "%s"',[td.ia[0],td.ia[1],td.s]);
        f := td.ia;
        writeln(string(f));
        rc := string(f) = td.s;
        Test(msg,rc);
      end;
    end;

  type
    AAB = record
      f1: array[0..1] of longint;
      f2: array[0..1] of longint;
      result: boolean;
    end;
  procedure test_fraction_eq_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:true),
        ( f1:(0,1);f2:(1,2);result:false),
        ( f1:(2,3);f2:(-2,4);result:false),
        ( f1:(2,3);f2:(16,24);result:true),
        ( f1:(1,3);f2:(1,3);result:true),
        ( f1:(-5,7);f2:(25,35);result:false)
    );
    td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction equal fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) = (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 =f2) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_ne_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:false),
        ( f1:(0,1);f2:(1,2);result:true),
        ( f1:(2,3);f2:(-2,4);result:true),
        ( f1:(2,3);f2:(16,24);result:false),
        ( f1:(1,3);f2:(1,3);result:false),
        ( f1:(-5,7);f2:(25,35);result:true)
    );
    td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction not equal fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) <> (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 <> f2) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_lt_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:false),
        ( f1:(0,1);f2:(1,2);result:true),
        ( f1:(2,3);f2:(-2,4);result:false),
        ( f1:(2,3);f2:(16,24);result:false),
        ( f1:(1,3);f2:(1,3);result:false),
        ( f1:(-5,7);f2:(25,35);result:true)
    );
      td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction less than fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) < (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 < f2) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_le_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:true),
        ( f1:(0,1);f2:(1,2);result:true),
        ( f1:(2,3);f2:(-2,4);result:false),
        ( f1:(2,3);f2:(16,24);result:true),
        ( f1:(1,3);f2:(1,3);result:true),
        ( f1:(-5,7);f2:(25,35);result:true)
    );
    td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction less than or equal fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) <= (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 <= f2) = td.result;
      Test(msg,rc);
    end;

  end;

  procedure test_fraction_gt_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:false),
        ( f1:(0,1);f2:(1,2);result:false),
        ( f1:(2,3);f2:(-2,4);result:true),
        ( f1:(2,3);f2:(16,24);result:false),
        ( f1:(1,3);f2:(1,3);result:false),
        ( f1:(-5,7);f2:(25,35);result:false)
    );
    td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction greater than fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) > (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 > f2) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_ge_fraction;
  var
    test_data: array of AAB = (
        ( f1:(0,1);f2:(0,1);result:true),
        ( f1:(0,1);f2:(1,2);result:false),
        ( f1:(2,3);f2:(-2,4);result:true),
        ( f1:(2,3);f2:(16,24);result:true),
        ( f1:(1,3);f2:(1,3);result:true),
        ( f1:(-5,7);f2:(25,35);result:false)
    );
    td: AAB;
    msg: string;
    rc: boolean;
    f1,f2: fraction_type;

  begin
    TestCase('fraction greater than or equal to fraction');
//    f1 := (2,3);
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) >= (%s) -- %s',[string(f1),string(f2),BoolToStr(td.result,true)]);
      rc := (f1 >= f2) = td.result;
      Test(msg,rc);
    end;
  end;

  type
    ARB = record
      f: array[0..1] of longint;
      r: real;
      result: boolean;
    end;
  procedure test_fraction_eq_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:true),
        ( f:(0,1);r:(1/2);result:false),
        ( f:(2,3);r:(-2/4);result:false),
        ( f:(2,3);r:(16/24);result:true),
        ( f:(1,3);r:(1/3);result:true),
        ( f:(-5,7);r:(25/35);result:false)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction equal real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) = (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  = td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_ne_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:false),
        ( f:(0,1);r:(1/2);result:true),
        ( f:(2,3);r:(-2/4);result:true),
        ( f:(2,3);r:(16/24);result:false),
        ( f:(1,3);r:(1/3);result:false),
        ( f:(-5,7);r:(25/35);result:true)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction not equal real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) <> (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  <> td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_lt_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:false),
        ( f:(0,1);r:(1/2);result:true),
        ( f:(2,3);r:(-2/4);result:false),
        ( f:(2,3);r:(16/24);result:false),
        ( f:(1,3);r:(1/3);result:false),
        ( f:(-5,7);r:(25/35);result:true)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction less than real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) < (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  < td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_le_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:true),
        ( f:(0,1);r:(1/2);result:true),
        ( f:(2,3);r:(-2/4);result:false),
        ( f:(2,3);r:(16/24);result:true),
        ( f:(1,3);r:(1/3);result:true),
        ( f:(-5,7);r:(25/35);result:true)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction less than or equal real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) <= (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  <= td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_gt_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:false),
        ( f:(0,1);r:(1/2);result:false),
        ( f:(2,3);r:(-2/4);result:true),
        ( f:(2,3);r:(16/24);result:false),
        ( f:(1,3);r:(1/3);result:false),
        ( f:(-5,7);r:(25/35);result:false)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction greater than real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) > (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  > td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_fraction_ge_real;
  var
    test_data: array of ARB = (
        ( f:(0,1);r:(0/1);result:true),
        ( f:(0,1);r:(1/2);result:false),
        ( f:(2,3);r:(-2/4);result:true),
        ( f:(2,3);r:(16/24);result:true),
        ( f:(1,3);r:(1/3);result:true),
        ( f:(-5,7);r:(25/35);result:false)
    );
    td: ARB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('fraction greater than or equal to real');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%s) >= (%g) -- %s',[string(f),td.r,BoolToStr(td.result,true)]);
      rc := (f  >= td.r) = td.result;
      Test(msg,rc);
    end;
  end;

  type
    RAB = record
      r: real;
      f: array[0..1] of longint;
      result: boolean;
    end;
  procedure test_real_eq_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:true),
        ( r:(0/1);f:(1,2);result:false),
        ( r:(2/3);f:(-2,4);result:false),
        ( r:(2/3);f:(16,24);result:true),
        ( r:(1/3);f:(1,3);result:true),
        ( r:(-5/7);f:(25,35);result:false)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real equal fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) = (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r = f) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_real_ne_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:false),
        ( r:(0/1);f:(1,2);result:true),
        ( r:(2/3);f:(-2,4);result:true),
        ( r:(2/3);f:(16,24);result:false),
        ( r:(1/3);f:(1,3);result:false),
        ( r:(-5/7);f:(25,35);result:true)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real not equal fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) <> (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r <> f) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_real_lt_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:false),
        ( r:(0/1);f:(1,2);result:true),
        ( r:(2/3);f:(-2,4);result:false),
        ( r:(2/3);f:(16,24);result:false),
        ( r:(1/3);f:(1,3);result:false),
        ( r:(-5/7);f:(25,35);result:true)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real less than fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) < (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r < f) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_real_le_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:true),
        ( r:(0/1);f:(1,2);result:true),
        ( r:(2/3);f:(-2,4);result:false),
        ( r:(2/3);f:(16,24);result:true),
        ( r:(1/3);f:(1,3);result:true),
        ( r:(-5/7);f:(25,35);result:true)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real less than or equal to fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) <= (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r <= f) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_real_gt_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:false),
        ( r:(0/1);f:(1,2);result:false),
        ( r:(2/3);f:(-2,4);result:true),
        ( r:(2/3);f:(16,24);result:false),
        ( r:(1/3);f:(1,3);result:false),
        ( r:(-5/7);f:(25,35);result:false)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real greater than fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) > (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r > f) = td.result;
      Test(msg,rc);
    end;
  end;

  procedure test_real_ge_fraction;
  var
    test_data: array of RAB = (
        ( r:(0/1);f:(0,1);result:true),
        ( r:(0/1);f:(1,2);result:false),
        ( r:(2/3);f:(-2,4);result:true),
        ( r:(2/3);f:(16,24);result:true),
        ( r:(1/3);f:(1,3);result:true),
        ( r:(-5/7);f:(25,35);result:false)
    );
    td: RAB;
    msg: string;
    rc: boolean;
    f: fraction_type;

  begin
    TestCase('real greater than fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) >= (%s) -- %s',[td.r,string(f),BoolToStr(td.result,true)]);
      rc := (td.r >= f) = td.result;
      Test(msg,rc);
    end;
  end;

type
  FFF = record
    f1: array[0..1] of longint;
    f2: array[0..1] of longint;
    f3: array[0..1] of longint;
  end;
procedure test_fraction_plus_fraction;
  var
    test_data: array of FFF = (
        ( f1:(0,1);f2:(0,1);f3:(0,1) ),
        ( f1:(0,1);f2:(1,1);f3:(1,1) ),
        ( f1:(3,5);f2:(-2,9);f3:(17,45) ),
        ( f1:(-2,8);f2:(-6,8);f3:(-1,1) ),
        ( f1:(7,3);f2:(10,7);f3:(79,21) ),
        ( f1:(-5,7);f2:(25,35);f3:(0,1) )
    );
    msg: string;
    rc: boolean;
    f1,f2,f3,result: fraction_type;
    td: FFF;
  begin
    TestCase('fraction plus fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      f3 := td.f3;
      msg := Format('(%s) + (%s) = (%s)',[string(f1),string(f2),string(f3)]);
      result := f1 + f2;
      rc := f3 = result;
      Test(msg,rc);
    end
  end;

  procedure test_fraction_minus_fraction;
    var
      test_data: array of FFF = (
          ( f1:(0,1);f2:(0,1);f3:(0,1) ),
          ( f1:(0,1);f2:(1,1);f3:(-1,1) ),
          ( f1:(3,5);f2:(-2,9);f3:(37,45) ),
          ( f1:(-2,8);f2:(-6,8);f3:(1,2) ),
          ( f1:(7,3);f2:(10,7);f3:(19,21) ),
          ( f1:(-5,7);f2:(25,35);f3:(-10,7) )
      );
      msg: string;
      rc: boolean;
      f1,f2,f3,result: fraction_type;
      td: FFF;
    begin
      TestCase('fraction minus fraction');
      for td in test_data do
      begin
        f1 := td.f1;
        f2 := td.f2;
        f3 := td.f3;
        msg := Format('(%s) - (%s) = (%s)',[string(f1),string(f2),string(f3)]);
        result := f1 - f2;
        rc := f3 = result;
        Test(msg,rc);
      end
    end;

  procedure test_fraction_times_fraction;
    var
      test_data: array of FFF = (
          ( f1:(0,1);f2:(0,1);f3:(0,1) ),
          ( f1:(0,1);f2:(1,1);f3:(0,1) ),
          ( f1:(3,5);f2:(-2,9);f3:(-2,15) ),
          ( f1:(-2,8);f2:(-6,8);f3:(3,16) ),
          ( f1:(7,3);f2:(10,7);f3:(10,3) ),
          ( f1:(-5,7);f2:(25,35);f3:(-25,49) )
      );
      msg: string;
      rc: boolean;
      f1,f2,f3,result: fraction_type;
      td: FFF;
    begin
      TestCase('fraction times fraction');
      for td in test_data do
      begin
        f1 := td.f1;
        f2 := td.f2;
        f3 := td.f3;
        msg := Format('(%s) * (%s) = (%s)',[string(f1),string(f2),string(f3)]);
        result := f1 * f2;
        rc := f3 = result;
        Test(msg,rc);
      end
    end;

  procedure test_fraction_divided_by_fraction;
    var
      test_data: array of FFF = (
          ( f1:(0,1);f2:(1,1);f3:(0,1) ),
          ( f1:(3,5);f2:(-2,9);f3:(-27,10) ),
          ( f1:(-2,8);f2:(-6,8);f3:(1,3) ),
          ( f1:(7,3);f2:(10,7);f3:(49,30) ),
          ( f1:(-5,7);f2:(25,35);f3:(-1,1) )
      );
      msg: string;
      rc: boolean;
      f1,f2,f3,result: fraction_type;
      td: FFF;
    begin
      TestCase('fraction times fraction');
      for td in test_data do
      begin
        f1 := td.f1;
        f2 := td.f2;
        f3 := td.f3;
        msg := Format('(%s) / (%s) = (%s)',[string(f1),string(f2),string(f3)]);
        result := f1 / f2;
        rc := f3 = result;
        Test(msg,rc);
      end
    end;

  procedure test_fraction_power_fraction;
    var
      test_data: array of FFF = (
          ( f1:(0,1);f2:(1,1);f3:(0,1) ),
          ( f1:(3,5);f2:(-2,9);f3:(643,574) ),
          ( f1:(2,8);f2:(-3,4);f3:(577,204) ),
          ( f1:(7,3);f2:(10,7);f3:(1399,417) ),
          ( f1:(-5,7);f2:(3,1);f3:(-125,343) )
      );
      msg: string;
      rc: boolean;
      f1,f2,f3,result: fraction_type;
      td: FFF;
    begin
      TestCase('fraction to power of fraction');
      for td in test_data do
      begin
        f1 := td.f1;
        f2 := td.f2;
        f3 := td.f3;
        msg := Format('(%s) ** (%s) = (%s)',[string(f1),string(f2),string(f3)]);
        result := f1 ** f2;
        rc := f3 = result;
        Test(msg,rc);
      end
    end;

type
  FRF = record
    f1: array[0..1] of longint;
    r: real;
    f2: array[0..1] of longint;
  end;

procedure test_fraction_plus_real;
  var
    test_data: array of FRF = (
        ( f1:(0,1);r:(0/1);f2:(0,1) ),
        ( f1:(0,1);r:(1/1);f2:(1,1) ),
        ( f1:(3,5);r:(-2/9);f2:(17,45) ),
        ( f1:(-2,8);r:(-6/8);f2:(-1,1) ),
        ( f1:(7,3);r:(10/7);f2:(79,21) ),
        ( f1:(-5,7);r:(25/35);f2:(0,1) )
    );
    msg: string;
    rc: boolean;
    f1,f2,result: fraction_type;
    td: FRF;
  begin
    TestCase('fraction plus fraction');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) + (%g) = (%s)',[string(f1),td.r,string(f2)]);
      result := f1 + td.r;
      rc := f2 = result;
      Test(msg,rc);
    end
  end;

procedure test_fraction_minus_real;
  var
    test_data: array of FRF = (
        ( f1:(0,1);r:(0/1);f2:(0,1) ),
        ( f1:(0,1);r:(1/1);f2:(-1,1) ),
        ( f1:(3,5);r:(-2/9);f2:(37,45) ),
        ( f1:(-2,8);r:(-6/8);f2:(1,2) ),
        ( f1:(7,3);r:(10/7);f2:(19,21) ),
        ( f1:(-5,7);r:(25/35);f2:(-10,7) )
    );
    msg: string;
    rc: boolean;
    f1,f2,result: fraction_type;
    td: FRF;
  begin
    TestCase('fraction minus real');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) - (%g) = (%s)',[string(f1),td.r,string(f2)]);
      result := f1 - td.r;
      rc := f2 = result;
      Test(msg,rc);
    end
  end;

procedure test_fraction_times_real;
  var
    test_data: array of FRF = (
        ( f1:(0,1);r:(0/1);f2:(0,1) ),
        ( f1:(0,1);r:(1/1);f2:(0,1) ),
        ( f1:(3,5);r:(-2/9);f2:(-2,15) ),
        ( f1:(-2,8);r:(-6/8);f2:(3,16) ),
        ( f1:(7,3);r:(10/7);f2:(10,3) ),
        ( f1:(-5,7);r:(25/35);f2:(-25,49) )
    );
    msg: string;
    rc: boolean;
    f1,f2,result: fraction_type;
    td: FRF;
  begin
    TestCase('fraction times real');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) * (%g) = (%s)',[string(f1),td.r,string(f2)]);
      result := f1 * td.r;
      rc := f2 = result;
      Test(msg,rc);
    end
  end;

procedure test_fraction_divided_by_real;
  var
    test_data: array of FRF = (
        ( f1:(0,1);r:(1/1);f2:(0,1) ),
        ( f1:(3,5);r:(-2/9);f2:(-27,10) ),
        ( f1:(-2,8);r:(-6/8);f2:(1,3) ),
        ( f1:(7,3);r:(10/7);f2:(49,30) ),
        ( f1:(-5,7);r:(25/35);f2:(-1,1) )
    );
    msg: string;
    rc: boolean;
    f1,f2,result: fraction_type;
    td: FRF;
  begin
    TestCase('fraction divided by real');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) / (%g) = (%s)',[string(f1),td.r,string(f2)]);
      result := f1 / td.r;
      rc := f2 = result;
      Test(msg,rc);
    end
  end;

procedure test_fraction_power_real;
  var
    test_data: array of FRF = (
        ( f1:(0,1);r:(1/1);f2:(0,1) ),
        ( f1:(3,5);r:(-2/9);f2:(643,574) ),
        ( f1:(2,8);r:(-3/4);f2:(577,204) ),
        ( f1:(7,3);r:(10/7);f2:(1399,417) ),
        ( f1:(-5,7);r:(3/1);f2:(-125,343) )
    );
    msg: string;
    rc: boolean;
    f1,f2,result: fraction_type;
    td: FRF;
  begin
    TestCase('fraction to power of real');
    for td in test_data do
    begin
      f1 := td.f1;
      f2 := td.f2;
      msg := Format('(%s) ** (%g) = (%s)',[string(f1),td.r,string(f2)]);
      result := f1 ** td.r;
      rc := f2 = result;
      Test(msg,rc);
    end
  end;

type
  RFR = record
    r: real;
    f: array[0..1] of longint;
    result: real;
  end;
procedure test_real_plus_fraction;
  var
    test_data: array of RFR = (
        ( r:(0/1);f:(0,1);result:(0/1) ),
        ( r:(0/1);f:(1,1);result:(1/1) ),
        ( r:(3/5);f:(-2,9);result:(17/45) ),
        ( r:(-2/8);f:(-6,8);result:(-1/1) ),
        ( r:(7/3);f:(10,7);result:(79/21) ),
        ( r:(-5/7);f:(25,35);result:(0/1) )
    );
    msg: string;
    rc: boolean;
    f: fraction_type;
    td: RFR;
  begin
    TestCase('real plus fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) + (%s) = (%g)',[td.r,string(f),td.result]);
      rc := abs((td.r + f) - td.result) < fraction_type.epsilon;
      Test(msg,rc);
    end
  end;

procedure test_real_minus_fraction;
  var
    test_data: array of RFR = (
        ( r:(0/1);f:(0,1);result:(0/1) ),
        ( r:(0/1);f:(1,1);result:(-1/1) ),
        ( r:(3/5);f:(-2,9);result:(37/45) ),
        ( r:(-2/8);f:(-6,8);result:(1/2) ),
        ( r:(7/3);f:(10,7);result:(19/21) ),
        ( r:(-5/7);f:(25,35);result:(-10/7) )
    );
    msg: string;
    rc: boolean;
    f: fraction_type;
    td: RFR;
  begin
    TestCase('real minus fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) - (%s) = (%g)',[td.r,string(f),td.result]);
      rc := abs((td.r - f) - td.result) < fraction_type.epsilon;
      Test(msg,rc);
    end
  end;

procedure test_real_times_fraction;
  var
    test_data: array of RFR = (
        ( r:(0/1);f:(0,1);result:(0/1) ),
        ( r:(0/1);f:(1,1);result:(0/1) ),
        ( r:(3/5);f:(-2,9);result:(-2/15) ),
        ( r:(-2/8);f:(-6,8);result:(3/16) ),
        ( r:(7/3);f:(10,7);result:(10/3) ),
        ( r:(-5/7);f:(25,35);result:(-25/49) )
    );
    msg: string;
    rc: boolean;
    f: fraction_type;
    td: RFR;
  begin
    TestCase('real times fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) * (%s) = (%g)',[td.r,string(f),td.result]);
      rc := abs((td.r * f) - td.result) < fraction_type.epsilon;
      Test(msg,rc);
    end
  end;

procedure test_real_divided_by_fraction;
  var
    test_data: array of RFR = (
        ( r:(0/1);f:(1,1);result:(0/1) ),
        ( r:(3/5);f:(-2,9);result:(-27/10) ),
        ( r:(-2/8);f:(-6,8);result:(1/3) ),
        ( r:(7/3);f:(10,7);result:(49/30) ),
        ( r:(-5/7);f:(25,35);result:(-1/1) )
    );
    msg: string;
    rc: boolean;
    f: fraction_type;
    td: RFR;
  begin
    TestCase('real divided by fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) / (%s) = (%g)',[td.r,string(f),td.result]);
      rc := abs((td.r / f) - td.result) < fraction_type.epsilon;
      Test(msg,rc);
    end
  end;

procedure test_real_power_fraction;
  var
    test_data: array of RFR = (
        ( r:(0/1);f:(1,1);result:(0/1) ),
        ( r:(3/5);f:(-2,9);result:(643/574) ),
        ( r:(2/8);f:(-6,8);result:(577/204) ),
        ( r:(7/3);f:(10,7);result:(1399/417) ),
        ( r:(-5/7);f:(3,1);result:(-125/343) )
    );
    msg: string;
    rc: boolean;
    f: fraction_type;
    td: RFR;
  begin
    TestCase('real to power of fraction');
    for td in test_data do
    begin
      f := td.f;
      msg := Format('(%g) ** (%s) = (%g)',[td.r,string(f),td.result]);
      rc := abs((td.r ** f) - td.result) < fraction_type.epsilon;
      Test(msg,rc);
    end
  end;

  procedure test_fraction_round;
  var
    i: integer;
    msg: string;
    rc: boolean;
    round_data: array[0..3,0..4] of longint = ( (3333,10000,10,3,10), (3333,10000,100,33,100),
        (639,5176,100,3,25), ( 2147483647,106197, 1000, 10110849,500));
    f1,f2: fraction_type;

  begin
    TestCase('fraction round');
    for i := 0 to high(round_data) do
    begin
      msg := Format('(%d/%d).Round(%d) = (%d,%d)',[round_data[i,0],round_data[i,1],
          round_data[i,2],round_data[i,3],round_data[i,4]]);
      f1.fset(round_data[i,0],round_data[i,1]);
      f2 := f1.Round(round_data[i,2]);
      rc := R(f2,round_data[i,3],round_data[i,4]);
      Test(msg,rc);
    end
  end;


var
  tests: ProcArray = (
    @test_gcd,
    @test_set_num,
    @test_set_num_denom,
    @test_set_mixed,
    @test_set_real,
    @test_assign_real,
    @test_assign_array_with_one_element,
    @test_assign_array_with_two_elements,
    @test_assign_array_with_three_elements,
    @test_cast_to_string,
    @test_fraction_eq_fraction,
    @test_fraction_ne_fraction,
    @test_fraction_lt_fraction,
    @test_fraction_le_fraction,
    @test_fraction_gt_fraction,
    @test_fraction_ge_fraction,
    @test_fraction_eq_real,
    @test_fraction_ne_real,
    @test_fraction_lt_real,
    @test_fraction_le_real,
    @test_fraction_gt_real,
    @test_fraction_ge_real,
    @test_real_eq_fraction,
    @test_real_ne_fraction,
    @test_real_lt_fraction,
    @test_real_le_fraction,
    @test_real_gt_fraction,
    @test_real_ge_fraction,
    @test_fraction_plus_fraction,
    @test_fraction_minus_fraction,
    @test_fraction_times_fraction,
    @test_fraction_divided_by_fraction,
    @test_fraction_power_fraction,
    @test_fraction_plus_real,
    @test_fraction_minus_real,
    @test_fraction_times_real,
    @test_fraction_divided_by_real,
    @test_fraction_power_real,
    @test_real_plus_fraction,
    @test_real_minus_fraction,
    @test_real_times_fraction,
    @test_real_divided_by_fraction,
    @test_real_power_fraction,
    @test_fraction_round
  );

begin
  RunTests(tests);
end.
