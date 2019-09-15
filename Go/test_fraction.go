package main

import ( "fmt";. "fraction";. "test_harness";"os" )

func testGCD() {
  TestCase("Greatest Common Divisor")
  var gcd_test_data = [][]int64 { { 0,2,2},{ 10,1,1},{ 105,15,15},{ 10,230,10},{ 28,234,2}, {872452914,78241452,6 } }
//  var n int = len(gcd_test_data)
  for _,data := range gcd_test_data {
    msg := fmt.Sprintf("GCD(%v,%v)=%v",data[0],data[1],data[2])
    Test(msg,GCD(data[0],data[1])==data[2])
  }
}

func R(f Fraction,n int64,d int64) bool {
  return f.Numerator() == n && f.Denominator() == d
}

func test_fraction_set() {
  var f Fraction
  TestCase("Fraction Set long")
  var set_test_data = [][]int64 { {-10,-10,1} , {0,0,1}, {10,10,1}}
  for _,data := range set_test_data {
    msg := fmt.Sprintf("Set(%v)=(%v/%v)",data[0],data[1],data[2])
    f.Set(data[0])
    Test(msg,R(f,data[1],data[2]))
  }
}

func test_fraction_set_long_long() {
  var f Fraction
  TestCase("Fraction Set long")
  var set_ll_test_data = [][]int64 { { 0,1,0,1 }, {1,1,1,1}, {-2,3,-2,3}, {2,-3,-2,3}, {-2,-3,2,3},
      { 17179869183,68719476736, 17179869183,68719476736 },  { 68719476736,17179869183,68719476736,17179869183 } ,
     { -17179869183,68719476736,-17179869183,68719476736 }, { -68719476736,17179869183,-68719476736,17179869183 }, }
  for _,data := range set_ll_test_data {
    msg := fmt.Sprintf("Set(%v,%v)=(%v/%v)",data[0],data[1],data[2],data[3])
    f.Set(data[0],data[1]);
    Test(msg,R(f,data[2],data[3]))
  }

}

func test_fraction_set_mixed() {
  TestCase("Fraction Set Mixed")
  var f Fraction
  var set_mixed_test_data = [][]int64 { { -10,2,3,-32,3 }, {0,-2,3,-2,3}, {0,0,1,0,1}, {0,2,3,2,3}, {10,2,3,32,3},}
  for _,data := range set_mixed_test_data {
    msg := fmt.Sprintf("SetMixed(%v,%v,%v)=(%v/%v)",data[0],data[1],data[2],data[3],data[4])
    f.Set(data[0],data[1],data[2]);
    Test(msg,R(f,data[3],data[4]))
    fmt.Println(f)
  }
}

func test_fraction_set_float() {
  TestCase("Fraction Set float")
  var f Fraction
  var set_float_input = [] float64 { -2.5, -1.0, -0.06 , 0.0, 0.06, 1.0 , 2.5, 0.3, 0.33, 0.33333333 }
  var set_float_output = [][] int64 { {-5,2}, {-1,1}, { -3,50}, {0,1}, {3,50}, {1,1}, {5,2}, {3,10}, {33,100}, {1,3}}
  for i,data := range set_float_input {
    msg := fmt.Sprintf("Set(%v)=(%v,%v)",data,set_float_output[i][0],set_float_output[i][1])
    f.Set(data)
    Test(msg,R(f,set_float_output[i][0],set_float_output[i][1]))
  }
}

func test_fraction_plus_fraction() {
  TestCase("Fraction plus fraction")
  var f1,f2 Fraction
  var plus_data = [][] int64 { {0,1,0,1,0,1} , {0,1,1,1,1,1},{3,5,-2,9,17,45},
          {-2,8,-6,8,-1,1}, {7,3,10,7,79,21}, {-5,7,25,35,0,1}}
  for _,data := range plus_data {
    msg := fmt.Sprintf("(%v/%v) + (%v/%v) = (%v,%v)",data[0],data[1],data[2],data[3],data[4],data[5])
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    f3 := FractionPlusFraction(f1,f2)
    Test(msg,R(f3,data[4],data[5]))
  }
}

func test_fraction_minus_fraction() {
  TestCase("Fraction minus fraction")
  var f1,f2 Fraction
  var plus_data = [][] int64 { {0,1,0,1,0,1} , {0,1,1,1,-1,1},{3,5,-2,9,37,45},
          {-2,8,-6,8,1,2}, {7,3,10,7,19,21}, {-5,7,25,35,-10,7}}
  for _,data := range plus_data {
    msg := fmt.Sprintf("(%v/%v) - (%v/%v) = (%v,%v)",data[0],data[1],data[2],data[3],data[4],data[5])
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    f3 := FractionMinusFraction(f1,f2)
    Test(msg,R(f3,data[4],data[5]))
  }
}

