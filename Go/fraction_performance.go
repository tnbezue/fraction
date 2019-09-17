package main

import ("fmt"; "time";. "fraction"; "math"; "strings";"sort"; "math/rand"; "flag" ; "os")

type Statistics struct {
  average float64
  standard_deviation float64
  size int
  median int
  mode int
  maxFreq int
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

type FrequencyArray [] Frequency

/* Sorting interface functions */
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

  // Calculate sample size, sum, mode, and average
  var i,sum int
  sum = 0
  s.maxFreq =0
  s.size=0
  for i=0; i < fa.Len(); i++ {
    s.size+=(*fa)[i].frequency
    sum+=(*fa)[i].frequency*(*fa)[i].value
    if((*fa)[i].frequency > s.maxFreq) {
      s.maxFreq=(*fa)[i].frequency
      s.mode=(*fa)[i].value
    }
  }
  s.average = float64(sum)/float64(s.size)

  // Get median and variance
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

  // standard deviation
  s.standard_deviation = math.Sqrt(variance/float64(s.size-1))
  return s
}

var terminalCols int = 50
func(fa *FrequencyArray) DisplayGraph(xlabel string,ylabel string,maxValue int) {
  fmt.Printf("\n%v|                   %v\n",xlabel,ylabel)
  fmt.Println(strings.Repeat("-",terminalCols+10))
  var scale float64 = float64(terminalCols)/float64(maxValue)
  var i int
  for i=0; i < fa.Len(); i++ {
    var height int = int(math.Round(scale*float64((*fa)[i].frequency)))
//    fmt.Println((*fa)[i].value,"|",strings.Repeat("#",height)," ",(*fa)[i].frequency)
    fmt.Printf("%4d |%s %d\n",(*fa)[i].value,strings.Repeat("#",height),(*fa)[i].frequency)
  }
}

func (fa *FrequencyArray) ShowResults(xlabel string) {
  fmt.Println("Max ",xlabel,": ",(*fa)[fa.Len()-1].value)
  s := fa.Statistics();
  fmt.Println("Sample size: ",s.size)
  fmt.Println("Average: ",s.Average().MixedString())
  fmt.Println("Median: ",s.median)
  fmt.Println("Mode: ",s.mode)
  fmt.Println("Standard Deviation: ",s.StandardDeviation().MixedString())
  fa.DisplayGraph(xlabel,"Frequency",s.maxFreq)
}

func DoTest(denominator int,time_freq *FrequencyArray,loop_freq *FrequencyArray) {
  var i int
  var f Fraction
  for i=0; i < denominator; i++ {
    var value float64 = float64(i)/float64(denominator)
    start := time.Now()
    f.Set(value)
    elapsed := time.Now().Sub(start)
    if(i>0) {
      time_freq.Increment(int(math.Round(float64(elapsed.Nanoseconds())/100.0)))
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
  fmt.Println("")
  loop_freq.ShowResults("Loops")
}

func RandomTest(minTests int) {
  rand.Seed(time.Now().UnixNano())
  var denominators [] int
  var nTests int = 0
  for nTests < minTests {
    var denominator int = rand.Intn(minTests+100)
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
  fmt.Println("")
  loop_freq.ShowResults("Loops")
}

func Syntax() {
  fmt.Println("Syntax: ",os.Args[0]," -h");
  fmt.Println("        ",os.Args[0]," -s N");
  fmt.Println("        ",os.Args[0]," -r N");
  fmt.Println("        ",os.Args[0]," -s N -r N");
  fmt.Println("        ",os.Args[0],"\n");
  fmt.Println("Where:  -h prints this help message");
  fmt.Println("        -s N -- gather statistics using N as denominator (runs tests using fractions 1/N to (N-1)/N)");
  fmt.Println("        -r N -- gather statistics running a minimum of N tests using random denominators");
  fmt.Println("        No options -- Run the default case of a single test using 1000 as denominator and 1000 minimum random tests\n");
  fmt.Println("Examples");
  fmt.Println("   1) To run default case");
  fmt.Println("      ",os.Args[0],"\n");
  fmt.Println("   2) To run single test using denominator of 100000");
  fmt.Println("      ",os.Args[0]," -s 100000\n");
  fmt.Println("   3) To run a minimum of 30000 random test");
  fmt.Println("      ",os.Args[0]," -r 30000\n");
  fmt.Println("   4) To run a single test using denominator of 100000 and a minimum of 30000 random test");
  fmt.Println("      ",os.Args[0]," -s 100000 -r 30000\n");
}

func main() {
  args := os.Args
  if len(args) > 1 {
    fs := flag.NewFlagSet("fraction_performance", flag.ExitOnError)
    fs.Usage = Syntax
//    h := fs.Bool("h", false, "Shows detailed help.")
    var singleDenominator int = 0
    var minTest int = 0
    fs.IntVar(&singleDenominator,"s",0,"Run single test using denominator specified")
    fs.IntVar(&minTest,"r",0,"Run test using random denominators for a minimum of the test specified")
    if err := fs.Parse(os.Args[1:]); err != nil {
                os.Exit(100)
        }
        //flag.Parse()
    args := fs.Args()
    if len(args) > 0 {
      fmt.Println("\n****Invalid arguments specified***")
      Syntax()
      os.Exit(100)
    }
    if singleDenominator > 0 {
      SingleTest(singleDenominator)
    }
    if minTest > 0 {
      RandomTest(minTest)
    }
  } else {
    SingleTest(1000)
    RandomTest(1000)
  }
}
