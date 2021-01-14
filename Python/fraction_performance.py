#!/usr/bin/python3
import sys
import fraction
import math
import time
import random

class Statistics:
  sample_size = 0
  median = 0
  mode = 0
  average = 0.0
  standard_deviation = 0.9

  def __init__(self):
    self.sample_size = 0
    self.median = 0
    self.mode = 0
    self.average = 0.0
    self.standard_deviation = 0.9

  def Size(self):
    return self.sample_size

  def Average(self):
    return fraction.Fraction(self.average).round(100).to_mixed_string()

  def Median(self):
    return self.median

  def Mode(self):
    return self.mode

  def StandardDeviation(self):
    return fraction.Fraction(self.standard_deviation).round(100).to_mixed_string()

class FrequencyArray:
  frequencies = []

  def __init__(self):
    self.frequencies = [] # Array of 2 item array.

  def increment(self,value):
    pos=-1
    for i in range(len(self.frequencies)):
      if(self.frequencies[i][0]) == value:
        pos=i
        break
    if pos == -1:
      pos = len(self.frequencies)
      self.frequencies.append([value,0])
    self.frequencies[pos][1]+=1

  def Size(self):
    return len(self.frequencies)

  def Sort(self):
    self.frequencies.sort()

  def Statistics(self):
    total=0
    stats = Statistics()
    stats.mode = 0
    for freq in self.frequencies:
      stats.sample_size += freq[1]
      total += freq[0]*freq[1]
      if freq[1] > stats.mode:
        stats.mode=freq[1]
    stats.average = float(total)/float(stats.sample_size)

    var=0
    count=0
    stats.median=-1
    for freq in self.frequencies:
      var += (stats.average-freq[0])*(stats.average-freq[0])*freq[1]
      if stats.median == -1:
        count += freq[1]
        if count > stats.sample_size/2:
          stats.median=freq[0]

    stats.standard_deviation=math.sqrt(var/(stats.sample_size-1))
    return stats

  def DisplayGraph(self,xlabel,ylabel,maxFreq):
    print("\n  ",xlabel,"|              ",ylabel)
    scale=50/maxFreq
    for freq in self.frequencies:
      print(' ',freq[0],str('#'*int(scale*freq[1])),freq[1])
    print

  def ShowResult(self,heading,xlabel):
    print("\n{}".format(heading))
    freq = self.frequencies[0]
    print("  Min {}: {}".format(xlabel,freq[0]))
    freq = self.frequencies[len(self.frequencies)-1]
    print("  Max {}: {}".format(xlabel,freq[0]))
    stats = self.Statistics()
    print("  Sample size:",stats.Size())
    print("  Average:",stats.Average())
    print("  Median:",stats.Median())
    print("  Mode:",stats.Mode())
    print("  Standard Deviation:",stats.StandardDeviation())
    self.DisplayGraph(xlabel,"Frequency",stats.Mode())


def DoTest(value,time_freq,loop_freq):
  f = fraction.Fraction()
  start=time.clock_gettime_ns(time.CLOCK_PROCESS_CPUTIME_ID)
  for i in range(0,100):
    f.set(value)
  finish=time.clock_gettime_ns(time.CLOCK_PROCESS_CPUTIME_ID)
  time_freq.increment(int((finish-start)/10/100))
  loop_freq.increment(fraction.Fraction.Loops())

def SingleTest(denominator):
  time_freq=FrequencyArray()
  loop_freq=FrequencyArray()
  for i in range(1,denominator):
    DoTest(i/denominator,time_freq,loop_freq)
  time_freq.Sort()
  time_freq.ShowResult("Time","Time")
  loop_freq.Sort();
  loop_freq.ShowResult("Loops","Loops")

def RandomTest(nTests):
  random.seed(time.time())
  time_freq=FrequencyArray()
  loop_freq=FrequencyArray()
  values = []
  iTest=0
  while iTest < nTests:
    value = random.random()*random.randrange(1,100)
    found = False
    for val in values:
      if abs(val - value) < 5e-6:
        found = True
        break
    if not found:
      values.append(value)
      iTest+=1
  for val in values:
    DoTest(val,time_freq,loop_freq)
  time_freq.Sort()
  time_freq.ShowResult("Time","Time")
  loop_freq.Sort();
  loop_freq.ShowResult("Loops","Loops")

SingleTest(1000)
#RandomTest(1000)
