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

program fraction_performance;
uses unixtype,crt,fraction,sysutils,linux,getopts;

type
  Frequency = object
  public
    value,frequency : longint;
end;

type
  Statistics = object
  avg,standard_deviation: real;
  sample_size,sample_median,sample_mode: longint;

  function Average: TMixedFraction;
  function StandardDeviation: TMixedFraction;
  function Count: longint;
  function Mode: longint;
  function Median: longint;
end;

function Statistics.Average: TMixedFraction;
begin
  Average.fset(avg);
  Average := Average.Round(100);
end;

function Statistics.StandardDeviation: TMixedFraction;
begin
  StandardDeviation.fset(standard_deviation);
  StandardDeviation := StandardDeviation.Round(100);
end;

function Statistics.Count: longint;
begin
  Count := sample_size;
end;

function Statistics.Median: longint;
begin
  Median := sample_median;
end;

function Statistics.Mode: longint;
begin
  Mode := sample_mode;
end;

type
  FrequencyArray = object
  freq_array: array of Frequency;
  max_freq: longint;

  public
    function size: longint;
    function maxFreq: longint;
    procedure increment(value: longint);
    procedure Sort;
    function Statistics: Statistics;
    procedure DisplayGraph(const xlabel,ylabel: string);
    procedure ShowResults(const heading,xlabel: string);
end;

function FrequencyArray.size: longint;
begin
  size := length(freq_array);
end;

function FrequencyArray.maxFreq: longint;
begin
  maxFreq := max_freq;
end;

procedure FrequencyArray.increment(value: longint);
var
  i: integer;
  found: boolean;

begin
  found := false;
  for i := 0 to high(freq_array) do
  begin
    if(freq_array[i].value = value) then
    begin
      found := true;
      break;
    end;
  end;
  if found = false then
  begin
    i:=length(freq_array);
    setlength(freq_array,i+1);
    freq_array[i].value := value;
    freq_array[i].frequency := 0;
  end;
  freq_array[i].frequency := freq_array[i].frequency + 1;
end;

procedure FrequencyArray.Sort;
var
  i,j: integer;
  temp_freq: Frequency;
begin
  for i := 0 to high(freq_array)-1 do
    for j := i+1 to high(freq_array) do
    begin
      if freq_array[i].value > freq_array[j].value then
      begin
        temp_freq := freq_array[i];
        freq_array[i] := freq_array[j];
        freq_array[j] := temp_freq;
      end;
    end;

end;

function FrequencyArray.Statistics: Statistics;
var
  i,sum,count: longint;
  variance: real;
begin
  sum := 0;
  Statistics.sample_size:=0;
  max_freq := 0;
  for i := 0 to high(freq_array) do
  begin
    Statistics.sample_size += freq_array[i].frequency;
    sum += freq_array[i].frequency*freq_array[i].value;
    if freq_array[i].frequency > max_freq then
    begin
      max_freq := freq_array[i].frequency;
      Statistics.sample_mode := freq_array[i].value;
    end
  end;
  Statistics.avg := sum/Statistics.sample_size;

  count := 0;
  variance := 0;
  Statistics.sample_median := -1;
  for i := 0 to high(freq_array) do
  begin
    variance += sqr(freq_array[i].value - Statistics.avg)*freq_array[i].frequency;
    if Statistics.sample_median = -1 then
    begin
      count += freq_array[i].frequency;
      if count >= trunc(Statistics.sample_size/2) then
        Statistics.sample_median := freq_array[i].value;
    end;
  end;

  Statistics.standard_deviation := sqrt(variance/(Statistics.sample_size-1));
end;

procedure FrequencyArray.DisplayGraph(const xlabel,ylabel: string);
  var
    i: longint;
    scale: real;
begin
  scale := 55/max_freq;
  writeln;
  writeln(format('%5s|              %s',[xlabel,ylabel]));
  writeln(StringOfChar('-',55));
  for i:=0 to high(freq_array) do
    writeln(format('%4d |%s %d',[freq_array[i].value,StringOfChar('#',trunc(freq_array[i].frequency*scale)),
          freq_array[i].frequency]));
  writeln;
end;

procedure FrequencyArray.ShowResults(const heading,xlabel: string);
var
  s: Statistics;

