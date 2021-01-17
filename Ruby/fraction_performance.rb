require 'fraction'

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
    puts "  %5s|                      %s" % [ xlabel,ylabel]
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
    puts heading
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
  loop_freq.increment($fraction_loops)
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

random(1000)
