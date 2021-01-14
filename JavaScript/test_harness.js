class TestHarness {

  constructor() {
    this.nPass=0;
    this.nFail=0;
    this.nTotalPass=0;
    this.nTotalFail=0;
  }

  summary()
  {
    console.log("  Passed: ",this.nPass,"\n  Failed: ",this.nFail,"\n");
  }

  final_summary()
  {
    if(this.nPass != 0 || this.nFail != 0) {
      this.summary();
    }
    this.nTotalPass += this.nPass;
    this.nTotalFail += this.nFail;
    console.log("  Total Passed: ",this.nTotalPass,"\n  Failed: ",this.nTotalFail);
  }

  test_case(str)
  {
    if(this.nPass != 0 || this.nFail != 0) {
      this.summary();
    }
    console.log("\n",str);
    this.nTotalPass += this.nPass;
    this.nTotalFail += this.nFail;
    this.nPass=0;
    this.nFail=0;
  }

  test(str,result)
  {
    var result_str;
    if(result) {
      this.nPass++;
      result_str="Pass"
    } else {
      this.nFail++;
      result_str="Fail"
    }
    console.log("  ",str," ... ",result_str);
  }
}

module.exports = TestHarness;
