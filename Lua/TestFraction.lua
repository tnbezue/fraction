require 'TestHarness'
require 'Fraction'

function TS (...)
  local printResult = ""
  for i=1,select('#',...) do
    local v = select(i,...)
    printResult = printResult .. tostring(v)
  end
  return printResult
end

th = TestHarness:new()

function R(f,n,d)
  return f.numerator == n and f.denominator == d
end

function test_gcd()
  th:testcase("Greatest Common Denominator")
  test_data = { { 0,2,2},{ 10,1,1},{ 105,15,15},{ 10,230,10},{ 28,234,2}, {872452914,78241452,6 }}
  for _,d in ipairs(test_data) do
    th:test(string.format("Fraction:gcd(%d,%d)=%d",table.unpack(d)),Fraction:gcd(d[1],d[2])==d[3])
  end

end

function test_new_zero()
-- Test zero argument
  th:testcase("New with zero arguments")
  local f
  f=Fraction:new()
  print(f)
  th:test(TS("Fraction:new() = {",0,"/",1,"}"),R(f,0,1))
--  f=Fraction.new()
--  th:test(TS("Fraction.new(Fraction) = {",0,"/",1,"}"),R(f,0,1))

end

function test_new_single_number()
  -- single number argument
  local f
  th:testcase("New with single numerical argument")
  test_data = {
    { 10, 10, 1 },
    { -8, -8, 1 },
    { 12.2, 61, 5 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new(",d[1],") = {",d[2],",",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_new_two_integers()
  -- tow integer arguments
  th:testcase("New with two integer arguments")
  test_data = {
    { 10, 2,  5, 1 },
    { -8, 3, -8, 3 },
    { -1, 2, -1, 2 },
    {  1,-2, -1, 2 },
    { 30, 3, 10, 1 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1],d[2])
    th:test(TS("Fraction:new(",d[1],",",d[2],") = {",d[3],"/",d[4],"}"),R(f,d[3],d[4]))
  end
end

function test_new_three_integers()
  -- tow integer arguments
  th:testcase("New with three integer arguments")
  test_data = {
    {  2, 3, 2,   7, 2 },
    { -8, 2, 3, -26, 3 },
    { -1,-2,-3,  -5, 3 },
    {  1,-2,-3,   5, 3 },
    { 30, 1, 3,  91, 3 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1],d[2],d[3])
    th:test(TS("Fraction:new(",d[1],",",d[2],",",d[3],") = {",d[4],"/",d[5],"}"),R(f,d[4],d[5]))
  end
end

function test_new_single_string_argument()
  -- single string argument
  th:testcase("New with single string argument")
  test_data = {
    { "10", 10, 1 },
    { "-8", -8, 1 },
    { "12.2", 61, 5 },
    { "3/5", 3, 5 },
    { "-8/10", -4, 5 },
    { "1 3/5", 8, 5 },
    { "-6 2/3", -20, 3 },
    { "-6 -2/3", 20, 3 },
    { "-6 -2/-3", -20, 3 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new(\"",d[1],"\") = {",d[2],",",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_new_table_one_number()
  -- table argument with 1 numerical argument
  th:testcase("New with table containing 1 numerical argument")
  test_data = {
    { {10}, 10, 1 },
    { {-8}, -8, 1 },
    { {12.2}, 61, 5 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new({",d[1][1],"}) = {",d[2],",",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_new_table_two_integers()
  -- tow integer arguments
  th:testcase("New table with two integer arguments")
  test_data = {
    { {10, 2},  5, 1 },
    { {-8, 3}, -8, 3 },
    { {-1, 2}, -1, 2 },
    { {1,-2}, -1, 2 },
    { {30, 3}, 10, 1 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new({",d[1][1],",",d[1][2],"}) = {",d[2],"/",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_new_table_three_integers()
  -- tow integer arguments
  th:testcase("New table with three integer arguments")
  test_data = {
    { { 2, 3, 2},   7, 2 },
    { {-8, 2, 3}, -26, 3 },
    { {-1,-2,-3},  -5, 3 },
    { { 1,-2,-3},   5, 3 },
    { {30, 1, 3},  91, 3 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new({",d[1][1],",",d[1][2],",",d[1][3],"}) = {",d[2],"/",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_new_table_one_string()
-- table argument with 1 string argument
  th:testcase("New with table containing 1 string argument")
  test_data = {
    { {"10"}, 10, 1 },
    { {"-8"}, -8, 1 },
    { {"12.2"}, 61, 5 },
    { {"-6 2/3"}, -20, 3 },
  }

  for _,d in ipairs(test_data) do
    f=Fraction:new(d[1])
    th:test(TS("Fraction:new({\"",d[1][1],"\"}) = {",d[2],",",d[3],"}"),R(f,d[2],d[3]))
  end
end

function test_to_string()
  th:testcase("Fraction to_string")
  test_data = {
    { 0,1, "0/1"},
    { 2,10, "1/5"},
    { 32,6, "-16/3"},
    { 9,150, "3/50"},
    { -2,3, "-2/3"},
    { -2,-3, "2/3"},
  }

  for _,d in ipairs(test_data) do
    th:test(TS("tostring(Fraction:new(",d[1],",",d[2],")) = \"",d[3],"\""),tostring(Fraction:new(d[1],d[2])==d[3]))
  end
end

function test_fraction_plus_fraction()
  th:testcase("Fraction plus fraction")
  test_data = {
    {0,1,0,1,0,1},
    {0,1,1,1,1,1},
    {3,5,-2,9,17,45},
    {-2,8,-6,8,-1,1},
    {7,3,10,7,79,21},
    {-5,7,25,35,0,1}}
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    f3 = f1 + f2
    th:test(TS("(",d[1],"/",d[2],")+(",d[3],"/",d[4],")=(",d[5],"/",d[6],")"),R(f3,d[5],d[6]))
  end
end

function test_fraction_minus_fraction()
  th:testcase("Fraction minus fraction")
  test_data = {
    {0,1,0,1,0,1},
    {0,1,1,1,-1,1},
    {3,5,-2,9,37,45},
    {-2,8,-6,8,1,2},
    {7,3,10,7,19,21},
    {-5,7,25,35,-10,7}}
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    f3 = f1 - f2
    th:test(TS("(",d[1],"/",d[2],")-(",d[3],"/",d[4],")=(",d[5],"/",d[6],")"),R(f3,d[5],d[6]))
  end
end

function test_fraction_times_fraction()
  th:testcase("Fraction times fraction")
  test_data = {
    {0,1,0,1,0,1},
    {0,1,1,1,0,1},
    {3,5,-2,9,-2,15},
    {-2,8,-6,8,3,16},
    {7,3,10,7,10,3},
    {-5,7,25,35,-25,49}}
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    f3 = f1 * f2
    th:test(TS("(",d[1],"/",d[2],")*(",d[3],"/",d[4],")=(",d[5],"/",d[6],")"),R(f3,d[5],d[6]))
  end
end

function test_fraction_divided_by_fraction()
  th:testcase("Fraction divided by fraction")
  test_data = {
    {0,1,1,1,0,1},
    {3,5,-2,9,-27,10},
    {-2,8,-6,8,1,3},
    {7,3,10,7,49,30},
    {-5,7,25,35,-1,1},
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    f3 = f1 / f2
    th:test(TS("(",d[1],"/",d[2],")/(",d[3],"/",d[4],")=(",d[5],"/",d[6],")"),R(f3,d[5],d[6]))
  end
end

function test_fraction_plus_number()
  th:testcase("Fraction plus number")
  test_data = {
    {0,1,0.0,0,1},
    {0,1,1.0,1,1},
    {3,5,-0.22222222,17,45},
    {-2,8,-0.75,-1,1},
    {7,3,1.428571428,79,21},
    {-5,7,0.714285714,0,1}}
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f3 = f1 + d[3]
    th:test(TS("(",d[1],"/",d[2],")+(",d[3],")=(",d[4],"/",d[5],")"),R(f3,d[4],d[5]))
  end
end

function test_fraction_minus_number()
  th:testcase("Fraction minus number")
  test_data = {
    {0,1,0.0,0,1},
    {0,1,1.0,-1,1},
    {3,5,-0.22222222,37,45},
    {-2,8,-0.75,1,2},
    {7,3,1.428571428,19,21},
    {-5,7,0.714285714,-10,7}}
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f3 = f1 - d[3]
    th:test(TS("(",d[1],"/",d[2],")-(",d[3],")=(",d[4],"/",d[5],")"),R(f3,d[4],d[5]))
  end
end

function test_fraction_times_number()
  th:testcase("Fraction times number")
  test_data = {
    {0,1,0.0,0,1},
    {0,1,1.0,0,1},
    {3,5,-0.22222222,-2,15},
    {-2,8,-0.75,3,16},
    {7,3,1.428571428,10,3},
    {-5,7,0.714285714,-25,49}}
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f3 = f1 * d[3]
    th:test(TS("(",d[1],"/",d[2],")*(",d[3],")=(",d[4],"/",d[5],")"),R(f3,d[4],d[5]))
  end
end

function test_fraction_divided_by_number()
  th:testcase("Fraction divided by number")
  test_data = {
    {0,1,1.0,0,1},
    {3,5,-0.22222222,-27,10},
    {-2,8,-0.75,1,3},
    {7,3,1.428571428,49,30},
    {-5,7,0.714285714,-1,1},
  }
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f3 = f1 / d[3]
    th:test(TS("(",d[1],"/",d[2],")/(",d[3],")=(",d[4],"/",d[5],")"),R(f3,d[4],d[5]))
  end
end

function test_fraction_idiv_fraction()
  th:testcase("Integer Division -- fraction // fraction")
  test_data = {
    {Fraction:new(3,5),Fraction:new(2,5),1,1},
    {Fraction:new(-2,9),Fraction:new(11,18),0,1},
    {Fraction:new(-2,9),Fraction:new(1,15),-3,1},
    {Fraction:new(22,33),Fraction:new(1,11),7,1},
    {Fraction:new(105,23),Fraction:new(3,8),12,1},
  }
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f3 = d[1] // d[2]
    th:test(TS("(",d[1],") // (",d[2],")=(",d[3],"/",d[4],")"),R(f3,d[3],d[4]))
  end
end

function test_fraction_idiv_number()
  th:testcase("Integer Division -- fraction // number")
  test_data = {
    {Fraction:new(12,5),2,1,1},
  }
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f3 = d[1] // d[2]
    th:test(TS("(",d[1],") // ",d[2],"=(",d[3],"/",d[4],")"),R(f3,d[3],d[4]))
  end
end

function test_number_idiv_fraction()
  th:testcase("Integer Division -- number // fraction")
  test_data = {
    {7,Fraction:new(2,5),17},
    {1,Fraction:new(3,8),2},
    {-8,Fraction:new(3,2),-5},
    {0,Fraction:new(2,5),0},
    {3,Fraction:new(2,5),7},
  }
  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    n = d[1] // d[2]
    th:test(TS(d[1]," // (",d[2],")=",d[3]),n == d[3])
  end
end

function test_fraction_pow()
  th:testcase("Power")
  test_data = {
    { Fraction:new(),0, 1,1},
    { Fraction:new(),2, 0,1},
    { Fraction:new(1), 2, 1, 1},
    { Fraction:new(3,4), 3, 27,64},
    { Fraction:new(1,2), Fraction:new(1,2),408,577},
    { Fraction:new(5,2), -2, 4,25},
    { Fraction:new(5,2), Fraction:new(-2,5), 192,277 },
    { Fraction:new(2,3), Fraction:new(2,3), 1321, 1731 },
    { Fraction:new(2,3), Fraction:new(-2,3), 1731, 1321 },
  }
  for _,d in ipairs(test_data) do
    th:test(TS("(",d[1],")^(",d[2],")=(",d[3],"/",d[4],")"),R(d[1]^d[2],d[3],d[4]))
  end
  test_data = {
    { 3, Fraction:new(1,5), 1.2457309396155 },
  }
  for _,d in ipairs(test_data) do
    local value = d[1]^d[2]
    th:test(TS("(",d[1],")^(",d[2],")=(",d[3],")"),math.abs(value-d[3])<Fraction.epsilon)
  end

end

function test_fraction_unm()
  th:testcase("Unary minus")
  test_data = {
    { Fraction:new(),0,1},
    { Fraction:new(1), -1, 1},
    { Fraction:new(3,4), -3, 4},
    { Fraction:new(-3,4), 3, 4},
    { Fraction:new(-3,-4), -3, 4},
    { Fraction:new(12,7), -12, 7},
    { Fraction:new(-24,14), 12, 7},
    { Fraction:new(-21,7), 3, 1},
    { Fraction:new(-64,28), 16, 7},
  }
  for _,d in ipairs(test_data) do
    local f = -d[1]
    th:test(TS("-(",d[1],")=(",d[2],"/",d[3],")"),R(f,d[2],d[3]))
  end
end

function test_fraction_len()
  th:testcase("Unary minus")
  test_data = {
    { Fraction:new(),0},
    { Fraction:new(1), 1},
    { Fraction:new(-3,4), -0.75},
    { Fraction:new(22,7), 3.142857},
  }
  for _,d in ipairs(test_data) do
    th:test(TS("#(",d[1],")=",d[2]),math.abs(#d[1]-d[2]) < Fraction.epsilon)
  end
end

function test_fraction_eq_fraction()
  th:testcase("Fraction == fraction")
  test_data = {
    { 0,1,0,1,true},
    {0,1,1,2,false},
    {2,3,-2,4,false},
    {2,3,16,24,true},
    {1,3,1,3,true},
    {-5,7,25,35,false}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")==(",d[3],",",d[4],") ",str_tf),(f1 == f2) == d[5])
  end
end

function test_fraction_ne_fraction()
  th:testcase("Fraction ~= fraction")
  test_data = {
    { 0,1,0,1,false},
    {0,1,1,2,true},
    {2,3,-2,4,true},
    {2,3,16,24,false},
    {1,3,1,3,false},
    {-5,7,25,35,true}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")~=(",d[3],",",d[4],") ",str_tf),(f1 ~= f2) == d[5])
  end
end

function test_fraction_lt_fraction()
  th:testcase("Fraction < fraction")
  test_data = {
    { 0,1,0,1,false},
    {0,1,1,2,true},
    {2,3,-2,4,false},
    {2,3,16,24,false},
    {1,3,1,3,false},
    {-5,7,25,35,true}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")<(",d[3],",",d[4],") ",str_tf),(f1 < f2) == d[5])
  end
end

function test_fraction_le_fraction()
  th:testcase("Fraction <= fraction")
  test_data = {
    { 0,1,0,1,true},
    {0,1,1,2,true},
    {2,3,-2,4,false},
    {2,3,16,24,true},
    {1,3,1,3,true},
    {-5,7,25,35,true}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")<=(",d[3],",",d[4],") ",str_tf),(f1 <= f2) == d[5])
  end
end

function test_fraction_gt_fraction()
  th:testcase("Fraction > fraction")
  test_data = {
    { 0,1,0,1,false},
    {0,1,1,2,false},
    {2,3,-2,4,true},
    {2,3,16,24,false},
    {1,3,1,3,false},
    {-5,7,25,35,false}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")>(",d[3],",",d[4],") ",str_tf),(f1 > f2) == d[5])
  end
end

function test_fraction_ge_fraction()
  th:testcase("Fraction >= fraction")
  test_data = {
    { 0,1,0,1,true},
    {0,1,1,2,false},
    {2,3,-2,4,true},
    {2,3,16,24,true},
    {1,3,1,3,true},
    {-5,7,25,35,false}
  }
  local f1 = Fraction:new()
  local f2 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f2:set(d[3],d[4])
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(TS("(",d[1],"/",d[2],")>=(",d[3],",",d[4],") ",str_tf),(f1 >= f2) == d[5])
  end
end

function test_fraction_abs()
  th:testcase("Absolute value")
  test_data = {
    { Fraction:new(),0,1},
    { Fraction:new(-1), 1, 1},
    { Fraction:new(-3,4), 3, 4},
    { Fraction:new(12,7), 12, 7},
    { Fraction:new(-3,10), 3, 10},
    { Fraction:new(-7,25), 7, 25 },
  }
  for _,d in ipairs(test_data) do
    local f = d[1]:abs()
    th:test(TS("(",d[1],"):abs()=(",d[2],"/",d[3],")"),R(f,d[2],d[3]))
  end
end

function test_round()
  th:testcase("Round")
  test_data = {
    {3333,10000,10,3,10},
    {3333,10000,100,33,100},
    {639,5176,100,3,25},
    { 2147483647,106197, 1000, 10110849,500}
  }

  local f1 = Fraction:new()
  for _,d in ipairs(test_data) do
    f1:set(d[1],d[2])
    f1=f1:round(d[3])
    th:test(string.format("(%d/%d):round(%d)=(%d/%d)",table.unpack(d)),R(f1,d[4],d[5]))
  end
end

function test_random()
  th:testcase("Random conversion from number to fraction")
  f=Fraction:new()
  local sign=1
  for i=1,1000 do
    local value = sign*math.random()*math.random(math.random(1000))
    f:set(value);
    th:test(TS(string.format("%10.5f",value)," = ","(",f,")"),math.abs(f:tonumber() - value) < Fraction.epsilon)
    sign=-sign
  end
end

tests = {
  test_gcd,
  test_new_zero,
  test_new_single_number,
  test_new_two_integers,
  test_new_three_integers,
  test_new_single_string_argument,
  test_new_table_one_number,
  test_new_table_two_integers,
  test_new_table_three_integers,
  test_new_table_one_string,
  test_to_string,
  test_fraction_plus_fraction,
  test_fraction_minus_fraction,
  test_fraction_times_fraction,
  test_fraction_divided_by_fraction,
  test_fraction_plus_number,
  test_fraction_minus_number,
  test_fraction_times_number,
  test_fraction_divided_by_number,
  test_fraction_idiv_fraction,
  test_fraction_idiv_number,
  test_number_idiv_fraction,
  test_fraction_pow,
  test_fraction_unm,
  test_fraction_len,
  test_fraction_eq_fraction,
  test_fraction_ne_fraction,
  test_fraction_lt_fraction,
  test_fraction_le_fraction,
  test_fraction_gt_fraction,
  test_fraction_ge_fraction,
  test_fraction_abs,
  test_round,
  test_random,
}

local params = {...}
local nparams = #params
if(nparams > 0) then
  local ntests = #tests
  for i=1,nparams do
    itest = tonumber(params[i])
    if(itest >= 1 and itest <= ntests) then
      tests[itest]()
    else
      io.stdout:write("No test case for ",itest,".\n")
    end
  end
else
  for _,t in ipairs(tests) do
    t()
  end
end

th:final_summary()
