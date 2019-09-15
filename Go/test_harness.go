package test_harness

import ( "fmt"; "strconv" )

type TestFunc func()

var nPass int32
var nFail int32
var nTotalPass int32
var nTotalFail int32

func summary() {
  fmt.Printf("   Passed: %v\n   Failed: %v\n\n",nPass,nFail)
}

func FinalSummary() {
  if nFail > 0 || nPass > 0 {
    summary();
  }
  nTotalPass+=nPass
  nTotalFail+=nFail
  fmt.Printf("Total Passed: %v\nTotal Failed: %v\n",nTotalPass,nTotalFail)
}

func TestCase(msg string) {
  if nFail > 0 || nPass > 0 {
    summary();
  }
  nTotalPass+=nPass
  nTotalFail+=nFail
  nPass=0
  nFail=0
  fmt.Println(msg)
}

func Test(msg string,rc bool) {
  var result string
  if rc {
    result="pass"
    nPass++
  } else {
    result="fail"
    nFail++
  }
  fmt.Printf("   %v ... %v\n",msg,result)
}

//var Tests []TestFunc

func RunTests(argv [] string,tests [] TestFunc) {
  if len(argv)> 0 {
    nTests := len(tests)
    for _,istr := range argv {
      i,_ := strconv.Atoi(istr)
      if i<nTests  {
        tests[i]()
      } else {
        fmt.Println("No test for ",i)
      }
    }
  } else {
    for _,testfunc := range tests {
      testfunc()
    }
  }
}
