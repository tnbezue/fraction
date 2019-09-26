program HelloWorld;
uses fract,crt,test_harness,sysutils;

var
  true_or_false: array[0..1] of string = ('false','true');

procedure test_gcd;
  var
    i: integer;
    msg: string;
    rc: boolean;
    gcd_test_data: array[0..5,0..2] of longint = ( ( 0,2,2),( 10,1,1),( 105,15,15),( 10,230,10),( 28,234,2), (872452914,78241452,6 ));

  begin
    TestCase('Greatest Common Divisor');
    for i:= 0 to high(gcd_test_data) do
    begin
      msg := Format('GCD(%d,%d)=%d',[gcd_test_data[i,0],gcd_test_data[i,1],gcd_test_data[i,2]]);
      rc := gcd(gcd_test_data[i,0],gcd_test_data[i,1])=gcd_test_data[i,2];
      Test(msg,rc);
    end;
  end;

function R(f: Fraction; var n,d: longint): boolean;
  begin
    R := (f.numerator = n) and (f.denominator = d);
  end;

procedure test_set_num;
  var
    i: integer;
    msg: string;
    rc: boolean;
    set_num_data: array[0..4,0..2] of longint = ( ( 0,0,1 ), (1,1,1), (-2,-2,1), (-12,-12,1), (12,12,1) );
    f: Fraction;

  begin
    TestCase('Set Numerator');
    for i := 0 to high(set_num_data) do
    begin
      msg := Format('SetNum(%d) = (%d/%d)',[set_num_data[i,0],set_num_data[i,1],set_num_data[i,2]]);
      f.SetNum(set_num_data[i,0]);
      rc := R(f,set_num_data[i,1],set_num_data[i,2]);
      Test(msg,rc);
    end
  end;

