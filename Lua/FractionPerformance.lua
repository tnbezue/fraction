require 'Fraction'
require "perf_utils"

function println(fmt,...)
  print(string.format(fmt,...))
end

Frequency = { value=0, frequency = 0 }
Frequency.__index = Frequency

function Frequency:new(value)
  o = { }
  setmetatable(o, Frequency)
  o.value = value
  o.frequency = 1
  return o
end

Statistics = { average = MixedFraction:new(), standard_deviation = MixedFraction:new(),
    size = 0, median = -1, mode = 0, maxFreq = 0 }
Statistics.__index = Statistics

function Statistics:new()
  o = {}
  setmetatable(o, Statistics)
  return o
end

FrequencyArray = { }
FrequencyArray.__index = FrequencyArray

function FrequencyArray:new()
  o = { }
  setmetatable(o, FrequencyArray)
  o.array = {}
  return o
end

function FrequencyArray:increment(value)
  local n=#self.array
  for i = 1,n do
    if(self.array[i].value == value) then
      self.array[i].frequency=self.array[i].frequency+1
      return
    end
  end
  table.insert(self.array,Frequency:new(value))
end

function FrequencyArray:statistics()
  local sum=0
  local stats=Statistics:new()
  for _,v in ipairs(self.array) do
    stats.size = stats.size + v.frequency
    sum = sum + v.value*v.frequency;
    if(v.frequency > stats.maxFreq) then
      stats.maxFreq = v.frequency
      stats.mode = v.value
    end
  end
  local avg = sum/stats.size
  stats.average:set(avg)
  stats.average=stats.average:round(100)

  local var = 0
  local count = 0
  for _,v in ipairs(self.array) do
    var = var + ((avg - v.value)^2)*v.frequency
    if(stats.median == -1) then
      count = count + v.frequency
      if(count >= math.floor(stats.size/2)) then
        stats.median = v.value
      end
    end
  end

  stats.standard_deviation:set(math.sqrt(var/(stats.size - 1)))
  stats.standard_deviation = stats.standard_deviation:round(100)
  return stats
end

function FrequencyArray:sort()
  table.sort(self.array, function(left,right) return left.value < right.value end)
end

function FrequencyArray:displayGraph(xlabel,ylabel,maxFreq)
  println("\n %.5s |             %s",xlabel,ylabel)
  println(string.rep("-",70))
  local scale = 60 / maxFreq
  if(scale > 1) then
    scale = 1
  end
  for _,v in ipairs(self.array) do
    local n = math.floor(scale*v.frequency)
    local ch = "#"
    if(n == 0) then
      n = 1
      ch = "|"
    end
    println("%6d | %s %d",v.value,string.rep(ch,n),v.frequency)
  end
  print("")
end

function FrequencyArray:show_results(heading,xlabel)
  local stats = self:statistics()
  local n = #self.array
  println("\n%s",heading)
  println(" Min %s: %d",xlabel,self.array[1].value)
  println(" Max %s: %d",xlabel,self.array[n].value)
  println(" Sample size: %d",stats.size)
  println(" Average: %s",stats.average)
  println(" Median: %d",stats.median)
  println(" Mode: %d",stats.mode)
  println(" Standard Deviation: %s",stats.standard_deviation)
  self:displayGraph(xlabel,"Frequency",stats.maxFreq)
end

function DoTest(value,time_freq,loop_freq)
  local f=Fraction:new()
  local start=clock_gettime_in_ns(CLOCK_PROCESS_CPUTIME_ID)
  for i=1,100 do
    f:set(value)
  end
  local finish=clock_gettime_in_ns(CLOCK_PROCESS_CPUTIME_ID)
  -- divide by 1000 because divide by number of loops (100) then divide by 10 for 10s of nanoseconds
  time_freq:increment(math.floor(((finish-start)/1000.0)+0.5))
  loop_freq:increment(Fraction:loops())
end

function SingleTest(denominator)
  local time_freq = FrequencyArray:new()
  local loop_freq = FrequencyArray:new()
  for i = 1,denominator-1 do
    DoTest(i/denominator,time_freq,loop_freq)
  end

  time_freq:sort()
  time_freq:show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time ")
  loop_freq:sort()
  loop_freq:show_results("Number of iterations to convert floating point to fraction","Loops")
end

function RandomTest(nTests)
  local values = {}
  while (nTests > 0) do
    local value = math.random()*math.random(math.random(1000))
    local found=false
    for _,v in ipairs(values) do
      if(math.abs(v - value) < Fraction.epsilon) then
        found = true
        break
      end
    end
    if(found == false) then
      table.insert(values,value)
      nTests = nTests - 1
    end
  end
  local time_freq = FrequencyArray:new()
  local loop_freq = FrequencyArray:new()
  for _,v in ipairs(values) do
    DoTest(v,time_freq,loop_freq)
  end

  time_freq:sort()
  time_freq:show_results("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time ")
  loop_freq:sort()
  loop_freq:show_results("Number of iterations to convert floating point to fraction","Loops")
end

local singleTestDenominator = 0
local randomNTest = 0
local params = {...}
local nparams = #params
if(nparams > 0) then
  local i = 1
  while i <= nparams do
    if params[i] == "-s" or params[i] == "--single" then
      if i < nparams then
        i = i + 1
        singleTestDenominator = tonumber(params[i])
      else
        print("Invalid argument")
        return
      end
    else
      if params[i] == "-r" or params[i] == "--random" then
        if i < nparams then
          i = i + 1
          randomNTest = tonumber(params[i])
        else
          print("Invalid argument")
          return
        end
      else
        print("Invalid argument")
        return
      end
    end
    i = i + 1
  end
else
  singleTestDenominator = 1000
  randomNTest = 1000
end

function syntax()
end

if singleTestDenominator > 0 then SingleTest(singleTestDenominator) end
if randomNTest > 0 then RandomTest(randomNTest) end
