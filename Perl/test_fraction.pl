#!/usr/bin/env -S perl -I.

use TestHarness;
use Fraction;

my $th = TestHarness->new();

sub R
{
  my ($f,$n,$d) = @_;
  return $f->{numerator_} == $n and $f->{denominator_} == $d;
}

sub RN
{
  my ($n1,$n2) = @_;
  return abs($n1 - $n2) < $Fraction::epsilon;
}

sub test_gcd
{
  my @test_data =  (
    [ 0,2,2],
    [ 10,1,1],
    [ 105,15,15],
    [ 10,230,10],
    [ 28,234,2],
    [872452914,78241452,6 ]
 );
  $th->testcase("Greatest common denominator");
  foreach (@test_data) {
    $th->test("GCD($$_[0],$$_[1]) is $$_[2]",Fraction::gcd($$_[0],$$_[1])==$$_[2]);
  }
}

sub test_new_zero()
{
  $th->testcase("New with zero arguments");
  my $f = Fraction->new();
  $th->test("Fraction->new()=(0/1)",R($f,0,1));
}

sub test_new_single_integer()
{
  my @test_data = ( 0, 1, -10, 3, -3);

  $th->testcase("New/Set with single integer");
  foreach (@test_data) {
    my $f =Fraction->new($_);
    $th->test("Fraction->new($_) = ($_/1)",R($f,$_,1 ));
  }
}

sub test_new_single_number()
{
  my @test_data = (
    [0.0,0,1],
    [0.06,3,50],
    [-10.7,-107,10],
    [1.0/3.0,1,3],
    [-2.0/3.0,-2,3],
    [-50.5,-101,2],
  );
  $th->testcase("New/Set with single floating point number");
  foreach (@test_data) {
    my $f =Fraction->new($$_[0]);
    $th->test("Fraction->new($$_[0]) = ($$_[1]/$$_[2])",R($f,$$_[1],$$_[2]));
  }
}

sub test_new_single_string()
{
  my @test_data = (
    ["0.0",0,1],
    ["-0.06",-3,50],
    ["4/5",4,5],
    ["-9/2",-9,2],
    ["3 2/5",,17,5],
    ["-2 -3/-5",-13,5],
    ["-2 -3/5",13,5],
  );
  $th->testcase("New/Set with single string");
  foreach (@test_data) {
    my $f =Fraction->new($$_[0]);
    $th->test("Fraction->new(\"$$_[0]\") = ($$_[1]/$$_[2])",R($f,$$_[1],$$_[2]));
  }
}

sub test_new_two_integer()
{
  my @test_data = (
    [0,1,0,1],
    [1,-2,-1,2],
    [12,11,12,11],
    [105,5,21,1],
    [-35,-25,7,5],
    [-10,2,-5,1],
  );

  $th->testcase("New/Set with two integers");
  foreach (@test_data) {
    my $f =Fraction->new($$_[0],$$_[1]);
    $th->test("Fraction->new($$_[0],$$_[1]) = ($$_[2],$$_[3])",R($f,$$_[2],$$_[3]));
  }
}

sub test_new_three_integer()
{
  my @test_data = (
    [0,0,1,0,1],
    [0,1,-2,-1,2],
    [2,3,5,13,5],
    [-2,-5,7,19,7],
    [-4,-3,-5,-23,5],
    [2,-1,2,-5,2],
  );

  $th->testcase("New/Set with three integers");
  foreach (@test_data) {
    my $f =Fraction->new($$_[0],$$_[1],$$_[2]);
    $th->test("Fraction->new($$_[0],$$_[1],$$_[2]) = ($$_[3],$$_[4])",R($f,$$_[3],$$_[4]));
  }
}

sub test_new_existing_fraction()
{
  my @test_data = (
    [0,1],
    [-3,50],
    [4,5,],
    [-9,2],
  );
  $th->testcase("New/Set from aother");
  foreach (@test_data) {
    my $f =Fraction->new(Fraction->new($$_[0],$$_[1]));
    $th->test("Fraction->new(($$_[0],$$_[1])) = ($$_[0],$$_[1])",R($f,$$_[0],$$_[1]));
  }
}

