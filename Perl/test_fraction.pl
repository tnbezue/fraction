use TestHarness;
use Fraction;

my $th = TestHarness->new();

sub R
{
  my ($f,$n,$d) = @_;
  return $f->{numerator_} == $n and $f->{denominator_} == $d;
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

sub test_set()
{
  my @test_data = (
    [ 0,0,1 ],
    [ 0,1,0,1 ],
    [ Fraction->new(0,1),0,1 ],
    [1,1,1,1],
    [-2,3,-2,3],
    [2,-3,-2,3],
    [-2,-3,2,3],
    [.06,3,50],
    ["7.125",57,8],
    );

  $th->testcase("New/Set");
  foreach (@test_data) {
    my $f;
    if(scalar(@$_) == 3) {
      # Testing fraction or single number
      $f=Fraction->new($$_[0]);
      if(ref($$_[0]) eq "Fraction") {
        $th->test("set(Fraction($$_[0]->{numerator_},$$_[0]->{denominator_}) is ($$_[1]/$$_[2]))",
            R($f,$$_[1],$$_[2]));
      } else {
        $th->test("set($$_[0]) is ($$_[1]/$$_[2]))",R($f,$$_[1],$$_[2]));
      }
    } elsif(scalar(@$_) == 4) {
      $f = Fraction->new($$_[0],$$_[1]);
      $th->test("set($$_[0],$$_[1]) is ($$_[2]/$$_[3])",R($f,$$_[2],$$_[3]));
    }
  }
}

sub test_plus
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,1,1],
      [3,5,-2,9,17,45],
      [-2,8,-6,8,-1,1],
      [7,3,10,7,79,21],
      [-5,7,25,170,7],
      [-5,7,-10,-75,7],
      [-5,7,0.06,-229,350],
    );

  $th->testcase("Addition");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 6) {
      # Adding fraction to number
      my $f2=Fraction->new($$_[2],$$_[3]);
      my $f3=Fraction::fraction_plus_fraction($f1,$f2);
      $th->test("($$_[0]/$$_[1]) + ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
    } elsif(scalar(@$_) == 5) {
      # Adding fraction to number
      my $f3=Fraction::fraction_plus_fraction($f1,$$_[2]);
      $th->test("($$_[0]/$$_[1]) + $$_[2] = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
    }
  }
}

sub test_minus
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,-1,1],
      [3,5,-2,9,37,45],
      [-2,8,-6,8,1,2],
      [7,3,10,7,19,21],
      [-5,7,25,-180,7],
      [-5,7,-10,65,7],
      [-5,7,0.06,-271,350],
    );

  $th->testcase("Subtraction");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 6) {
      # Fraction - Fraction
      my $f2=Fraction->new($$_[2],$$_[3]);
      my $f3=Fraction::fraction_minus_fraction($f1,$f2);
      $th->test("($$_[0]/$$_[1]) - ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
    } elsif(scalar(@$_) == 5) {
      # Fraction - number
      my $f3=Fraction::fraction_minus_fraction($f1,$$_[2]);
      $th->test("($$_[0]/$$_[1]) - $$_[2] = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
    }
  }
}

sub test_multiply
{
  my @test_data = (
      [0,1,0,1,0,1],
      [0,1,1,1,0,1],
      [3,5,-2,9,-2,15],
      [-2,8,-6,8,3,16],
      [7,3,10,7,10,3],
      [-5,7,25,-125,7],
      [-5,7,-10,50,7],
      [-5,7,0.06,-3,70],
    );

  $th->testcase("Multiplication");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 6) {
      # Fraction * Fraction
      my $f2=Fraction->new($$_[2],$$_[3]);
      my $f3=Fraction::fraction_times_fraction($f1,$f2);
      $th->test("($$_[0]/$$_[1]) * ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
    } elsif(scalar(@$_) == 5) {
      # Fraction * number
      my $f3=Fraction::fraction_times_fraction($f1,$$_[2]);
      $th->test("($$_[0]/$$_[1]) * $$_[2] = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
    }
  }
}

sub test_divide
{
  my @test_data = (
      [0,1,1,1,0,1],
      [3,5,-2,9,-27,10],
      [-2,8,-6,8,1,3],
      [7,3,10,7,49,30],
      [-5,7,25,-1,35],
      [-5,7,-10,1,14],
      [-5,7,0.06,-250,21],
    );

  $th->testcase("Division");
  foreach (@test_data) {
    my $f1=Fraction->new($$_[0],$$_[1]);
    if(scalar(@$_) == 6) {
      # Fraction - Fraction
      my $f2=Fraction->new($$_[2],$$_[3]);
      my $f3=Fraction::fraction_divided_by_fraction($f1,$f2);
      $th->test("($$_[0]/$$_[1]) / ($$_[2]/$$_[3]) = ($$_[4]/$$_[5])",R($f3,$$_[4],$$_[5]));
    } elsif(scalar(@$_) == 5) {
      # Fraction - number
      my $f3=Fraction::fraction_divided_by_fraction($f1,$$_[2]);
      $th->test("($$_[0]/$$_[1]) / $$_[2] = ($$_[3]/$$_[4])",R($f3,$$_[3],$$_[4]));
    }
  }
}

sub test_eq
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
      $th->test("($$_[0]/$$_[1]) == ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->eq($f2) == $$_[4]);
    }
  }
}

sub test_ne
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
      $th->test("($$_[0]/$$_[1]) != ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->ne($f2) == $$_[4]);
    }
  }
}

sub test_lt
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
      $th->test("($$_[0]/$$_[1]) < ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->lt($f2) == $$_[4]);
    }
  }
}

sub test_le
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
      $th->test("($$_[0]/$$_[1]) <= ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->le($f2) == $$_[4]);
    }
  }
}

sub test_gt
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
      $th->test("($$_[0]/$$_[1]) > ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->gt($f2) == $$_[4]);
    }
  }
}

sub test_ge
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
      $th->test("($$_[0]/$$_[1]) >= ($$_[2]/$$_[3]) ".($$_[4] ? "(True)" : "(False)"),$f->ge($f2) == $$_[4]);
    }
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
  \&test_set,
  \&test_plus,
  \&test_minus,
  \&test_multiply,
  \&test_divide,
  \&test_eq,
  \&test_ne,
  \&test_lt,
  \&test_le,
  \&test_gt,
  \&test_ge,
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
