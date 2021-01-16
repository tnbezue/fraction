# Copyright (C) 2016-2018  by Terry N Bezue

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package Fraction;

use strict;
use warnings;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw( $nloops );
BEGIN
{
}
our $nloops = 0;
our $epsilon = 5e-6;

# Some utilities
my $is_fraction = sub
{
  my ($self,$str) =@_;
  my $valid=0;
  my $n=0;
  my $d=1;
  if ($str =~ m/^\s*([-+]?\d+)(\s+([-+]?\d+)\/([-+]?\d+))?\s*$/) {
    $valid = 1;
    if(defined($3)) {
      my $w = $1;
      $n = $3;
      $d = $4;
      my $sign = 1;
      if($w < 0) {
        $sign *= -1;
        $w = -$w;
      }
      if($n < 0) {
        $sign *= -1;
        $n = -$n;
      }
      if($d < 0) {
        $sign *= -1;
        $d = -$d;
      }
      $n = $sign*($w*$d + $n);
    } else {
      $n = $1 + 0;
      $d = 1;
    }
  } elsif($str=~m/^\s*([-+]?\d+)\/([-+]?\d+)\s*$/) {
    $valid = 1;
    $n = $1;
    $d = $2;
  }
  return ($valid,$n,$d);
};

my $is_number = sub
{
  my ($self,$str) =@_;
  my $valid = 0;
  my $value = 0;
  if($str =~ m/^\s*([-+]?(\d+)(\.\d*)?([eE][-+]?\d+)?)\s*$/) {
    $valid = 1;
    $value = $1;
  } elsif ($str =~ m/^\s*([-+]?(\d*)(\.\d+)([eE][-+]?\d+)?)\s*$/) {
    $valid = 1;
    $value = $1;
  }
  return ($valid,$value);
};

my $number_to_fraction = sub
{
  # Expect number (integer or floating point) as only argument
  my ($self,$number) = @_;
  my $v = $number;
  my ($h,$hm1,$hm2,$k,$km1,$km2) = (0,1,0,0,0,1);
  $nloops = 0;
  while(1) {
    my $a = int($v);
    $h = $a*$hm1 + $hm2;
    $k = $a*$km1 + $km2;
    if(abs($number - $h/$k) < $epsilon) {
      last;
    }
    $v = 1.0/($v - $a);
    $hm2=$hm1;
    $km2=$km1;
    $hm1=$h;
    $km1=$k;
    $nloops += 1;
  }
  if($k<0) {
    $k=-$k;
    $h=-$h;
  }
  return ($h,$k);
};

my $cmp_fraction= sub {
  # Expect two fractions
  my ($lhs,$rhs) = @_;
  my $a = $lhs->{numerator_}*$rhs->{denominator_};
  my $b = $rhs->{numerator_}*$lhs->{denominator_};
  if($a < $b) {
    return -1;
  }
  if($a > $b) {
    return 1;
  }
  return 0;
};

my $fraction_to_float = sub {
  my ($self,$arg) = @_;
  my $result = $arg;
  if(ref($arg) eq "Fraction") {
    $result = $arg->{numerator_}/$arg->{denominator_};
  }
  return $result;
};

# Methods
sub gcd
{
  my $a = shift;
  my $b = shift;
  while($b!=0){
    my $t=$b;
    $b=$a % $b;
    $a=$t;
  }
  return $a;
}

sub new
{
  my $class = shift;
  my $self = bless { numerator_=>0, denominator_=>1}, $class;
  $self->set(@_);
  return $self;
}

sub set
{
  my ($self,@args)=@_;
  my $n=0;
  my $d=1;
  my $valid = 0;
  my $nargs = scalar(@args);
  if($nargs == 1) {
    # Args either another fraction ,,,
    if(ref($args[0]) eq "Fraction") {
      $n = $args[0]->{numerator_};
      $d = $args[0]->{denominator_};
    } else {
      # ...  a string representation of a fraction ...
      ($valid,$n,$d) = $self->$is_fraction($args[0]);
      if(!$valid) {
        # ... or a floating point number
        ($valid,$d) = $self->$is_number($args[0]);
        if($valid) {
          ($n,$d) = $self->$number_to_fraction($d);
        } else {
          die "Could not convert \"$args[0]\" to a fraction";
        }
      }
    }
  } elsif($nargs == 2) {
    # Args should be two numbers representing numerator and denominator
    $n = $args[0];
    $d=$args[1];
  } elsif($nargs == 3) {
    # Args should be three numbers representing a mixed fraction -- whole, numerator, denominator
    my $w = $args[0];
    $n = $args[1];
    $d = $args[2];
    my $sign = -1;
    if($w < 0) {
      $sign *= -1;
      $w = -$w;
    }
    if($n < 0) {
      $sign *= -1;
      $n = -$n;
    }
    if($d < 0) {
      $sign *= -1;
      $d = -$d;
    }
    $n = $sign*($w*$d+$n);
  }
  # Sign should be in numerator
  if($d < 0) {
    $n=-$n;
    $d=-$d;
  }
  my $gcd = gcd(abs($n),$d);
  $self->{numerator_}=$n/$gcd;
  $self->{denominator_}=$d/$gcd;
  return $self;
}

