const Fraction = require('./fraction.js');
const { PerformanceObserver, performance } = require('perf_hooks');

function statistics(statObject)
{
  var sum = 0;
}

function statistics(dataFreq)
{
  var stats = {
    average: new Fraction(),
    standard_deviation: new Fraction(),
    size: 0,
    median: -1,
    mode: 0
  };

  var sum=0;
  var max_freq=0;
  for(key in dataFreq) {
    stats["size"] += dataFreq[key];
    sum += key*dataFreq[key];
    if(dataFreq[key] > max_freq) {
      max_freq = dataFreq[key];
      stats["mode"] = key;
    }
  }

  stats["average"].set(sum/stats["size"]);
  stats["average"].round(100);

  var variance=0;
  var count=0;
  for(key in dataFreq) {
    variance += (stats["average"]-key)*(stats["average"]-key)*dataFreq[key];
    if(stats["median"] == -1) {
      count += dataFreq[key];
      if(count > stats["size"]/2) {
        stats["median"]=key;
      }
    }
  }

  stats["standard_deviation"].set(Math.sqrt(variance/(stats["size"]-1)));
  stats["standard_deviation"].round(100);
  return stats;
}

function do_test(value,timeFreq,loopFreq)
{
  var f=new Fraction();
  var begin_time = performance.now();
  f.set(value);
  var end_time = performance.now();
  elapsed_in_microsecs = Math.round((end_time - begin_time)*10000);
  if(!(elapsed_in_microsecs in timeFreq)) {
    timeFreq[elapsed_in_microsecs] = 0;
  }
  timeFreq[elapsed_in_microsecs]++;
  if(!(Fraction.loops in loopFreq)) {
    loopFreq[Fraction.loops]=0;
  }
  loopFreq[Fraction.loops]++;
}

function fn(n,w) /* format number so that total witdh is width specified. */
{
  if(n<0) {
    w--;
  }
  var abs_n = Math.abs(n);
  while(abs_n > 9 && w > 0) {
    abs_n = abs_n/10;
    w--;
  }
  return " ".repeat(w)+n;
}
function display_graph(dataFreq,xlabel,ylabel,max)
{
  console.log("\n",xlabel," |          ",ylabel);
  console.log("-".repeat(50));
  var scale=75/max;
  if(scale > 1) {
    scale=1;
  }
  for (key in dataFreq) {
    console.log(fn(key,4)," | ","#".repeat(Math.round(scale*dataFreq[key])),dataFreq[key]);
  }
}

function show_results(dataFreq,heading,xlabel)
{
  console.log(heading);
  var keys=Object.keys(dataFreq);
  console.log("  Min",xlabel,": ",keys[0]);
  console.log("  Max",xlabel,": ",keys[keys.length-1]);
  var stats=statistics(dataFreq);
  console.log("  Sample size: ",stats["size"]);
  console.log("  Average: ",stats["average"].toMixedString());
  console.log("  Median: ",stats["median"]);
  console.log("  Mode: ",stats["mode"]);
  console.log("  Standard deviation: ",stats["standard_deviation"].toMixedString());
  display_graph(dataFreq,xlabel,"Frequency",dataFreq[stats["mode"]]);
}

function single_test(denominator)
{
  var timeFreq={ }
  var loopFreq={ }
  var i;
  for(i=1;i<10;i++) {
    do_test(i/denominator,timeFreq,loopFreq);
  }
  timeFreq={ }
  loopFreq={ }
  for(i=1;i<denominator;i++) {
    do_test(i/denominator,timeFreq,loopFreq);
  }
  show_results(timeFreq,"Time taken to convert floating point to faction (time is in 100s of nanoseconds)","time");
  show_results(loopFreq,"Number of iterations to convert floating point to fraction","Loops");
}

function random_test(nTests)
{
  var tests=[];
  while(tests.length < nTests) {
    var v = Math.random();
    var found=false;
    for(const a of tests.values()) {
      if(Math.abs(a - v) < Fraction.epsilon) {
        found=true;
        break;
      }
    }
    if(!found) {
      tests.push(v);
    }
  }
  var timeFreq={ }
  var loopFreq={ }
  for(const value of tests.values()) {
    do_test(value,timeFreq,loopFreq);
  }
  show_results(timeFreq,"Time taken to convert floating point to faction (time is in 100s of nanoseconds)","time");
  show_results(loopFreq,"Number of iterations to convert floating point to fraction","Loops");

}

//if(scriptArgs.length == 0) {
  single_test(1000);
//  random_test(1000);
/*} else {
  var i;
  var denominator=0;
  var nTests=0;
  var re_int = /^\s*\+?\d+\s*$/;
  for(i=0;i<scriptArgs.length;i++) {
    if(scriptArgs[i] == "-s" || scriptArgs[i] == "--single") {
      i++;
      if(i < scriptArgs.length && re_int.test(scriptArgs[i])) {
        denominator = parseInt(scriptArgs[i]);
      } else {
        console.log("Syntax error");
      }
    } else if(scriptArgs[i] == "-r" || scriptArgs[i] == "--random") {
      i++;
      if(i < scriptArgs.length && re_int.test(scriptArgs[i])) {
        nTests = parseInt(scriptArgs[i]);
      } else {
        console.log("Syntax error");
      }
    } else {
      console.log("Syntax error");
    }
  }
  if(denominator > 0) {
    single_test(denominator);
  }
  if(nTests>0) {
    random_test(nTests);
  }
}*/
