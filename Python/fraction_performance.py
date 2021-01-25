#!/usr/bin/python3

import sys
import math
import time
import random
import getopt

def usage():
  print("\nSyntax: {} [-h | --help ] [-n | --native] [ [-s | --single] N] [ [-r | --random] N ]".format(sys.argv[0]))
  print( "\nWhere:  -h | --help prints this help message")
  print( "        -n | --native -- use native (Python) version rather than C extension")
  print( "        -s | --single N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)")
  print( "        -r | --random N -- gather statistics running N tests using random floating point numbers")
  print( "        The default is to run a single test using 1000 as denominator and 1000 random tests\n")
  print( "Examples")
  print( "   1) To run default case  (use denominator = 1000 and 1000 random tests)")
  print( "      {}\n".format(sys.argv[0]))
  print( "   2) To run single test using denominator of 100000")
  print( "      {} -s 100000\n".format(sys.argv[0]))
  print( "   3) To run 30000 random test using the native (Python) version\n")
  print( "      {} -n -r 30000\n".format(sys.argv[0]))
  print( "   4) To run a single test using denominator of 100000 and 30000 random test")
  print( "      {} --single 100000 --random 30000\n".format(sys.argv[0]))

  sys.exit(0)

denominator = 1000
nTests = 1000
use_native = False
if len(sys.argv) > 1:
  denominator = 0
  nTests = 0

  try:
    opts,should_be_empty = getopt.getopt(sys.argv[1:],"hns:r:",["help","native","single=","random="])
  except getopt.GetoptError as err:
    print(err)
    usage()

  if len(should_be_empty) > 0:
    print("Invalid options specified")
    usage()

  use_native = False
  for opt, value in opts:
    if opt in ["-h","--help"]:
      usage()
    elif opt in ["-n","--native"]:
      use_native = True
    elif opt in ["-s","--single"]:
      denominator = int(value)
    elif opt in ["-r","--random"]:
      nTests = int(value)

if use_native:
  from fraction_native import Fraction,MixedFraction
else:
  from fraction import Fraction,MixedFraction

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
    return str(round(MixedFraction(self.average),100))

  def Median(self):
    return self.median

  def Mode(self):
    return self.mode

  def StandardDeviation(self):
    return str(round(MixedFraction(self.standard_deviation),100))

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
    print("\n{:5}|              {}".format(xlabel,ylabel))
    scale=50/maxFreq
    for freq in self.frequencies:
      ch = "#"
      height = int(scale*freq[1])
      if height==0:
        height=1
        ch="|"
      print("{:4} |{} {}".format(freq[0],(ch*height),freq[1]))

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
  f = Fraction()
  start=time.clock_gettime_ns(time.CLOCK_PROCESS_CPUTIME_ID)
  for i in range(0,100):
    f.set(value)
  finish=time.clock_gettime_ns(time.CLOCK_PROCESS_CPUTIME_ID)
  time_freq.increment(int((finish-start)/10/100))
  loop_freq.increment(Fraction.Loops())

def SingleTest(denominator):
  time_freq=FrequencyArray()
  loop_freq=FrequencyArray()
  for i in range(1,denominator):
    DoTest(i/denominator,time_freq,loop_freq)
  time_freq.Sort()
  time_freq.ShowResult("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time")
  loop_freq.Sort();
  loop_freq.ShowResult("Number of iterations to convert floating point to fraction","Loops")

def RandomTest(nTests):
  random.seed(time.time())
  time_freq=FrequencyArray()
  loop_freq=FrequencyArray()
  for i in range(nTests):
    DoTest(random.random()*random.randrange(1,100),time_freq,loop_freq)

  time_freq.Sort()
  time_freq.ShowResult("Time taken to convert floating point to faction (time is in 10s of nanoseconds)","Time")
  loop_freq.Sort();
  loop_freq.ShowResult("Number of iterations to convert floating point to fraction","Loops")

if denominator > 2:
  SingleTest(denominator)

if nTests > 2:
  RandomTest(nTests)
