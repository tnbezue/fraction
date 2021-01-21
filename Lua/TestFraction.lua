#!/usr/bin/env -S lua

local function syntax()
  print("\nTestFraction.lua [-h|--help] [-n|--native] [-m|--mixed] [1..n]")
  print("\nWhere:")
  print("   -h|--help -- prints this help message")
  print("   -n|--native -- use the native (Lua) version of Fraction. Uses C version by default")
  print("   -m|--mixed -- use MixedFraction class rather than Fraction to perform test")
  print("   [1..n] -- execute the test indicated. Multiple entries can be specified")
  print("             If no entries are specifed, then all test are performed")
  print("\nExamples:")
  print("  1. TestFraction.lua -- uses C version and Fraction class to perform all test")
  print("\n  2. TestFraction.lua -m 3 4 15 -- use C version and MixedFraction class to perform test 3, 4, and 15")
  print("\n  3. TestFraction.lua -n 22 -- use Lua version and Fraction class to perform test 22")
  os.exit(0)
end

--[[
  Copy cmdline arguments. If one is the option "-n", remove it and use native library
]]--
local cmdline_args = {...}
local params = {}
use_native=false
local use_mixed_fraction=false
for _,v in ipairs(cmdline_args) do
  if v == '-n' or v == "--native" then
    use_native=true
  elseif v == '-m' or v == "--mixed" then
    use_mixed_fraction=true
  elseif v == '-h' or v == "--help" then
    syntax()
  else
    table.insert(params,v)
  end
end

require 'TestHarness'
if use_native then
  require 'FractionNative'
else
  require 'Fraction'
end

local FractionType = Fraction
if use_mixed_fraction then
  FractionType = MixedFraction
end

th = TestHarness:new()

function R(f,n,d)
  return f.numerator == n and f.denominator == d
end

function test_gcd()
  th:testcase("Greatest Common Denominator")
  test_data = { { 0,2,2},{ 10,1,1},{ 105,15,15},{ 10,230,10},{ 28,234,2}, {872452914,78241452,6 }}
  for _,d in ipairs(test_data) do
    th:test(string.format("%s:gcd(%d,%d)=%d",FractionType.__name,table.unpack(d)),Fraction.gcd(d[1],d[2])==d[3])
  end
end

function test_new_zero()
-- Test zero argument
  th:testcase("New with zero arguments")
  local f
  f=FractionType:new()
  th:test(string.format("%s:new() = (0/1)",FractionType.__name),R(f,0,1))
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
    f=FractionType:new(d[1])
    th:test(string.format("%s:new(%g) = (%d/%d)",FractionType.__name,table.unpack(d)),R(f,d[2],d[3]))
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
    f=FractionType:new(d[1],d[2])
    th:test(string.format("%s:new(%d,%d)=(%d/%d)",FractionType.__name,table.unpack(d)),R(f,d[3],d[4]))
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
    f=FractionType:new(d[1],d[2],d[3])
    th:test(string.format("%s:new(%d,%d,%d)=(%d/%d)",FractionType.__name,table.unpack(d)),R(f,d[4],d[5]))
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
    f=FractionType:new(d[1])
    th:test(string.format("%s:new(\"%s\")=(%d/%d)",FractionType.__name,table.unpack(d)),R(f,d[2],d[3]))
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
    f=FractionType:new(d[1])
    th:test(string.format("%s:new({%g})=(%d/%d)",FractionType.__name,d[1][1],d[2],d[3]),R(f,d[2],d[3]))
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
    f=FractionType:new(d[1])
    th:test(string.format("%s:new({%d,%d})=(%d/%d)",FractionType.__name,d[1][1],d[1][2],d[2],d[3]),R(f,d[2],d[3]))
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
    f=FractionType:new(d[1])
    th:test(string.format("%s:new({%d,%d,%d})=(%d/%d)",FractionType.__name,d[1][1],d[1][2],d[1][3],d[2],d[3]),R(f,d[2],d[3]))
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
    th:test(string.format("%s:new({\"%s\"}) = (%d/%d)",FractionType.__name,d[1][1],d[2],d[3]),R(f,d[2],d[3]))
  end
end

