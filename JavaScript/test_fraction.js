const Fraction = require('./fraction.js');
const TestHarness = require('./test_harness.js');

var th = new TestHarness();

function R(f,n,d)
{
  return f.numerator == n && f.denominator == d;
}

function F(n,d)
{
  return n+"/"+d;
}

function test_gcd()
{
  th.test_case("Fraction GCD");
  var test_data = [
    [ 0,2,2],
    [ 10,1,1],
    [ 105,15,15],
    [ 10,230,10],
    [ 28,234,2],
    [872452914,78241452,6 ]
  ];
  var i;
  for(const data of test_data.values()) {
    th.test("GCD("+data[0]+","+data[1]+")="+data[2],Fraction.gcd(data[0],data[1])==data[2]);
  }
}

function test_set()
{
  th.test_case("Set");
  var test_data = [
    [ 0,1 ],
    [ 4,4,1 ],
    [ 20,30,2,3 ],
    [ new Fraction(6,4),3,2 ],
    [1,1,1,1],
    [-2,3,-2,3],
    [2,-3,-2,3],
    [-2,-3,2,3],
    [.06,3,50],
    ["7.125",57,8],
  ];
  var f = new Fraction();
  for(const data of test_data.values()) {
    if(data.length == 2) {
      th.test("set()=("+data[0]+"/"+data[1]+")",R(f,data[0],data[1]));
    } else if(data.length == 3) { // A fraction or double value
      f.set(data[0]);
      var t = typeof(data[0]);
      if(t=="object") { // a fraction
        th.test("set(("+data[0].numerator+"/"+data[0].denominator+"))=("+data[1]+"/"+data[2]+")",R(f,data[1],data[2]));
      } else if(t=="string") {
        th.test("set(\""+data[0]+"\")=("+data[1]+"/"+data[2]+")",R(f,data[1],data[2]));
      } else {
        th.test("set("+data[0]+")=("+data[1]+"/"+data[2]+")",R(f,data[1],data[2]));
      }
    } else {
      f.set(data[0],data[1]);
      th.test("set("+data[0]+","+data[1]+")=("+data[2]+"/"+data[3]+")",R(f,data[2],data[3]));
    }
  }
}

function test_tostring()
{
  th.test_case("ToString");
  var test_data = [
    [0,1,"0"],
    [3,5,"3/5"],
    [4,1,"4"],
    [-2,8,"-1/4"],
    [7,-3,"-7/3"],
    [-5,7,"-5/7"],
  ];
  for(const data of test_data.values()) {
    var f = new Fraction(data[0],data[1]);
    th.test("("+data[0]+"/"+data[1]+")=\""+data[2]+"\"",f.toString()==data[2]);
  }
}

function test_plus()
{
  th.test_case("Addition");
  var test_data=[
    [0,1,0,1,"0"],
    [0,1,1,1,"1"],
    [3,5,-2,9,"17/45"],
    [-2,8,-6,8,"-1"],
    [7,3,10,7,"79/21"],
    [-5,7,25,1,"170/7"],
    [-5,7,-10,1,"-75/7"],
    [-5,7,3,50,"-229/350"],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    var f3=Fraction.fraction_plus_fraction(f1,f2);
    th.test("("+F(data[0],data[1])+")+("+F(data[2],data[3])+")=("+data[4]+")",f3.toString()==data[4]);
  }
}

function test_minus()
{
  th.test_case("Subtraction");
  var test_data=[
    [0,1,0,1,"0"],
    [0,1,1,1,"-1"],
    [3,5,-2,9,"37/45"],
    [-2,8,-6,8,"1/2"],
    [7,3,10,7,"19/21"],
    [-5,7,25,1,"-180/7"],
    [-5,7,-10,1,"65/7"],
    [-5,7,3,50,"-271/350"],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    var f3=Fraction.fraction_minus_fraction(f1,f2);
    th.test("("+F(data[0],data[1])+")-("+F(data[2],data[3])+")=("+data[4]+")",f3.toString()==data[4]);
  }
}

function test_multiply()
{
  th.test_case("Multiplication");
  var test_data=[
    [0,1,0,1,"0"],
    [0,1,1,1,"0"],
    [3,5,-2,9,"-2/15"],
    [-2,8,-6,8,"3/16"],
    [7,3,10,7,"10/3"],
    [-5,7,25,1,"-125/7"],
    [-5,7,-10,1,"50/7"],
    [-5,7,3,50,"-3/70"],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    var f3=Fraction.fraction_times_fraction(f1,f2);
    th.test("("+F(data[0],data[1])+")*("+F(data[2],data[3])+")=("+data[4]+")",f3.toString()==data[4]);
  }
}

