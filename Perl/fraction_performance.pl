use strict;
use warnings;

use Fraction;
use Time::HiRes qw(clock_gettime clock_getres tv_interval CLOCK_MONOTONIC CLOCK_THREAD_CPUTIME_ID gettimeofday);
use Getopt::Long;

sub statistics
{
  my $refData = shift;
  my %stats = (
    average => Fraction->new(),
    standard_deviation => Fraction->new(),
    size => 0,
    median => 0,
    mode => 0
  );

  # Average and mode
  my $sum = 0;
  my $max_freq = 0;
  for my $k (sort {$a <=> $b} keys %$refData) {
    $stats{size} += $refData->{$k};
    $sum += $k*$refData->{$k};
    if($max_freq < $refData->{$k}) {
      $max_freq = $refData->{$k};
      $stats{mode} = $k;
    }
  }
  my $average = $sum/$stats{size};
  $stats{average}->set_number($average); # report average as a fraction
  $stats{average}->round(100);

  # median and variance
  my $var = 0;
  my $count =0;
  $stats{median}=-1;
  for my $k (sort {$a <=> $b} keys %$refData) {
    $var += ($k-$average)**2 * $refData->{$k};
    if($stats{median} == -1) {
      $count += $refData->{$k};
      if($count >= $stats{size}/2) {
        $stats{median}=$k;
      }
    }
  }

  # Standard deviantion
  $stats{standard_deviation}->set_number(sqrt($var/($stats{size}-1)));
  $stats{standard_deviation}->round(100);
  return \%stats;
}

sub time_diff_in_10s_of_nanoseconds
{
  my ($start,$end) = @_;
}

sub do_test
{
  my ($value,$refTimeFreq,$refLoopFreq) = @_;
  my $f=Fraction->new();
    my $begin_time = clock_gettime(CLOCK_THREAD_CPUTIME_ID);
    $f->set_number($value);
    my $end_time = clock_gettime(CLOCK_THREAD_CPUTIME_ID);
    my $diff_in_msecs=int(10000000*($end_time-$begin_time)+0.5);
    if(not exists $refLoopFreq->{$Fraction::nloops}) {
      $refLoopFreq->{$Fraction::nloops}=0;
    }
    if(not exists $refTimeFreq->{$diff_in_msecs}) {
      $refTimeFreq->{$diff_in_msecs}=0;
    }
    $refLoopFreq->{$Fraction::nloops}++;
    $refTimeFreq->{$diff_in_msecs}++;
}

sub display_graph
{
  my ($refFreqArray,$xlabel,$ylabel,$max) = @_;
  print "\n$xlabel |             $ylabel\n";
  print "-"x50,"\n";
  my $scale = 50/$max;
  for my $k (sort {$a <=> $b} keys %$refFreqArray) {
    printf "%4d  | %s %d\n",$k,"#"x(int($scale*$refFreqArray->{$k})),$refFreqArray->{$k};
  }
  print "\n";
}

sub show_results
{
  my ($refFreqArray,$heading,$xlabel) = @_;
  print "\n$heading\n";
  my @keys = sort {$a <=> $b} keys %$refFreqArray;
  print "  Min $xlabel: $keys[0]\n";
  print "  Max $xlabel: $keys[scalar(@keys)-1]\n";
  my $refStats = statistics($refFreqArray);
  print "  Sample size: $refStats->{size}\n";
  print "  Average: ",$refStats->{average}->to_mixed_string,"\n";
  print "  Median: $refStats->{median}\n";
  print "  Mode: $refStats->{mode}\n";
  print "  Standard deviation: ",$refStats->{standard_deviation}->to_mixed_string(),"\n";
  display_graph($refFreqArray,$xlabel,"Frequency",$refFreqArray->{$refStats->{mode}});
}

sub single_test
{
  my $denominator = shift;
  my $freqTime={};
  my $freqLoop={};
  for(my $i=1;$i<$denominator;$i++) {
    do_test($i/$denominator,$freqTime,$freqLoop);
  }
  show_results($freqTime,"Time taken to convert floating point to faction (time is in 100s of nanoseconds)","time");
  show_results($freqLoop,"Number of iterations to convert floating point to fraction","Loops");
}

sub random_test
{
  my $freqTime={};
  my $freqLoop={};
  my @values = ();
  my $ntests=0;
  while($ntests < $_[0]) {
    my $value = [rand()*16777216,rand()*16777216];
    my $found = 0;
    foreach my $v (@values) {
      if($v->[0] == $value->[0] && $v->[1] == $value->[1]) {
        $found = 1;
        last;
      }
    }
    if($found == 0) {
      push @values,$value;
      $ntests += 1;
    }
    $found = 0;
  }
  foreach my $value (@values) {
    do_test($value->[0]/$value->[1],$freqTime,$freqLoop);
  }
  show_results($freqTime,"Time taken to convert floating point to faction (time is in 100s of nanoseconds)","time");
  show_results($freqLoop,"Number of iterations to convert floating point to fraction","Loops");
}

if (scalar(@ARGV) > 0) {
  my $single_test_denominator=0;
  GetOptions(
    'single|s=i' => \$single_test_denominator
  ) or die "Error";
  print $single_test_denominator;
  if($single_test_denominator > 0) {
    single_test($single_test_denominator);
  }
} else {
  single_test(1000);
  random_test(1000);
}
