#!/usr/bin/env -S ruby -I.
require 'getoptlong'

def syntax(pgm)
  puts "\nSyntax: #{pgm} [-h | --help ] [-n | --native] [ [-s | --single] N] [ [-r | --random] N ]"
  puts "\nWhere:  -h | --help prints this help message"
  puts "        -n | --native -- use native (ruby) version rather than C extension"
  puts "        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)"
  puts "        -r | --random N -- gather statistics running a minimum of N tests using random floating point numbers"
  puts "        The default is to run a single test using 1000 as denominator and 1000 minimum random tests\n"
  puts "\nExamples"
  puts "   1) To run default case"
  puts "      #{pgm}"
  puts "   2) To run single test using denominator of 100000"
  puts "      #{pgm} -s 100000"
  puts "   3) To run 30000 random test using the native (ruby) version\n"
  puts "      #{pgm} -n -r 30000\n"
  puts "   4) To run a single test using denominator of 100000 and a minimum of 30000 random test\n"
  puts "      #{pgm} --single 100000 --random 30000\n\n"
  exit(0)
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--single', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--random', '-r', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--native', '-n', GetoptLong::NO_ARGUMENT]
)

denominator=0
denominator_specified=false
nTests=0
nTests_specified=false
native = false
opts.each do |opt,arg|
  case opt

    when '--help'
      syntax($0)

    when '--single'
      denominator=arg.to_i
      denominator_specified = true

    when '--random'
      nTests = arg.to_i
      nTests_specified=true

    when '--native'
      native = true
  end
end

if native
  require 'Fraction'
else
  require 'fraction'
end

if not denominator_specified and not nTests_specified
  denominator=1000
  nTests=1000
end

class Statistics
  attr_accessor :average,:standard_deviation,:size,:median,:mode
end

class Frequency
  include Comparable
  attr_accessor :value,:frequency

  def initialize(v)
    @value=v
    @frequency=1
  end

  def <=>(other)
    return @value <=> other.value
  end

end

class FrequencyArray
  def initialize
    @array = Array.new
  end

  def sort
    @array.sort!
  end

  def increment(value)
    temp = Frequency.new(value)
    idx = @array.index(temp)
    if idx == nil
      @array << temp
    else
      @array[idx].frequency+=1
    end
  end

  def statistics
    s = Statistics.new
    sum = 0
    s.size = 0
    @max_freq = 0
    @array.each do |entry|
      s.size += entry.frequency
      sum += entry.frequency*entry.value
      if(entry.frequency > @max_freq)
        @max_freq = entry.frequency
        s.mode = entry.value
      end
    end
    s.average = sum.to_f/s.size

    var = 0
    count = 0
    s.median = -1
    @array.each do |entry|
      var += (entry.value-s.average)**2*entry.frequency
      if s.median == -1
        count += entry.frequency
        if count > s.size/2
          s.median = entry.value
        end
      end
    end

    s.standard_deviation = MixedFraction.new(Math.sqrt(var.to_f/(s.size-1)))
    s.standard_deviation.round!(100)
    s.average = MixedFraction.new(s.average)
    s.average.round!(100)
    return s
  end

  def display_graph(xlabel,ylabel)
    puts "\n  %5s|                      %s" % [ xlabel,ylabel]
    puts "-"*70
    scale = 60.0/@max_freq
    scale = 1 if scale > 1
    @array.each do |entry|
      ch = "#"
      height = (entry.frequency*scale).round()
      if height == 0
        ch='|'
        height = 1
      end
      puts "  %4d | %s %d" % [entry.value,ch*height,entry.frequency]
    end
    puts ""
  end

  def show_results(heading,xlabel)
    s = self.statistics
    puts "\n",heading
    puts "  Min: #{@array[0].value}"
    puts "  Max: #{@array[@array.size-1].value}"
    puts "  Sample size: #{s.size}"
    puts "  Average: #{s.average}"
    puts "  Median: #{s.median}"
    puts "  Mode: #{s.mode}"
    puts "  Standard Deviation: #{s.standard_deviation}"
    display_graph(xlabel,"Frequency")
  end

  def dump
    @array.each { |item| puts "#{item.value} #{item.frequency}"}
  end
end

def do_test(value,time_freq,loop_freq)
  start = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
  f = Fraction.new()
  n=0
  100.times { |i|
    f.set(value)
    n +=1
  }
  finish = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
  time_freq.increment(((finish-start)*1000000).to_i)
  loop_freq.increment(Fraction.loops)
end

def single(denominator)
  time_freq = FrequencyArray.new
  loop_freq = FrequencyArray.new
  (1..(denominator-1)).each { |i| do_test(i.to_f/denominator,time_freq,loop_freq) }
  time_freq.sort
  loop_freq.sort
  time_freq.show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time")
  loop_freq.show_results("Number of iterations to convert floating point to fraction","Loops")
end

def random(nTests)
  r=Random.new
  values = Array.new
  while values.size < nTests
    value = r.rand(nTests)*r.rand
    values << value if values.index(value) == nil
  end
  time_freq = FrequencyArray.new
  loop_freq = FrequencyArray.new
  values.each {|value| do_test(value,time_freq,loop_freq)}
  time_freq.sort
  loop_freq.sort
  time_freq.show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time")
  loop_freq.show_results("Number of iterations to convert floating point to fraction","Loops")
end

Fraction.epsilon = 5.0e-6
single(denominator) if denominator > 2
random(nTests) if nTests > 2