procedure test_set_num_denom;
  var
    i: integer;
    msg: string;
    rc: boolean;
    set_num_denom_data: array[0..6,0..3] of longint = ( ( 0,1,0,1 ), (1,1,1,1), (-2,3,-2,3),
        (2,-3,-2,3), (-2,-3,2,3) , (-12, 3, -4, 1), (100,200,1,2));
    f: Fraction;

  begin
    TestCase('Set Numerator and Denominator');
    for i := 0 to high(set_num_denom_data) do
    begin
      msg := Format('SetNum(%d,%d) = (%d/%d)',[set_num_denom_data[i,0],set_num_denom_data[i,1],set_num_denom_data[i,2],
          set_num_denom_data[i,3]]);
      f.SetNumDenom(set_num_denom_data[i,0],set_num_denom_data[i,1]);
      rc := R(f,set_num_denom_data[i,2],set_num_denom_data[i,3]);
      Test(msg,rc);
    end
  end;

  procedure test_set_mixed;
  var
    i: integer;
    msg: string;
    rc: boolean;
    set_mixed_data: array[0..4,0..4] of longint = ( ( -10,2,3,-32,3 ), (0,-2,3,-2,3), (0,0,1,0,1), (0,2,3,2,3), (10,2,3,32,3));
    f: Fraction;

  begin
    TestCase('Set Mixed');
    for i := 0 to high(set_mixed_data) do
    begin
      msg := Format('SetMixed(%d,%d,%d) = (%d/%d)',[set_mixed_data[i,0],set_mixed_data[i,1],set_mixed_data[i,2],
          set_mixed_data[i,3],set_mixed_data[i,4]]);
      f.SetMixed(set_mixed_data[i,0],set_mixed_data[i,1],set_mixed_data[i,2]);
      rc := R(f,set_mixed_data[i,3],set_mixed_data[i,4]);
      Test(msg,rc);
    end
  end;

  procedure test_set_real;
  var
    i: integer;
    msg: string;
    rc: boolean;
    set_real_input_data: array[0..11] of real = (-12.25, -10.0, -1.0, -0.25, 0.0, 0.25, 1.0,
        10.0, 12.25, 0.3, 0.33, 0.33333333 );
    set_real_output_data: array[0..11,0..1] of longint = ((-49,4), (-10,1), (-1,1), (-1,4), (0,1), (1,4), (1,1),
        (10,1), ( 49,4),(3,10), (33,100), (1,3) );
    f: Fraction;

  begin
    TestCase('Set Real');
    for i := 0 to high(set_real_input_data) do
    begin
      msg := Format('SetReal(%.6g) = (%d/%d)',[set_real_input_data[i],set_real_output_data[i,0],
          set_real_output_data[i,1]]);
      f.SetReal(set_real_input_data[i]);
      rc := R(f,set_real_output_data[i,0],set_real_output_data[i,1]);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_plus;
  var
    i: integer;
    msg: string;
    rc: boolean;
    plus_data: array[0..5,0..5] of longint = ( (0,1,0,1,0,1) , (0,1,1,1,1,1),(3,5,-2,9,17,45),
          (-2,8,-6,8,-1,1), (7,3,10,7,79,21), (-5,7,25,35,0,1));
    f1,f2,f3: Fraction;

  begin
    TestCase('Fraction Addition');
    for i := 0 to high(plus_data) do
    begin
      msg := Format('(%d/%d) + (%d,%d) = (%d/%d)',[plus_data[i,0],plus_data[i,1],plus_data[i,2],
          plus_data[i,3],plus_data[i,4],plus_data[i,5]]);
      f1.SetNumDenom(plus_data[i,0],plus_data[i,1]);
      f2.SetNumDenom(plus_data[i,2],plus_data[i,3]);
      f3 := fraction_plus_fraction(f1,f2);
      rc := R(f3,plus_data[i,4],plus_data[i,5]);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_minus;
  var
    i: integer;
    msg: string;
    rc: boolean;
    minus_data: array[0..5,0..5] of longint = ( (0,1,0,1,0,1) , (0,1,1,1,-1,1),(3,5,-2,9,37,45),
          (-2,8,-6,8,1,2), (7,3,10,7,19,21), (-5,7,25,35,-10,7));
    f1,f2,f3: Fraction;

  begin
    TestCase('Fraction subtraction');
    for i := 0 to high(minus_data) do
    begin
      msg := Format('(%d/%d) - (%d,%d) = (%d/%d)',[minus_data[i,0],minus_data[i,1],minus_data[i,2],
          minus_data[i,3],minus_data[i,4],minus_data[i,5]]);
      f1.SetNumDenom(minus_data[i,0],minus_data[i,1]);
      f2.SetNumDenom(minus_data[i,2],minus_data[i,3]);
      f3 := fraction_minus_fraction(f1,f2);
      rc := R(f3,minus_data[i,4],minus_data[i,5]);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_times;
  var
    i: integer;
    msg: string;
    rc: boolean;
    times_data: array[0..5,0..5] of longint = ( (0,1,0,1,0,1) , (0,1,1,1,0,1),(3,5,-2,9,-2,15),
          (-2,8,-6,8,3,16), (7,3,10,7,10,3), (-5,7,25,35,-25,49));
    f1,f2,f3: Fraction;

  begin
    TestCase('Fraction multiplication');
    for i := 0 to high(times_data) do
    begin
      msg := Format('(%d/%d) * (%d,%d) = (%d/%d)',[times_data[i,0],times_data[i,1],times_data[i,2],
          times_data[i,3],times_data[i,4],times_data[i,5]]);
      f1.SetNumDenom(times_data[i,0],times_data[i,1]);
      f2.SetNumDenom(times_data[i,2],times_data[i,3]);
      f3 := fraction_times_fraction(f1,f2);
      rc := R(f3,times_data[i,4],times_data[i,5]);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_divided_by;
  var
    i: integer;
    msg: string;
    rc: boolean;
    divided_by_data: array[0..4,0..5] of longint = ( (0,1,1,1,0,1),(3,5,-2,9,-27,10),
          (-2,8,-6,8,1,3), (7,3,10,7,49,30), (-5,7,25,35,-1,1));
    f1,f2,f3: Fraction;

  begin
    TestCase('Fraction Division');
    for i := 0 to high(divided_by_data) do
    begin
      msg := Format('(%d/%d) / (%d,%d) = (%d/%d)',[divided_by_data[i,0],divided_by_data[i,1],
          divided_by_data[i,2],divided_by_data[i,3],divided_by_data[i,4],divided_by_data[i,5]]);
      f1.SetNumDenom(divided_by_data[i,0],divided_by_data[i,1]);
      f2.SetNumDenom(divided_by_data[i,2],divided_by_data[i,3]);
      f3 := fraction_divided_by_fraction(f1,f2);
      rc := R(f3,divided_by_data[i,4],divided_by_data[i,5]);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_equality;
  var
    i: integer;
    msg: string;
    rc: boolean;
    equality_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,1), (0,1,1,2,0), (2,3,-2,4,0), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,0));
    f1,f2: Fraction;

  begin
    TestCase('Fraction equality');
    for i := 0 to high(equality_data) do
    begin
      msg := Format('(%d/%d) = (%d,%d) -- %s',[equality_data[i,0],equality_data[i,1],
          equality_data[i,2],equality_data[i,3],true_or_false[equality_data[i,4]]]);
      f1.SetNumDenom(equality_data[i,0],equality_data[i,1]);
      f2.SetNumDenom(equality_data[i,2],equality_data[i,3]);
      rc := (fraction_eq_fraction(f1,f2)) = (equality_data[i,4]=1);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_inequality;
  var
    i: integer;
    msg: string;
    rc: boolean;
    inequality_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,0), (0,1,1,2,1), (2,3,-2,4,1), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,1));
    f1,f2: Fraction;

  begin
    TestCase('Fraction equality');
    for i := 0 to high(inequality_data) do
    begin
      msg := Format('(%d/%d) <> (%d,%d) -- %s',[inequality_data[i,0],inequality_data[i,1],
          inequality_data[i,2],inequality_data[i,3],true_or_false[inequality_data[i,4]]]);
      f1.SetNumDenom(inequality_data[i,0],inequality_data[i,1]);
      f2.SetNumDenom(inequality_data[i,2],inequality_data[i,3]);
      rc := (fraction_ne_fraction(f1,f2)) = (inequality_data[i,4]=1);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_less_than;
  var
    i: integer;
    msg: string;
    rc: boolean;
    less_than_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,0), (0,1,1,2,1), (2,3,-2,4,0), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,1));
    f1,f2: Fraction;

  begin
    TestCase('Fraction less than');
    for i := 0 to high(less_than_data) do
    begin
      msg := Format('(%d/%d) < (%d,%d) -- %s',[less_than_data[i,0],less_than_data[i,1],
          less_than_data[i,2],less_than_data[i,3],true_or_false[less_than_data[i,4]]]);
      f1.SetNumDenom(less_than_data[i,0],less_than_data[i,1]);
      f2.SetNumDenom(less_than_data[i,2],less_than_data[i,3]);
      rc := (fraction_lt_fraction(f1,f2)) = (less_than_data[i,4]=1);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_less_than_equal;
  var
    i: integer;
    msg: string;
    rc: boolean;
    less_than_equal_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,1), (0,1,1,2,1), (2,3,-2,4,0), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,1));
    f1,f2: Fraction;

  begin
    TestCase('Fraction less than or equal');
    for i := 0 to high(less_than_equal_data) do
    begin
      msg := Format('(%d/%d) <= (%d,%d) -- %s',[less_than_equal_data[i,0],less_than_equal_data[i,1],
          less_than_equal_data[i,2],less_than_equal_data[i,3],true_or_false[less_than_equal_data[i,4]]]);
      f1.SetNumDenom(less_than_equal_data[i,0],less_than_equal_data[i,1]);
      f2.SetNumDenom(less_than_equal_data[i,2],less_than_equal_data[i,3]);
      rc := (fraction_le_fraction(f1,f2)) = (less_than_equal_data[i,4]=1);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_greater_than;
  var
    i: integer;
    msg: string;
    rc: boolean;
    greater_than_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,0), (0,1,1,2,0), (2,3,-2,4,1), (2,3,16,24,0), (1,3,1,3,0),(-5,7,25,35,0));
    f1,f2: Fraction;

  begin
    TestCase('Fraction greater than');
    for i := 0 to high(greater_than_data) do
    begin
      msg := Format('(%d/%d) > (%d,%d) -- %s',[greater_than_data[i,0],greater_than_data[i,1],
          greater_than_data[i,2],greater_than_data[i,3],true_or_false[greater_than_data[i,4]]]);
      f1.SetNumDenom(greater_than_data[i,0],greater_than_data[i,1]);
      f2.SetNumDenom(greater_than_data[i,2],greater_than_data[i,3]);
      rc := (fraction_gt_fraction(f1,f2)) = (greater_than_data[i,4]=1);
      Test(msg,rc);
    end
  end;

  procedure test_fraction_greater_than_equal;
  var
    i: integer;
    msg: string;
    rc: boolean;
    greater_than_equal_data: array[0..5,0..4] of longint = ( ( 0,1,0,1,1), (0,1,1,2,0), (2,3,-2,4,1), (2,3,16,24,1), (1,3,1,3,1),(-5,7,25,35,0));
    f1,f2: Fraction;

  begin
    TestCase('Fraction greater than or equal');
    for i := 0 to high(greater_than_equal_data) do
    begin
      msg := Format('(%d/%d) >= (%d,%d) -- %s',[greater_than_equal_data[i,0],greater_than_equal_data[i,1],
          greater_than_equal_data[i,2],greater_than_equal_data[i,3],true_or_false[greater_than_equal_data[i,4]]]);
      f1.SetNumDenom(greater_than_equal_data[i,0],greater_than_equal_data[i,1]);
      f2.SetNumDenom(greater_than_equal_data[i,2],greater_than_equal_data[i,3]);
      rc := (fraction_ge_fraction(f1,f2)) = (greater_than_equal_data[i,4]=1);
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
    f1,f2: Fraction;

  begin
    TestCase('Fraction round');
    for i := 0 to high(round_data) do
    begin
      msg := Format('(%d/%d).Round(%d) = (%d,%d)',[round_data[i,0],round_data[i,1],
          round_data[i,2],round_data[i,3],round_data[i,4]]);
      f1.SetNumDenom(round_data[i,0],round_data[i,1]);
      f2 := f1.Round(round_data[i,2]);
      rc := R(f2,round_data[i,3],round_data[i,4]);
      Test(msg,rc);
    end
  end;


var
  tests: array[0..15] of procedure = (
    @test_gcd,
    @test_set_num,
    @test_set_num_denom,
    @test_set_mixed,
    @test_set_real,
    @test_fraction_plus,
    @test_fraction_minus,
    @test_fraction_times,
    @test_fraction_divided_by,
    @test_fraction_equality,
    @test_fraction_inequality,
    @test_fraction_less_than,
    @test_fraction_less_than_equal,
    @test_fraction_greater_than,
    @test_fraction_greater_than_equal,
    @test_fraction_round
  );

begin
  RunTests(tests);
end.