func test_fraction_times_fraction() {
  TestCase("Fraction times fraction")
  var f1,f2 Fraction
  var plus_data = [][] int64 {{0,1,0,1,0,1} , {0,1,1,1,0,1},{3,5,-2,9,-2,15},
          {-2,8,-6,8,3,16}, {7,3,10,7,10,3}, {-5,7,25,35,-25,49} }
  for _,data := range plus_data {
    msg := fmt.Sprintf("(%v/%v) * (%v/%v) = (%v,%v)",data[0],data[1],data[2],data[3],data[4],data[5])
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    f3 := FractionTimesFraction(f1,f2)
    Test(msg,R(f3,data[4],data[5]))
  }
}

func test_fraction_divided_by_fraction() {
  TestCase("Fraction divided by fraction")
  var f1,f2 Fraction
  var plus_data = [][] int64 { {0,1,1,1,0,1},{3,5,-2,9,-27,10},
          {-2,8,-6,8,1,3}, {7,3,10,7,49,30}, {-5,7,25,35,-1,1} }
  for _,data := range plus_data {
    msg := fmt.Sprintf("(%v/%v) / (%v/%v) = (%v,%v)",data[0],data[1],data[2],data[3],data[4],data[5])
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    f3 := FractionDividedByFraction(f1,f2)
    Test(msg,R(f3,data[4],data[5]))
  }
}

func test_fraction_equality() {
  TestCase("Fraction Equality")
  var f1,f2 Fraction
  var eq_data = [][] int64 { { 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1},{-5,7,25,35,0}}
  for _,data := range eq_data {
    msg := fmt.Sprintf("(%v/%v) == (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionEqFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_inequality() {
  TestCase("Fraction Inequality")
  var f1,f2 Fraction
  var ne_data = [][] int64 {{ 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}}
  for _,data := range ne_data {
    msg := fmt.Sprintf("(%v/%v) != (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionNeFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_less_than() {
  TestCase("Fraction less than fraction")
  var f1,f2 Fraction
  var lt_data = [][] int64 { { 0,1,0,1,0}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,1}}
  for _,data := range lt_data {
    msg := fmt.Sprintf("(%v/%v) < (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionLtFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_less_than_equal() {
  TestCase("Fraction less than or equal fraction")
  var f1,f2 Fraction
  var le_data = [][] int64 {{ 0,1,0,1,1}, {0,1,1,2,1}, {2,3,-2,4,0}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,1} }
  for _,data := range le_data {
    msg := fmt.Sprintf("(%v/%v) <= (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionLeFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_greater_than() {
  TestCase("Fraction Greater than fraction")
  var f1,f2 Fraction
  var gt_data = [][] int64 {{ 0,1,0,1,0}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,0}, {1,3,1,3,0}, {-5,7,25,35,0} }
  for _,data := range gt_data {
    msg := fmt.Sprintf("(%v/%v) > (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionGtFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_greater_than_equal() {
  TestCase("Fraction greater than or equal")
  var f1,f2 Fraction
  var ge_data = [][] int64 {{ 0,1,0,1,1}, {0,1,1,2,0}, {2,3,-2,4,1}, {2,3,16,24,1}, {1,3,1,3,1}, {-5,7,25,35,0} }
  for _,data := range ge_data {
    msg := fmt.Sprintf("(%v/%v) >= (%v/%v) -- %v",data[0],data[1],data[2],data[3],data[4]==1)
    f1.Set(data[0],data[1])
    f2.Set(data[2],data[3])
    Test(msg,FractionGeFraction(f1,f2) == (data[4]==1))
  }
}

func test_fraction_abs() {
  TestCase("Fraction abs")
  var f1,f2 Fraction
  var abs_data = [][] int64 { {0,1,0,1}, {-1,1,1,1},{-30,2,15,1}, { 1,1,1,1}, {30,2,15,1}}
  for _,data := range abs_data {
    msg := fmt.Sprintf("(%v,%v).Abs==(%v,%v)",data[0],data[2],data[2],data[3])
    f1.Set(data[0],data[1])
    f2=f1.Abs()
    Test(msg,R(f2,data[2],data[3]))
  }
}

func test_fraction_round() {
  TestCase("Fraction greater than or equal")
  var f1 Fraction
  var round_data = [][] int64 { {101,214,100,47,100},{101,214,25,12,25},{101,214,10,1,2}}
  for _,data := range round_data {
    msg := fmt.Sprintf("(%v,%v).Round(%v)=(%v,%v)",data[0],data[1],data[2],data[3],data[4])
    f1.Set(data[0],data[1])
    Test(msg,R(f1.Round(data[2]),data[3],data[4]))
  }
}

var tests = [] TestFunc {
  testGCD,
  test_fraction_set,
  test_fraction_set_long_long,
  test_fraction_set_mixed,
  test_fraction_set_float,
  test_fraction_plus_fraction,
  test_fraction_minus_fraction,
  test_fraction_times_fraction,
  test_fraction_divided_by_fraction,
  test_fraction_equality,
  test_fraction_inequality,
  test_fraction_less_than,
  test_fraction_less_than_equal,
  test_fraction_greater_than,
  test_fraction_greater_than_equal,
  test_fraction_abs,
  test_fraction_round,
}

func main() {
  RunTests(os.Args[1:],tests)
  FinalSummary();
}
