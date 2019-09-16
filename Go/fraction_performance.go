package main

import ("fmt"; "time";. "fraction"; "math"; "strings";"sort"; "math/rand")

type Statistics struct {
  average float64
  standard_deviation float64
  size int
  median int
  mode int
}

func(s Statistics) Average() Fraction {
  var avg Fraction
  avg.Set(s.average)
  avg = avg.Round(100)
  return avg
}

func(s Statistics) StandardDeviation() Fraction {
  var sd Fraction
  sd.Set(s.standard_deviation)
  sd = sd.Round(100)
  return sd
}

type Frequency struct {
  value int
  frequency int
}
/*
type FrequencyArray struct {
  size,maxFreq int
  freqArray [] Frequency
}
*/

type FrequencyArray [] Frequency

func(fa FrequencyArray) Len() int { return len(fa) }
func(fa FrequencyArray) Less(i,j int) bool { return fa[i].value < fa[j].value}
func(fa FrequencyArray) Swap(i,j int) { fa[i],fa[j] = fa[j],fa[i]}

func(fa *FrequencyArray) Increment(value int) {
  var i int
  for i = 0; i<fa.Len(); i++ {
    if (*fa)[i].value == value {
      break
    }
  }
  if i == fa.Len() {
    *fa = append(*fa,Frequency {value,0})
    (*fa)[i].value=value
  }
  (*fa)[i].frequency++
}

func(fa *FrequencyArray) Statistics() Statistics {
  var s Statistics
  var i,sum int
  sum = 0
//  var maxFreq int =0
  s.size=0
  for i=0; i < fa.Len(); i++ {
    s.size+=(*fa)[i].frequency
    sum+=(*fa)[i].frequency*(*fa)[i].value
/*    if(fa[i].frequency > maxFreq) {
      maxFreq=fa[i].frequency
    }*/
  }
  s.average = float64(sum)/float64(s.size)
  var variance float64 = 0.0
  var count int
  s.median=-1
  for i=0; i<fa.Len(); i++ {
    variance+=(float64((*fa)[i].value) - s.average)*(float64((*fa)[i].value) - s.average)*float64((*fa)[i].frequency)
    if s.median == -1 {
      count+=(*fa)[i].frequency
      if count >= s.size/2 {
        s.median=(*fa)[i].value
      }
    }
  }

  s.standard_deviation = math.Sqrt(variance/float64(s.size-1))
  return s
}

var terminalCols int = 50
func(fa *FrequencyArray) DisplayGraph(xlabel string,ylabel string) {
  fmt.Printf("\n%v|                   %v\n",xlabel,ylabel)
  fmt.Println(strings.Repeat("-",terminalCols+10))
  var scale float64 = float64(terminalCols)/float64(1000)
  var i int
  for i=0; i < fa.Len(); i++ {
    var height int = int(math.Round(scale*float64((*fa)[i].frequency)))
    fmt.Println((*fa)[i].value,"|",strings.Repeat("#",height)," ",(*fa)[i].frequency)
  }
}

func (fa *FrequencyArray) ShowResults(xlabel string) {
  fmt.Println(fa.Len())
  fmt.Println("Max ",xlabel,": ",(*fa)[fa.Len()-1].value)
  s := fa.Statistics();
  fmt.Println("Sample size: ",s.size)
  fmt.Println("Average: ",s.Average().MixedString())
  fmt.Println("Median: ",s.median)
  fmt.Println("Mode: ",s.mode)
  fmt.Println("Standard Deviation: ",s.StandardDeviation().MixedString())
  fa.DisplayGraph(xlabel,"Frequency")
}

func DoTest(denominator int,time_freq *FrequencyArray,loop_freq *FrequencyArray) {
  var i int
  var f Fraction
  for i=0; i < denominator; i++ {
    var value float64 = float64(i)/float64(denominator)
    start := time.Now()
    f.SetFloat(value)
    elapsed := time.Now().Sub(start)
    if(i>0) {
      time_freq.Increment(int(math.Round(float64(elapsed.Nanoseconds())/1000.0)))
      loop_freq.Increment(Loops)
    }
  }
}

func SingleTest(denominator int) {
  var time_freq FrequencyArray
  var loop_freq FrequencyArray
  DoTest(denominator,&time_freq,&loop_freq)
  sort.Sort(FrequencyArray(time_freq))
  sort.Sort(FrequencyArray(loop_freq))
  time_freq.ShowResults("t(us)")
  loop_freq.ShowResults("Loops")
}

func RandomTest(maxTests int) {
  rand.Seed(time.Now().UnixNano())
  var denominators [] int
  var nTests int = 0
  for nTests < maxTests {
    var denominator int = rand.Intn(maxTests+1000)
    var found bool = false
    for _,d := range denominators {
      if(d == denominator) {
        found=true
        break
      }
    }
    if !found {
      denominators=append(denominators,denominator)
      nTests += denominator-1
    }
  }

  var time_freq FrequencyArray
  var loop_freq FrequencyArray
  for _,denominator := range denominators {
    DoTest(denominator,&time_freq,&loop_freq)
  }
  sort.Sort(FrequencyArray(time_freq))
  sort.Sort(FrequencyArray(loop_freq))
  time_freq.ShowResults("t(us)")
  loop_freq.ShowResults("Loops")
}

func main() {
//  SingleTest(1000)
  RandomTest(1000)
}