function test_division()
{
  th.test_case("Division");
  var test_data=[
    [0,1,1,1,"0"],
    [3,5,-2,9,"-27/10"],
    [-2,8,-6,8,"1/3"],
    [7,3,10,7,"49/30"],
    [-5,7,25,1,"-1/35"],
    [-5,7,-10,1,"1/14"],
    [-5,7,3,50,"-250/21"],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    var f3=Fraction.fraction_divided_by_fraction(f1,f2);
    th.test("("+F(data[0],data[1])+")/("+F(data[2],data[3])+")=("+data[4]+")",f3.toString()==data[4]);
  }
}

function test_eq()
{
  th.test_case("Equality");
  var test_data = [
    [ 0,1,0,1,true],
    [0,1,1,2,false],
    [2,3,-2,4,false],
    [2,3,16,24,true],
    [1,3,33,99,true],
    [-5,7,25,35,false],
    [5,7,25,35,true],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_equal_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_equal_fraction(f1,f2) == data[4]);
  }
}

function test_ne()
{
  th.test_case("Inequality");
  var test_data = [
    [ 0,1,0,1,false],
    [0,1,1,2,true],
    [2,3,-2,4,true],
    [2,3,16,24,false],
    [1,3,33,99,false],
    [-5,7,25,35,true],
    [5,7,25,35,false],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_not_equal_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_not_equal_fraction(f1,f2) == data[4]);
  }
}

function test_lt()
{
  th.test_case("Fraction less than Fraction");
  var test_data = [
    [ 0,1,0,1,false],
    [0,1,1,2,true],
    [2,3,-2,4,false],
    [2,3,16,24,false],
    [1,3,33,99,false],
    [-5,7,25,35,true],
    [5,7,25,35,false],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_less_than_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_less_than_fraction(f1,f2) == data[4]);
  }
}

function test_le()
{
  th.test_case("Fraction less than or equal Fraction");
  var test_data = [
    [ 0,1,0,1,true],
    [0,1,1,2,true],
    [2,3,-2,4,false],
    [2,3,16,24,true],
    [1,3,33,99,true],
    [-5,7,25,35,true],
    [5,7,25,35,true],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_less_than_equal_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_less_than_equal_fraction(f1,f2) == data[4]);
  }
}

function test_gt()
{
  th.test_case("Fraction greater than Fraction");
  var test_data = [
    [ 0,1,0,1,false],
    [0,1,1,2,false],
    [2,3,-2,4,true],
    [2,3,16,24,false],
    [1,3,33,99,false],
    [-5,7,25,35,false],
    [5,7,25,35,false],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_greater_than_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_greater_than_fraction(f1,f2) == data[4]);
  }
}

function test_ge()
{
  th.test_case("Fraction greater than or equal Fraction");
  var test_data = [
    [ 0,1,0,1,true],
    [0,1,1,2,false],
    [2,3,-2,4,true],
    [2,3,16,24,true],
    [1,3,33,99,true],
    [-5,7,25,35,false],
    [5,7,25,35,true],
  ];
  for(const data of test_data.values()) {
    var f1=new Fraction(data[0],data[1]);
    var f2=new Fraction(data[2],data[3]);
    th.test("fraction_greater_than_equal_fraction("+F(data[0],data[1])+","+F(data[2],data[3])+") ("+(data[4] ? "True" : "False")+")",
        Fraction.fraction_greater_than_equal_fraction(f1,f2) == data[4]);
  }
}

function test_round()
{
  th.test_case("Round");
  var test_data = [
    [3333,10000,10,"3/10"],
    [3333,10000,100,"33/100"],
    [639,5176,100,"3/25"],
    [ 2147483647,106197, 1000, "10110849/500"],
  ];
  for(const data of test_data.values()) {
    var f=new Fraction(data[0],data[1]);
    f.round(data[2]);
    th.test("("+F(data[0],data[1])+").round("+data[2]+")="+data[3],f.toString()==data[3]);
  }
}

function test_random()
{
  th.test_case("Random");
  var i;
  var sign=-1;
  var f = new Fraction();
  for(i=0;i<1000;i++) {
    var numerator=sign*Math.floor(Math.random()*16777216)+1;
    var denominator=Math.floor(Math.random()*16777216)+100;
    var value=numerator/denominator;
    f.set(value);
    if(Math.abs(value - f.valueOf()) < Fraction.epsilon) {
      th.nPass++;
    } else {
      th.nFail++;
    }
    sign=-sign;
  }
}

tests = [
  test_gcd,
  test_tostring,
  test_set,
  test_plus,
  test_minus,
  test_multiply,
  test_division,
  test_eq,
  test_ne,
  test_lt,
  test_le,
  test_gt,
  test_ge,
  test_round,
  test_random,
];

//if(scriptArgs.length == 0) {
  for(const test of tests.values()) {
    test();
  }
/*} else {
  var i;
  for(i=0;i<scriptArgs.length;i++) {
    var j = scriptArgs[i];
    if(j >= 0 && j < tests.length) {
      tests[j]();
    } else {
      print("\nNo test for ",j,"\n");
    }
  }
}
*/
th.final_summary();