use overload (
  '0+'  => sub
  {
    my ($self) = @_;
    return $self->{numerator_}/$self->{denominator_};
  },

  '+' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    if($swap) {
      return $rhs*$lhs->{numerator_}/$lhs->{denominator_};
    }
    my $temp = Fraction->new($rhs); # rhs may not be a fraction, convert it to a fractopm
    my $f = Fraction->new($lhs->{numerator_}*$temp->{denominator_} + $temp->{numerator_}*$lhs->{denominator_},
          $lhs->{denominator_}*$temp->{denominator_});
    return $f;
  },

  '-' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    # swap will only be true if rhs is number and it was specified first
    if($swap) {
      # First argument was a number, return a number
      return $rhs - $lhs->{numerator_}/$lhs->{denominator_};
    }
    my $temp = Fraction->new($rhs); # rhs may not be a fraction, convert it to a fractopm
    return Fraction->new($lhs->{numerator_}*$temp->{denominator_} - $temp->{numerator_}*$lhs->{denominator_},
          $lhs->{denominator_}*$temp->{denominator_});
  },

  '*' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    if($swap) {
      return $rhs * $lhs->{numerator_}/$lhs->{denominator_};
    }
    my $temp = Fraction->new($rhs);
    return Fraction->new($lhs->{numerator_}*$temp->{numerator_},$lhs->{denominator_}*$temp->{denominator_});
  },

  '/' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    if($swap) {
      return ($rhs * $lhs->{denominator_})/ $lhs->{numerator_};
    }
    my $temp = Fraction->new($rhs);
    return Fraction->new($lhs->{numerator_}*$temp->{denominator_},$lhs->{denominator_}*$temp->{numerator_});
  },

  '**' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    my $b = $lhs->$fraction_to_float($lhs);
    my $e = $lhs->$fraction_to_float($rhs);
    if($b < 0) {
      if(int($e) != $e) {
        die "Attempt to rase a negative base to a non integer power";
      }
    }
    my $result = $b**abs($e);
    if($e < 0) {
      $result = 1.0/$result;
    }
    if($swap) {
      return $result;
    }
    return Fraction->new($result);
  },

  'abs' => sub {
    my $self = shift;
    return Fraction->new(abs($self->{numerator_}),$self->{denominator_});
  },

  '%' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    my $temp = Fraction->new($rhs);
    my $result = 0;
    if($swap) {
      if($lhs->{numerator_} == 0) {
        die "Illegal modulus zero";
      }
      $result = abs($temp)/$lhs;
    } else {
      if($temp->{numerator_} == 0) {
        die "Illegal modulus zero";
      }
      $result = abs($lhs)/$temp;
    }
    $temp = $result->{numerator_} % $result->{denominator_};
    return Fraction->new($temp,$result->{denominator_});
  },

  'neg' => sub
  {
    my $self = shift;
    return Fraction->new(-$self->{numerator_},$self->{denominator_});
  },

  '<=>' => sub
  {
    my ($lhs,$rhs,$swap) = @_;
    if($swap) {
      return -$rhs->$cmp_fraction(Fraction->new($lhs));
    }
    return $lhs->$cmp_fraction(Fraction->new($rhs));
  },

  '""' => sub
  {
    my $self = shift;
    return "$self->{numerator_}". ($self->{denominator_} != 1 ? "/$self->{denominator_}" : "")
  }
);

sub to_mixed_string
{
  my $self = shift;
  if(abs($self->{numerator_}) < $self->{denominator_}) {
    return $self->to_string();
  }
  my $whole = int(abs($self->{numerator_})/$self->{denominator_});
  my $n = abs($self->{numerator_}) - $whole*$self->{denominator_};
  my $str = ($self->{numerator_} < 0 ? "-" : "") . "$whole";
  if($n > 0) {
    $str .= " $n/$self->{denominator_}";
  }
  return $str;
}

sub round
{
  my ($self,$d) = @_;
  $d=int($d);
  $self->set(int($self->{numerator_}*$d/$self->{denominator_}),$d);
  return $self;
}

1;
