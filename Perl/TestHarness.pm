
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

package TestHarness;

use strict;
use warnings;

sub new
{
  my $class = shift;
  my $self = bless { nPass => 0, nFail => 0, nTotalPass=>0, nTotalFail=>0 },$class;
  return $self;
}

sub summary
{
  my $self=shift;
  print "  Passed: $self->{nPass}\n  Failed: $self->{nFail}\n";
}

sub testcase
{
  my ($self,$s) = @_;
  if($self->{nPass} > 0 or $self->{nFail} > 0) {
    $self->summary();
  }
  print "\n$s\n";
  $self->{nTotalPass} += $self->{nPass};
  $self->{nTotalFail} += $self->{nFail};
  $self->{nPass} = 0;
  $self->{nFail} = 0;
}

sub test
{
  my ($self,$s,$b) = @_;
  my $pass_or_fail;
  if($b) {
    $self->{nPass} += 1;
    $pass_or_fail = "Pass";
  } else {
    $self->{nFail} +=1;
    $pass_or_fail = "Fail";
  }
  print "  $s ... $pass_or_fail\n";
}

sub final_summary
{
  my $self=shift;
  if($self->{nPass} > 0 or $self->{nFail} > 0) {
    $self->summary();
    $self->{nTotalPass} += $self->{nPass};
    $self->{nTotalFail} += $self->{nFail};
  }
  print "\nTotal Passed: $self->{nTotalPass}\nTotal Failed: $self->{nTotalFail}\n";
}

1;