begin
  writeln;
  writeln(heading);
  writeln;
  s := Statistics;
  writeln('  Sample size: ',s.Count());
  writeln('  Min ',xlabel,': ',freq_array[0].value);
  writeln('  Max ',xlabel,': ',freq_array[size-1].value);
  writeln('  Average: ',string(s.Average));
  writeln('  Median: ',s.Median);
  writeln('  Mode: ',s.Mode);
  writeln('  Standard Deviation: ',string(s.StandardDeviation));
  DisplayGraph(xlabel,'Frequency');
end;

function time_diff_in_tens_ns(start,finish : timespec): longint;
begin
  time_diff_in_tens_ns := round(((finish.tv_sec - start.tv_sec)*1000000000 + (finish.tv_nsec - start.tv_nsec))/10.0);
end;

type PFrequencyArray = ^FrequencyArray;

procedure DoTest(value: real; var time_freq,loop_freq: PFrequencyArray);
var
  i: longint;
  f: TFraction;
  start,finish: timespec;

begin
  clock_gettime(CLOCK_PROCESS_CPUTIME_ID,@start);
  for i := 1 to 1000 do
    f.fset(value);
  clock_gettime(CLOCK_PROCESS_CPUTIME_ID,@finish);
  time_freq^.increment(round(time_diff_in_tens_ns(start,finish)/1000));
  loop_freq^.increment(loops);
end;

procedure SingleTest(denominator: longint);
var
  time_freq,loop_freq: FrequencyArray;
  ptime_freq,ploop_freq: PFrequencyArray;
  i: longint;
begin
  ptime_freq := @time_freq;
  ploop_freq := @loop_freq;
  for i := 1 to denominator-1 do
    DoTest(i/denominator,ptime_freq,ploop_freq);

  time_freq.Sort;
  loop_freq.Sort;
  time_freq.ShowResults('Time (in tens of nanoseconds) to convert floating point to fraction','Time');
  loop_freq.ShowResults('Iterations to convert floating point to fraction','Loops');
end;

procedure RandomTest(nTests: longint);
var
  i: longint;
  time_freq,loop_freq: FrequencyArray;
  ptime_freq,ploop_freq: PFrequencyArray;

begin
  Randomize;
  ptime_freq := @time_freq;
  ploop_freq := @loop_freq;
  for i:= 1 to nTests do
    DoTest(Random(1000)/Random(1000),ptime_freq,ploop_freq);
  time_freq.Sort;
  loop_freq.Sort;
  time_freq.ShowResults('Time (in tens of nanoseconds) to convert floating point to fraction','Time');
  loop_freq.ShowResults('Iterations to convert floating point to fraction','Loops');
end;

procedure syntax;
var
  pgm: string;
begin
  pgm := paramstr(0);
  writeln('Syntax: ',pgm,' [-h | --help ]\n');
  writeln('        ',pgm,' [ [-s | --single] N] [ [-r | --random] N ]');
  writeln;
  writeln('        ',pgm);
  writeln;
  writeln('Where:  -h | --help prints this help message');
  writeln('        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)');
  writeln('        -r | --random N -- gather statistics running N tests using random values');
  writeln('        The default is to run a single test using 1000 as denominator and 1000 random tests');
  writeln('Examples');
  writeln('   1) To run default case');
  writeln('      ',pgm);
  writeln('   2) To run single test using denominator of 100000');
  writeln('      ',pgm,' -s 100000');
  writeln('   3) To run a minimum of 30000 random test');
  writeln('      ',pgm,' -r 30000');
  writeln('   4) To run a single test using denominator of 100000 and a minimum of 30000 random test');
  writeln('      ',pgm,' --single 100000 --random 30000');

  writeln;
  writeln;
end;

var
  needHelp : boolean;
  c: char;
  optionindex,denominator,maxTests : Longint;
  options : array[1..3] of TOption = (
      ( name:'help';has_arg:0;flag:nil;value:'h' ),
      ( name:'single';has_arg:1;flag:nil;value:'s' ),
      ( name:'random';has_arg:1;flag:nil;value:'r' )
    );

begin
  needHelp := false;
  denominator := -1;
  maxTests := -1;
  if paramcount > 0 then
  begin
    repeat
      c:=getlongopts('hs:r:',@options[1],optionindex);
      case c of
        'h','?',':' : needHelp := true;
        's' : denominator := StrToInt(optarg);
        'r' : maxTests  := StrToInt(optarg);
      end; { case }
    until c=endofoptions;
    if needHelp then
      syntax
    else
    begin
      if denominator > 0 then
        SingleTest(denominator);
      if maxTests > 0 then
        RandomTest(maxTests);
    end;
  end
  else
  begin
    SingleTest(1000);
    RandomTest(1000);
  end;
end.
