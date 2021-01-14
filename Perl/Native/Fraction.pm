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

# It's better to call set and let it determine if set_number should be called
sub set_number
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
  $self->{numerator_}=$h;
  $self->{denominator_}=$k;
  return $self;
};

sub set
{
  my ($self,@args)=@_;
  my $n=0;
  my $d=1;
  my $nargs = scalar(@args);
  if($nargs==0) {
  } elsif($nargs == 1) {
    # Args either another fraction or a number
    if(ref($args[0]) eq "Fraction") {
      $self->{numerator_} = $args[0]->{numerator_};
      $self->{denominator_} = $args[0]->{denominator_};
    } else {
      $self->set_number($args[0]);
    }
    return $self;
  } elsif($nargs == 2) {
    # Args should be two numbers representing numerator and denominator
    $n = $args[0];
    $d=$args[1];
  } elsif($nargs == 3) {
    # Args should be three numbers representing a mixed fraction -- whole, numerator, denominator
    $n = $args[0]*$args[2]+$args[1],$d=$args[2];
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

sub plus {
  my ($self,$o) = @_;
  if (ref($o) eq "Fraction") {
    # Add fractions
    $self->set($self->{numerator_}*$o->{denominator_} + $o->{numerator_}*$self->{denominator_},
          $self->{denominator_}*$o->{denominator_});
  } else {
    # Fraction plus number
    $self->plus(Fraction->new($o));
  }
  return $self;
}

sub fraction_plus_fraction
{
  my $f = Fraction->new($_[0]);
  $f->plus($_[1]);
  return $f;
}

sub minus {
  my ($self,$o) = @_;
  if (ref($o) eq "Fraction") {
    # subtract fractions
    $self->set($self->{numerator_}*$o->{denominator_} - $o->{numerator_}*$self->{denominator_},
          $self->{denominator_}*$o->{denominator_});
  } else {
    # Fraction minus number
    $self->minus(Fraction->new($o));

  }
  return $self;
}

sub fraction_minus_fraction
{
  my $f = Fraction->new($_[0]);
  $f->minus($_[1]);
  return $f;
}

sub times {
  my ($self,$o) = @_;
  if (ref($o) eq "Fraction") {
    # multiply fractions
    $self->set($self->{numerator_}*$o->{numerator_},$self->{denominator_}*$o->{denominator_});
  } else {
    # Fraction times number
    $self->times(Fraction->new($o));
  }
  return $self;
}

sub fraction_times_fraction
{
  my $f = Fraction->new($_[0]);
  $f->times($_[1]);
  return $f;
}

sub divided_by {
  my ($self,$o) = @_;
  if (ref($o) eq "Fraction") {
    # divide fractions
    $self->set($self->{numerator_}*$o->{denominator_},$self->{denominator_}*$o->{numerator_});
  } else {
    # Fraction divided number
    $self->divided_by(Fraction->new($o));
  }
  return $self;
}

sub fraction_divided_by_fraction
{
  my $f = Fraction->new($_[0]);
  $f->divided_by($_[1]);
  return $f;
}

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

sub eq
{
  my ($self,$o) = @_;
  if(ref($self) eq "Fraction") {
    if(ref($o) eq "Fraction") {
      return $self->$cmp_fraction($o) == 0; # Two fractions
    } else {
      return $self->$cmp_fraction(Fraction->new($o)) == 0;
    }
  } elsif (ref($o) == "Fraction") {
    return $o->$cmp_fraction(Fraction->new($self)) == 0; # 1st is not a fraction, second is
  } else {
    return $self == $o;  # Something onther than fractions
  }
}

sub ne
{
  my ($self,$o) = @_;
  if(ref($self) eq "Fraction") {
    if(ref($o) eq "Fraction") {
      return $self->$cmp_fraction($o) != 0; # Two fractions
    } else {
      return $self->$cmp_fraction(Fraction->new($o)) != 0;
    }
  } elsif(ref($o) == "Fraction") {
    return $o->$cmp_fraction(Fraction->new($self)) != 0; # 1st is not a fraction, second is
  } else {
    return $self != $o;  # Something onther than fractions
  }
}

sub lt
{
  my ($self,$o) = @_;
    if(ref($self) eq "Fraction") {
      if(ref($o) eq "Fraction") {
        return $self->$cmp_fraction($o) < 0; # Two fractions
      } else {
        return $self->$cmp_fraction(Fraction->new($o)) < 0;
      }
    } else {
      if(ref($o) == "Fraction") {
        return $o->$cmp_fraction(Fraction->new($self)) > 0; # 1st is not a fraction, second is
      } else {
        return $self < $o;  # Something onther than fractions
    }
  }
}

sub le
{
  my ($self,$o) = @_;
    if(ref($self) eq "Fraction") {
      if(ref($o) eq "Fraction") {
        return $self->$cmp_fraction($o) <= 0; # Two fractions
      } else {
        return $self->$cmp_fraction(Fraction->new($o)) <= 0;
      }
    } else {
      if(ref($o) == "Fraction") {
        return $o->$cmp_fraction(Fraction->new($self)) => 0; # 1st is not a fraction, second is
      } else {
        return $self <= $o;  # Something onther than fractions
    }
  }
}

sub gt
{
  my ($self,$o) = @_;
    if(ref($self) eq "Fraction") {
      if(ref($o) eq "Fraction") {
        return $self->$cmp_fraction($o) > 0; # Two fractions
      } else {
        return $self->$cmp_fraction(Fraction->new($o)) > 0;
      }
    } else {
      if(ref($o) == "Fraction") {
        return $o->$cmp_fraction(Fraction->new($self)) < 0; # 1st is not a fraction, second is
      } else {
        return $self > $o;  # Something onther than fractions
    }
  }
}

sub ge
{
  my ($self,$o) = @_;
    if(ref($self) eq "Fraction") {
      if(ref($o) eq "Fraction") {
        return $self->$cmp_fraction($o) >= 0; # Two fractions
      } else {
        return $self->$cmp_fraction(Fraction->new($o)) >= 0;
      }
    } else {
      if(ref($o) == "Fraction") {
        return $o->$cmp_fraction(Fraction->new($self)) <= 0; # 1st is not a fraction, second is
      } else {
        return $self >= $o;  # Something onther than fractions
    }
  }
}


sub to_string
{
  my $self = shift;
  return "$self->{numerator_}". ($self->{denominator_} != 1 ? "/$self->{denominator_}" : "")
}

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
