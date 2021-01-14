#include "Fraction.bi"
#include "crt/stdlib.bi"
#include "vbcompat.bi"
#include "clock.bi"

Type Statistics
    average_ as Double
    standard_deviation_ as Double
    size_ as Integer
    median_ as Integer
    mode_ as Integer

    Declare Constructor()
    declare Property Average as MixedFraction
    declare Property StandardDeviation as MixedFraction
    declare Property Size() as Integer
    declare Property Median() as Integer
    declare Property Mode() as Integer
end Type

Constructor Statistics()
  average_ = 0
  standard_deviation_ = 0
  size_ = 0
  median_ = -1
  mode_ = 0
end Constructor

Property Statistics.Average() as MixedFraction
  Property = MixedFraction(average_)
End Property

Property Statistics.StandardDeviation() as MixedFraction
  Property = MixedFraction(standard_deviation_)
End Property

Property Statistics.Size() as Integer
  Property = size_
End Property

Property Statistics.Median() as Integer
  Property = median_
End Property

Property Statistics.Mode() as Integer
  Property = mode_
End Property

Type Frequency
  value as integer
  freq as integer
  Declare Constructor()
  Declare Constructor(ByRef o as Frequency)
end Type

Constructor Frequency()
  value = 0
  freq = 0
end Constructor

Constructor Frequency(ByRef o as Frequency)
  value = o.value
  freq = o.freq
end Constructor

Type FrequencyArray
  private:
    as Integer maxFreq
    as Frequency array(Any)
  public:
    declare Constructor()
    Declare Sub Sort()
    Declare Sub Increment(ByVal v as integer)
    Declare Sub DisplayGraph(ByRef xlabel as const string,ByRef ylabel as const string)
    Declare Sub ShowResults(ByRef heading as const string, ByRef xlabel as const string)
    Declare Function Stats() as Statistics
end Type

Constructor FrequencyArray()

end Constructor

Function FrequencyCompare(lhs as any ptr,rhs as any ptr) as long
  dim as Frequency ptr plhs = lhs
  dim as Frequency ptr prhs = rhs
  if plhs->value < prhs->value then
    return -1
  end if
  if plhs->value > prhs->value then
    return 1
  end if
  return 0
end Function

Sub FrequencyArray.Sort()
  qsort(@array(0),UBound(array)+1,sizeof(Frequency),@FrequencyCompare)
end Sub

Sub FrequencyArray.Increment(ByVal v as Integer)
  Dim as Boolean Found = false
  Dim as Integer i
  for i = 0 to ubound(array)
    if array(i).value = v then
      found = true
      exit for
    end if
  next i
  if not found then
    ReDim Preserve array(ubound(array)+1)
    array(i).value = v
    array(i).freq = 0
  end if
  array(i).freq += 1
End Sub

'' Would like to use "begin" and "end" except "end" is a keyword
#define first(a) @a(0)
#define last(a) @a(ubound(a))
Function FrequencyArray.Stats() as Statistics
  dim as Statistics s
  dim as Double sum = 0
  dim as Frequency ptr i
  maxFreq = 0
  s.size_ = 0
  for i = first(array) to last(array)
    s.size_ += i->freq
    sum+=i->value*i->freq
    if i->freq > maxFreq then
      maxFreq = i->freq
      s.mode_ = i->value
    end if

  next i
  s.average_ = MixedFraction(sum/s.size_).Round(100)

  '' Get median and variance
  dim as double variance = 0
  dim as Integer count = 0
  for i = first(array) to last(array)
    variance +=(i->value-s.average_)^2*i->freq
    if(s.median_ = -1) then
      count += i->freq
      if count >= s.size_\2 then
        s.median_=i->value
      end if
    end if
  next i

  '' standard deviation
  s.standard_deviation_ = MixedFraction(sqr(variance/(s.size_-1))).Round(100)
  return s
End Function

#define TERMINAL_COLUMNS 50
Sub FrequencyArray.DisplayGraph(ByRef xlabel as const String, ByRef ylabel as const String)
  print ""
  print using " \   \|       &";xlabel;ylabel
  print string(TERMINAL_COLUMNS,"-")
  dim as Double scale = TERMINAL_COLUMNS/maxFreq
  if scale > 1 then
    scale = 1
  end if
  for i as Frequency Ptr = first(array) to last(array)
    dim as String bars = "|"
    dim as Integer height = int(i->freq*scale)
    if height > 0 then
      bars = string(height,"#")
    end if
    print using " #### | & &";i->value;bars;i->freq
  next i
  print ""
End Sub

Sub FrequencyArray.ShowResults(Byref heading as const String, ByRef xlabel as const String)
  Dim as Statistics s = Stats()
  print ""
  print heading
  Print using "  Min &: &";xlabel;(first(array))->value
  Print using "  Max &: &";xlabel;(last(array))->value
  print using "  Sample size: &";s.Size
  print using "  Average: &";str(s.Average)
  print using "  Media: &";s.Median
  print using "  Mode: &";s.Mode
  print using "  Standard Deviation: &";str(s.StandardDeviation)
  DisplayGraph(xlabel,"Frequency")
End Sub

Sub DoTest(ByVal value as Double,ByRef timeFreq as FrequencyArray,ByRef loopFreq as FrequencyArray)
  Dim f as Fraction
  Dim as LongInt start,finish
  start = clock_gettime_in_ns(CLOCK_PROCESS_CPUTIME_ID)
  '' Hope the compiler optimization disables this loop
  for i as Integer = 1 to 100
    f=value
  next i
  finish = clock_gettime_in_ns(CLOCK_PROCESS_CPUTIME_ID)
  timeFreq.Increment(int((finish - start)/1000))
  loopFreq.Increment(Fraction.Loops)
end Sub

Sub SingleTest(ByVal denominator as Integer)
  Dim as FrequencyArray timeFreq,loopFreq
  for i as integer = 1 to denominator-1
    DoTest(i/denominator,timeFreq,loopFreq)
  next i
  timeFreq.Sort()
  loopFreq.Sort()
  timeFreq.ShowResults("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","time")
  loopFreq.ShowResults("Number of iterations to convert floating point to fraction","Loops")
end Sub

sub RandomTest(ByVal nTests as Integer)
  Dim as Double values(nTests)
  Dim as integer n=0
  dim as Double v
  Randomize, Now()
  while n < nTests
    v = Rnd*10000
    dim as Boolean found = false
    for i as integer = 0 to n-1
      if(abs(v-values(i)) < Fraction.Epsilon) then
        found = true
        exit for
      end if
    next i
    if not found then
      values(n)=v
      n += 1
    end if
  wend
  Dim as FrequencyArray timeFreq,loopFreq
  for i as integer = 0 to nTests-1
    DoTest(values(i),timeFreq,loopFreq)
  next i
  timeFreq.Sort()
  loopFreq.Sort()
  timeFreq.ShowResults("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","time")
  loopFreq.ShowResults("Number of iterations to convert floating point to fraction","Loops")

end Sub

''SingleTest(1000)
RandomTest(1000)