function test_to_string()
  th:testcase("Fraction tostring")
  test_data = nil
  if FractionType == Fraction then
    test_data = {
      { 0,1, "0"},
      { 2,10, "1/5"},
      { -16,3, "-16/3"},
      { 9,150, "3/50"},
      { -2,3, "-2/3"},
      { -2,-3, "2/3"},
    }
  else
    test_data = {
      { 0,1, "0"},
      { 2,10, "1/5"},
      { -32,6, "-5 1/3"},
      { 150,9, "16 2/3"},
      { -2,3, "-2/3"},
      { -2,-3, "2/3"},
    }
  end

  for _,d in ipairs(test_data) do
    local f=FractionType:new(d[1],d[2])
    local s=tostring(f)
    th:test(string.format("tostring(%s:new(%d,%d))=\"%s\"",FractionType.__name,table.unpack(d)),s==d[3])
  end
end

function test_fraction_eq_fraction()
  th:testcase("Fraction == fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),true},
    {FractionType:new(0,1),FractionType:new(1,2),false},
    {FractionType:new(2,3),FractionType:new(-2,4),false},
    {FractionType:new(2,3),FractionType:new(16,24),true},
    {FractionType:new(1,3),FractionType:new(1,3),true},
    {FractionType:new(-5,7),FractionType:new(25,35),false}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) == (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] == d[2]) == d[3])
  end
end

function test_fraction_ne_fraction()
  th:testcase("Fraction ~= fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),false},
    {FractionType:new(0,1),FractionType:new(1,2),true},
    {FractionType:new(2,3),FractionType:new(-2,4),true},
    {FractionType:new(2,3),FractionType:new(16,24),false},
    {FractionType:new(1,3),FractionType:new(1,3),false},
    {FractionType:new(-5,7),FractionType:new(25,35),true}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) ~= (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] ~= d[2]) == d[3])
  end
end

function test_fraction_lt_fraction()
  th:testcase("Fraction < fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),false},
    {FractionType:new(0,1),FractionType:new(1,2),true},
    {FractionType:new(2,3),FractionType:new(-2,4),false},
    {FractionType:new(2,3),FractionType:new(16,24),false},
    {FractionType:new(1,3),FractionType:new(1,3),false},
    {FractionType:new(-5,7),FractionType:new(25,35),true}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) < (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] < d[2]) == d[3])
  end
end

function test_fraction_le_fraction()
  th:testcase("Fraction <= fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),true},
    {FractionType:new(0,1),FractionType:new(1,2),true},
    {FractionType:new(2,3),FractionType:new(-2,4),false},
    {FractionType:new(2,3),FractionType:new(16,24),true},
    {FractionType:new(1,3),FractionType:new(1,3),true},
    {FractionType:new(-5,7),FractionType:new(25,35),true}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) <= (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] <= d[2]) == d[3])
  end
end

function test_fraction_gt_fraction()
  th:testcase("Fraction > fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),false},
    {FractionType:new(0,1),FractionType:new(1,2),false},
    {FractionType:new(2,3),FractionType:new(-2,4),true},
    {FractionType:new(2,3),FractionType:new(16,24),false},
    {FractionType:new(1,3),FractionType:new(1,3),false},
    {FractionType:new(-5,7),FractionType:new(25,35),false}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) > (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] > d[2]) == d[3])
  end
end

function test_fraction_ge_fraction()
  th:testcase("Fraction >= fraction")
  test_data = {
    {FractionType:new(0,1),FractionType:new(0,1),true},
    {FractionType:new(0,1),FractionType:new(1,2),false},
    {FractionType:new(2,3),FractionType:new(-2,4),true},
    {FractionType:new(2,3),FractionType:new(16,24),true},
    {FractionType:new(1,3),FractionType:new(1,3),true},
    {FractionType:new(-5,7),FractionType:new(25,35),false}
  }
  for _,d in ipairs(test_data) do
    if(d[5]) then
      str_tf = "true"
    else
      str_tf = "false"
    end
    th:test(string.format("(%s) >= (%s) -- %s",tostring(d[1]),tostring(d[2]),d[3]),(d[1] >= d[2]) == d[3])
  end
end