sub test_fraction_plus_fraction
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,1,1],
      [3,5,-2,9,17,45],
      [-2,8,-6,8,-1,1],
      [7,3,10,7,79,21],
    );

  $th->testcase("Fraction plus Fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1+$f2;
    $th->test("($$_[0]/$$_[1]) + ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_fraction_minus_fraction
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,-1,1],
      [3,5,-2,9,37,45],
      [-2,8,-6,8,1,2],
      [7,3,10,7,19,21],
    );

  $th->testcase("Fraction minus Fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1-$f2;
    $th->test("($$_[0]/$$_[1]) - ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_fraction_times_fraction
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,0,1],
      [3,5,-2,9,-2,15],
      [-2,8,-6,8,3,16],
      [7,3,10,7,10,3],
    );

  $th->testcase("Fraction times Fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1 * $f2;
    $th->test("($$_[0]/$$_[1]) * ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_fraction_divided_by_fraction
{
  my @test_data = (
      [0,1,1,1,0,1],
      [3,5,-2,9,-27,10],
      [-2,8,-6,8,1,3],
      [7,3,10,7,49,30],
    );

  $th->testcase("Fraction divided by Fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1/$f2;
    $th->test("($$_[0]/$$_[1]) / ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_fraction_power_fraction
{
  my @test_data = (
      [0,1,1,2,0,1],
      [2,3,-2,4,485,396],
      [2,3,16,24,1321,1731],
      [1,3,1,3,303,437],
      [-5,7,25,1,-1,4499],
  );
  $th->testcase("Fraction to power of fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1**$f2;
    $th->test("($$_[0]/$$_[1]) ** ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_mod
{
  my @test_data = (
      [0,1,1,2,0,1],
      [2,3,-2,4,-1,3],
      [2,3,16,24,0,1],
      [-5,7,25,3,160,21],
  );
  $th->testcase("Modulus");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=Fraction->new($$_[2],$$_[3]);
    my $f3=$f1 % $f2;
    print "X ",ref($f3)," $ f3 X\n";
    $th->test("($$_[0]/$$_[1]) % ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
  }
}

sub test_fraction_plus_number
{
  my @test_data = (
      [0,1,0.0,0,1],
      [0,1,1.0,1,1],
      [3,5,-2.0/9.0,17,45],
      [-2,8,-6.0/8.0,-1,1],
      [7,3,10.7,391,30],
    );

  $th->testcase("Fraction plus Number");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f3=$f1 + $$_[2];
    $th->test("($$_[0]/$$_[1]) + $$_[2] = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
  }
}

sub test_fraction_minus_number
{
  my @test_data = (
      [0,1,0.0,0,1],
      [0,1,1.0,-1,1],
      [3,5,-2.0/9.0,37,45],
      [-2,8,-6.0/8.0,1,2],
      [7,3,10.0/7.0,19,21],
    );

  $th->testcase("Fraction minus number");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f3=$f1 - $$_[2];
    $th->test("($$_[0]/$$_[1]) - ($$_[2]) = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
  }
}

sub test_fraction_times_number
{
  my @test_data = (
      [0,1,0.0,0,1],
      [0,1,1.0,0,1],
      [3,5,-2.0/9.0,-2,15],
      [-2,8,-6.0/8.0,3,16],
      [7,3,10.0/7.0,10,3],
    );

  $th->testcase("Fraction times number");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f3=$f1*$$_[2];
    $th->test("($$_[0]/$$_[1]) * ($$_[2]) = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
  }
}

sub test_fraction_divided_by_number
{
  my @test_data = (
      [0,1,1.0,0,1],
      [3,5,-2.0/9.0,-27,10],
      [-2,8,-6.0/8.0,1,3],
      [7,3,10.0/7.0,49,30],
    );

  $th->testcase("Fraction divided by number");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f3=$f1/$$_[2];
    $th->test("($$_[0]/$$_[1]) / ($$_[2]) = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
  }
}

sub test_fraction_power_number
{
  my @test_data = (
      [0,1,1.0/2.0,0,1],
      [2,3,-2.0/4.0,485,396],
      [2,3,16.0/24.0,1321,1731],
      [1,3,1.0/3.0,303,437],
      [-5,7,25.0,-1,4499],
  );
  $th->testcase("Fraction to power of number");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=$f1**$$_[2];
    $th->test("($$_[0]/$$_[1]) ** ($$_[2]) = ($$_[3]/$$_[4])",R($f2,$$_[3],$$_[4]));
  }
}

sub test_number_plus_fraction
{
  my @test_data = (
      [0.0,0,1,0.0],
      [0.0,1,1,1.0],
      [3.0/5.0,-2,9,17.0/45.0],
      [-2.0/8.0,-6,8,-1.0],
      [7.0/3.0,10,7,79.0/21.0],
    );

  $th->testcase("Number plus Fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[1],$$_[2]);
    my $r= $$_[0] + $f1;
    $th->test("$$_[0] + ($$_[1]/$$_[2])  = $$_[3]",RN($r,$$_[3]));
  }
}

sub test_number_minus_fraction
{
  my @test_data = (
      [0.0,0,1,0.0],
      [0.0,1,1,-1.0],
      [3.0/5.0,-2,9,37.0/45.0],
      [-2.0/8.0,-6,8,1.0/2.0],
      [7.0/3.0,10,7,19.0/21.0],
    );

  $th->testcase("Number minus fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[1],$$_[2]);
    my $r= $$_[0] - $f1;
    $th->test("$$_[0] - ($$_[1]/$$_[2])  = $$_[3]",RN($r,$$_[3]));
  }
}

sub test_number_times_fraction
{
  my @test_data = (
      [0.0,0,1,0.0],
      [0.0,1,1,0.0],
      [3.0/5.0,-2,9,-2.0/15.0],
      [-2.0/8.0,-6,8,3.0/16.0],
      [7.0/3.0,10,7,10.0/3.0],
    );

  $th->testcase("Number times fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[1],$$_[2]);
    my $r= $$_[0] * $f1;
    $th->test("$$_[0] * ($$_[1]/$$_[2])  = $$_[3]",RN($r,$$_[3]));
  }
}

sub test_number_divided_by_fraction
{
  my @test_data = (
      [0.0,1,1,0.0],
      [3.0/5.0,-2,9,-27.0/10.0],
      [-2.0/8.0,-6,8,1.0/3.0],
      [7.0/3.0,10,7,49.0/30.0],
    );

  $th->testcase("Number divided by fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[1],$$_[2]);
    my $r= $$_[0] / $f1;
    $th->test("$$_[0] / ($$_[1]/$$_[2])  = $$_[3]",RN($r,$$_[3]));
  }
}

sub test_number_power_fraction
{
  my @test_data = (
      [0.0,1,2,0.0],
      [2.0/3.0,-2,4,485.0/396.0],
      [2.0/3.0,16,24,1321.0/1731.0],
      [1.0/3.0,1,3,303.0/437.0],
      [-5.0/7.0,25,1,-1.0/4499.0],
    );

  $th->testcase("Number power fraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[1],$$_[2]);
    my $r= $$_[0] ** $f1;
    $th->test("$$_[0] ** ($$_[1]/$$_[2])  = $$_[3]",RN($r,$$_[3]));
  }
}

sub test_neg
{
  my @test_data = (
    [ 0,1,0,1],
    [ 1, 1, -1, 1],
    [ 3,4, -3, 4],
    [ -3,4, 3, 4],
    [ -3,-4, -3, 4],
    [ 12,7, -12, 7],
    [ -24,14, 12, 7],
    [ -21,7, 3, 1],
    [ -64,28, 16, 7],
  );
  $th->testcase("Unary minus");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=-$f1;
    $th->test("-($$_[0]/$$_[1]) = ($$_[2]/$$_[3])",R($f2,$$_[2],$$_[3]));
  }
}

sub test_abs
{
  my @test_data = (
    [ 0,1,0,1],
    [ 1, 1, 1, 1],
    [ 3,4, 3, 4],
    [ -3,4, 3, 4],
    [ -3,-4, 3, 4],
    [ 12,7, 12, 7],
    [ -24,14, 12, 7],
    [ -21,7, 3, 1],
    [ -64,28, 16, 7],
  );
  $th->testcase("Unary minus");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    my $f2=abs($f1);
    $th->test("abs($$_[0]/$$_[1]) = ($$_[2]/$$_[3])",R($f2,$$_[2],$$_[3]));
  }
}

sub test_fraction_eq_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Equality");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) == ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f == $f2) == $$_[4]);
    }
  }
}

sub test_fraction_ne_fraction
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Inequality");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) != ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f != $f2) == $$_[4]);
    }
  }
}