function test_fraction_plus_fraction()
  th:testcase("Fraction plus fraction")
  test_data = {
    { FractionType:new(0,1), FractionType:new(0,1), FractionType:new(0,1) },
    { FractionType:new(0,1), FractionType:new(1,1), FractionType:new(1,1) },
    { FractionType:new(3,5), FractionType:new(-2,9), FractionType:new(17,45) },
    { FractionType:new(-2,8), FractionType:new(-6,8), FractionType:new(-1,1) },
    { FractionType:new(7,3), FractionType:new(10,7), FractionType:new(79,21) },
    { FractionType:new(-5,7), FractionType:new(25,35), FractionType:new(0,1) },
  }
  for _,d in ipairs(test_data) do
    f3 = d[1] + d[2]
    th:test(string.format("(%s) + (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f3 == d[3])
  end
end

function test_fraction_minus_fraction()
  th:testcase("Fraction minus fraction")
  test_data = {
    { FractionType:new(0,1), FractionType:new(0,1), FractionType:new(0,1) },
    { FractionType:new(0,1), FractionType:new(1,1), FractionType:new(-1,1) },
    { FractionType:new(3,5), FractionType:new(-2,9), FractionType:new(37,45) },
    { FractionType:new(-2,8), FractionType:new(-6,8), FractionType:new(1,2) },
    { FractionType:new(7,3), FractionType:new(10,7), FractionType:new(19,21) },
    { FractionType:new(-5,7), FractionType:new(25,35), FractionType:new(-10,7) },
  }
  for _,d in ipairs(test_data) do
    f3 = d[1] - d[2]
    th:test(string.format("(%s) - (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f3 == d[3])
  end
end

function test_fraction_times_fraction()
  th:testcase("Fraction times fraction")
  test_data = {
    { FractionType:new(0,1), FractionType:new(0,1), FractionType:new(0,1) },
    { FractionType:new(0,1), FractionType:new(1,1), FractionType:new(0,1) },
    { FractionType:new(3,5), FractionType:new(-2,9), FractionType:new(-2,15) },
    { FractionType:new(-2,8), FractionType:new(-6,8), FractionType:new(3,16) },
    { FractionType:new(7,3), FractionType:new(10,7), FractionType:new(10,3) },
    { FractionType:new(-5,7), FractionType:new(25,35), FractionType:new(-25,49) },
  }
  for _,d in ipairs(test_data) do
    f3 = d[1] * d[2]
    th:test(string.format("(%s) * (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f3 == d[3])
  end
end

function test_fraction_divided_by_fraction()
  th:testcase("Fraction divided by fraction")
  test_data = {
    { FractionType:new(0,1), FractionType:new(1,1), FractionType:new(0,1) },
    { FractionType:new(3,5), FractionType:new(-2,9), FractionType:new(-27,10) },
    { FractionType:new(-2,8), FractionType:new(-6,8), FractionType:new(1,3) },
    { FractionType:new(7,3), FractionType:new(10,7), FractionType:new(49,30) },
    { FractionType:new(-5,7), FractionType:new(25,35), FractionType:new(-1,1) },
  }
  for _,d in ipairs(test_data) do
    f3 = d[1] / d[2]
    th:test(string.format("(%s) / (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f3 == d[3])
  end
end

function test_fraction_plus_number()
  th:testcase("Fraction plus number")
  test_data = {
    { FractionType:new(0,1),0, FractionType:new(0,1) },
    { FractionType:new(0,1),1, FractionType:new(1,1) },
    { FractionType:new(3,5),-0.222222, FractionType:new(17,45) },
    { FractionType:new(-2,8),-0.75, FractionType:new(-1,1) },
    { FractionType:new(7,3),1.42857, FractionType:new(79,21) },
    { FractionType:new(-5,7),0.714286, FractionType:new(0,1) },
  }
  for _,d in ipairs(test_data) do
    f = d[1] + d[2]
    th:test(string.format("(%s) + (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f == d[3])
  end
end

function test_fraction_minus_number()
  th:testcase("Fraction minus number")
  test_data = {
    { FractionType:new(0,1),0, FractionType:new(0,1) },
    { FractionType:new(0,1),1, FractionType:new(-1,1) },
    { FractionType:new(3,5),-0.222222, FractionType:new(37,45) },
    { FractionType:new(-2,8),-0.75, FractionType:new(1,2) },
    { FractionType:new(7,3),1.42857, FractionType:new(19,21) },
    { FractionType:new(-5,7),0.714286, FractionType:new(-10,7) },
  }
  for _,d in ipairs(test_data) do
    f = d[1] - d[2]
    th:test(string.format("(%s) - (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f == d[3])
  end
end

function test_fraction_times_number()
  th:testcase("Fraction times number")
  test_data = {
    { FractionType:new(0,1),0, FractionType:new(0,1) },
    { FractionType:new(0,1),1, FractionType:new(0,1) },
    { FractionType:new(3,5),-0.222222, FractionType:new(-2,15) },
    { FractionType:new(-2,8),-0.75, FractionType:new(3,16) },
    { FractionType:new(7,3),1.42857, FractionType:new(10,3) },
    { FractionType:new(-5,7),0.714286, FractionType:new(-25,49) },
  }
  for _,d in ipairs(test_data) do
    f = d[1] * d[2]
    th:test(string.format("(%s) * (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f == d[3])
  end
end

function test_fraction_divided_by_number()
  th:testcase("Fraction divided by number")
  test_data = {
    { FractionType:new(0,1),1, FractionType:new(0,1) },
    { FractionType:new(3,5),-0.222222, FractionType:new(-27,10) },
    { FractionType:new(-2,8),-0.75, FractionType:new(1,3) },
    { FractionType:new(7,3),1.42857, FractionType:new(49,30) },
    { FractionType:new(-5,7),0.714286, FractionType:new(-1,1) },
  }
  for _,d in ipairs(test_data) do
    f = d[1] / d[2]
    th:test(string.format("(%s) / (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f == d[3])
  end
end

function test_fraction_idiv_fraction()
  th:testcase("Integer Division -- fraction // fraction")
  test_data = {
    {FractionType:new(3,5),FractionType:new(2,5),FractionType:new(1,1)},
    {FractionType:new(-3,5),FractionType:new(2,5),FractionType:new(-2,1)},
    {FractionType:new(3,5),FractionType:new(-2,5),FractionType:new(-2,1)},
    {FractionType:new(-3,5),FractionType:new(-2,5),FractionType:new(1,1)},
    {FractionType:new(-2,9),FractionType:new(11,18),FractionType:new(-1,1)},
    {FractionType:new(-2,9),FractionType:new(1,15),FractionType:new(-4,1)},
    {FractionType:new(22,33),FractionType:new(1,11),FractionType:new(7,1)},
    {FractionType:new(105,23),FractionType:new(3,8),FractionType:new(12,1)},
  }
  for _,d in ipairs(test_data) do
    local f3 = d[1] // d[2]
    th:test(string.format("(%s) // (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f3 == d[3])
  end
end

function test_fraction_idiv_number()
  th:testcase("Integer Division -- fraction // number")
  test_data = {
    {FractionType:new(12,5),2,FractionType:new(1,1)},
    {FractionType:new(-12,5),2,FractionType:new(-2,1)},
    {FractionType:new(12,5),-2,FractionType:new(-2,1)},
    {FractionType:new(-12,5),-2,FractionType:new(1,1)},
  }
  for _,d in ipairs(test_data) do
    local f3 = d[1] // d[2]
    th:test(string.format("(%s) // (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f3 == d[3])
  end
end

function test_number_idiv_fraction()
  th:testcase("Integer Division -- number // fraction")
  test_data = {
    {7,FractionType:new(2,5),17},
    {-7,FractionType:new(2,5),-18},
    {7,FractionType:new(-2,5),-18},
    {-7,FractionType:new(-2,5),17},
    {1,FractionType:new(3,8),2},
    {-8,FractionType:new(3,2),-6},
    {0,FractionType:new(2,5),0},
    {3,FractionType:new(2,5),7},
  }
  for _,d in ipairs(test_data) do
    local n = d[1] // d[2]
    th:test(string.format("(%g) // (%s) = (%g)",d[1],tostring(d[2]),d[3]),n == d[3])
  end
end

function test_fraction_power_fraction()
  th:testcase("Fraction to power of fraction")
  test_data = {
    { FractionType:new(1,2), FractionType:new(1,2),FractionType:new(408,577) },
    { FractionType:new(5,2), FractionType:new(-2,5),FractionType:new(192,277) },
    { FractionType:new(2,3), FractionType:new(2,3),FractionType:new(1321, 1731) },
    { FractionType:new(2,3), FractionType:new(-2,3),FractionType:new(1731, 1321) },
  }
  for _,d in ipairs(test_data) do
    local f = d[1] ^ d[2]
    th:test(string.format("(%s) ^ (%s) = (%s)",tostring(d[1]),tostring(d[2]),tostring(d[3])),f == d[3])
  end

end

function test_fraction_power_number()
  th:testcase("Fraction to power of number")
  test_data = {
    { FractionType:new(),2, FractionType:new(0,1) },
    { FractionType:new(1), 2., FractionType:new(1, 1) },
    { FractionType:new(3,4), 3.5, FractionType:new(0.36535446722) },
    { FractionType:new(5,2), -2.75, FractionType:new(0.0804757395) },
    { FractionType:new(-5,2), 2, FractionType:new(6.25) },
  }
  for _,d in ipairs(test_data) do
    local f = d[1] ^ d[2]
    th:test(string.format("(%s) ^ (%g) = (%s)",tostring(d[1]),d[2],tostring(d[3])),f == d[3])
  end
end

function test_number_power_fraction()
  th:testcase("Number to power of fraction")
  test_data = {
    { 3, FractionType:new(3,5), 1.93318204493 },
    { -math.sqrt(2.0), FractionType:new(2), 2 },
    { 0.8 , FractionType:new(1,8), 0.97249247247},
    { 0.8 , FractionType:new(-1,8), 1.0282855943}
  }
  for _,d in ipairs(test_data) do
    local v = d[1] ^ d[2]
    th:test(string.format("(%g) ^ (%s) = (%g)",d[1],tostring(d[2]),d[3]),math.abs(v - d[3]) < Fraction.epsilon)
  end

end
function test_fraction_unm()
  th:testcase("Unary minus")
  test_data = {
    { FractionType:new(),FractionType:new(0,1)},
    { FractionType:new(1), FractionType:new(-1, 1)},
    { FractionType:new(3,4), FractionType:new(-3, 4) },
    { FractionType:new(-3,4), FractionType:new(3, 4) },
    { FractionType:new(-3,-4), FractionType:new(-3, 4) },
    { FractionType:new(12,7), FractionType:new(-12, 7) },
    { FractionType:new(-24,14), FractionType:new(12, 7) },
    { FractionType:new(-21,7), FractionType:new(3, 1) },
    { FractionType:new(-64,28), FractionType:new(16, 7) },
  }
  for _,d in ipairs(test_data) do
    local f = -d[1]
    th:test(string.format("-(%s)=(%s)",table.unpack(d)),f == d[2])
  end
end

function test_fraction_len()
  th:testcase("Length (AKA, tonumber)")
  test_data = {
    { FractionType:new(),0},
    { FractionType:new(1), 1},
    { FractionType:new(-3,4), -0.75},
    { FractionType:new(22,7), 3.142857},
  }
  for _,d in ipairs(test_data) do
    th:test(string.format("#(%s)=%g",table.unpack(d)),math.abs(#d[1]-d[2]) < Fraction.epsilon)
  end
end


function test_fraction_abs()
  th:testcase("Absolute value")
  test_data = {
    { FractionType:new(),FractionType:new(0,1)},
    { FractionType:new(-1), FractionType:new(1, 1)},
    { FractionType:new(-3,4), FractionType:new(3, 4)},
    { FractionType:new(12,7), FractionType:new(12, 7)},
    { FractionType:new(-3,10), FractionType:new(3, 10)},
    { FractionType:new(-7,25), FractionType:new(7, 25) },
  }
  for _,d in ipairs(test_data) do
    local f = d[1]:abs()
    th:test(string.format("(%s):abs()=(%s)",tostring(d[1]),tostring(d[2])),d[1]:abs() == d[2])
  end
end

function test_round()
  th:testcase("Round")
  test_data = {
    {FractionType:new(3333,10000),10,FractionType:new(3,10)},
    {FractionType:new(-3333,10000),100,FractionType:new(-33,100)},
    {FractionType:new(-639,5176),100,FractionType:new(-03,25)},
    {FractionType:new(2147483647,106197), 1000, FractionType:new(10110849,500)}
  }

  for _,d in ipairs(test_data) do
    th:test(string.format("(%s):round(%d)=(%s)",tostring(d[1]),d[2],tostring(d[3])),d[1]:round(d[2]) == d[3])
  end
end

function test_random()
  th:testcase("Random conversion from number to fraction")
  f=Fraction:new()
  local sign=1
  for i=1,1000 do
    local value = sign*math.random()*math.random(math.random(1000))
    f:set(value);
    th:test(string.format("%10.5f = (%s)",value,tostring(f)),math.abs(#f - value) < Fraction.epsilon)
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
  test_fraction_eq_fraction,
  test_fraction_ne_fraction,
  test_fraction_lt_fraction,
  test_fraction_le_fraction,
  test_fraction_gt_fraction,
  test_fraction_ge_fraction,
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
  test_fraction_power_fraction,
  test_fraction_power_number,
  test_number_power_fraction,
  test_fraction_unm,
  test_fraction_len,
  test_fraction_abs,
  test_round,
  test_random,
}

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

os.exit(th.nTotalFail)