sub test_fraction_lt_fraction
{
  my @test_data = (
      [0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Less than");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) < ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f < $f2) == $$_[4]);
    }
  }
}

sub test_fraction_le_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,1],
  );
  $th->testcase("Less than or equal");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) <= ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f <= $f2) == $$_[4]);
    }
  }
}

sub test_fraction_gt_fraction
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,0],
  );
  $th->testcase("Greater than");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) > ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f > $f2) == $$_[4]);
    }
  }
}

sub test_fraction_ge_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Greater than or equal");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 5) {
      my $f2 = Fraction->new($$_[2],$$_[3]);
      $th->test("($$_[0]/$$_[1]) >= ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),($f >= $f2) == $$_[4]);
    }
  }
}

sub test_fraction_eq_number
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Fraction equal number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) == ($value) ".($$_[4] ? "(True)" : "(False)"),($f == $value) == $$_[4]);
  }
}

sub test_fraction_ne_number
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Fraction not equal number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) != ($value) ".($$_[4] ? "(True)" : "(False)"),($f != $value) == $$_[4]);
  }
}

sub test_fraction_lt_number
{
  my @test_data = (
      [0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Fraction less than number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) < ($value) ".($$_[4] ? "(True)" : "(False)"),($f < $value) == $$_[4]);
  }
}

sub test_fraction_le_number
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,1],
  );
  $th->testcase("Fraction less than or equal number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) <= ($value) ".($$_[4] ? "(True)" : "(False)"),($f <= $value) == $$_[4]);
  }
}

sub test_fraction_gt_number
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,0],
  );
  $th->testcase("Fraction greater than number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) > ($value) ".($$_[4] ? "(True)" : "(False)"),($f > $value) == $$_[4]);
  }
}

sub test_fraction_ge_number
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Fraction greater than or equal number");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $value = $$_[2]/$$_[3];
    $th->test("($$_[0]/$$_[1]) >= ($value) ".($$_[4] ? "(True)" : "(False)"),($f >= $value) == $$_[4]);
  }
}
sub test_number_eq_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Number equal fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) == ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value == $f) == $$_[4]);
  }
}

sub test_number_ne_fraction
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Number not equal fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) != ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value != $f) == $$_[4]);
  }
}

sub test_number_lt_fraction
{
  my @test_data = (
      [0,1,0,1,0],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,1],
  );
  $th->testcase("Number less than fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) < ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value < $f) == $$_[4]);
  }
}

sub test_number_le_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,1],
      [2,3,-2,4,0],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,1],
  );
  $th->testcase("Number less than or equal fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) <= ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value <= $f) == $$_[4]);
  }
}

sub test_number_gt_fraction
{
  my @test_data = (
      [ 0,1,0,1,0],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,0],
      [1,3,1,3,0],
      [-5,7,25,35,0],
  );
  $th->testcase("Number greater than fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) > ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value > $f) == $$_[4]);
  }
}

sub test_number_ge_fraction
{
  my @test_data = (
      [ 0,1,0,1,1],
      [0,1,1,2,0],
      [2,3,-2,4,1],
      [2,3,16,24,1],
      [1,3,1,3,1],
      [-5,7,25,35,0],
  );
  $th->testcase("Number greater than or equal fraction");
  foreach (@test_data) {
    my $value = $$_[0]/$$_[1];
    my $f = Fraction->new($$_[2],$$_[3]);
    $th->test("($value) >= ($$_[2]/$$_[3])".($$_[4] ? "(True)" : "(False)"),($value >= $f) == $$_[4]);
  }
}

sub test_round
{
  my @test_data = (
      [3333,10000,10,3,10],
      [3333,10000,100,33,100],
      [639,5176,100,3,25],
      [ 2147483647,106197, 1000, 10110849,500],
  );
  $th->testcase("Round");
  foreach (@test_data) {
    my $f = Fraction->new($$_[0],$$_[1]);
    my $f2 = $f->round($$_[2]);
    my $f3 = Fraction->new($$_[3],$$_[4]);
    $th->test("($$_[0]/$$_[1])->round($$_[2]) = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
  }

}

my @tests = (
  \&test_gcd,
  \&test_new_zero,
  \&test_new_single_integer,
  \&test_new_single_number,
  \&test_new_single_string,
  \&test_new_two_integer,
  \&test_new_three_integer,
  \&test_new_existing_fraction,
  \&test_fraction_plus_fraction,
  \&test_fraction_minus_fraction,
  \&test_fraction_times_fraction,
  \&test_fraction_divided_by_fraction,
  \&test_fraction_power_fraction,
  \&test_fraction_plus_number,
  \&test_fraction_minus_number,
  \&test_fraction_times_number,
  \&test_fraction_divided_by_number,
  \&test_fraction_power_number,
  \&test_number_plus_fraction,
  \&test_number_minus_fraction,
  \&test_number_times_fraction,
  \&test_number_divided_by_fraction,
  \&test_number_power_fraction,
  \&test_mod,
  \&test_neg,
  \&test_abs,
  \&test_fraction_eq_fraction,
  \&test_fraction_ne_fraction,
  \&test_fraction_lt_fraction,
  \&test_fraction_le_fraction,
  \&test_fraction_gt_fraction,
  \&test_fraction_ge_fraction,
  \&test_fraction_eq_number,
  \&test_fraction_ne_number,
  \&test_fraction_lt_number,
  \&test_fraction_le_number,
  \&test_fraction_gt_number,
  \&test_fraction_ge_number,
  \&test_number_eq_fraction,
  \&test_number_ne_fraction,
  \&test_number_lt_fraction,
  \&test_number_le_fraction,
  \&test_number_gt_fraction,
  \&test_number_ge_fraction,
  \&test_round,
);

if(scalar(@ARGV) == 0) {
  foreach (@tests) {
    &$_();
  }
} else {
  my $count = scalar(@tests);
  foreach (@ARGV) {
    if($_ < $count) {
      $tests[$_]();
    } else {
      print "No test for $_\n";
    }
  }
}
$th->final_summary();
