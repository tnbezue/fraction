
class TestHarness
  attr_reader :nFail,:nPass,:nTotalFail,:nTotalPass
  attr_writer :tests
  def initialize
    @tests=Array.new
    @nPass = 0
    @nFail = 0
    @nTotalPass=0
    @nTotalFail=0
    @nTestCases=0
  end

  def summary
      puts "   Passed: #{@nPass}"
      puts "   Failed: #{@nFail}"
      @nTotalPass += @nPass
      @nTotalFail += @nFail
  end

  def final_summary
    summary if @nPass > 0 || @nFail > 0
    puts "\nFinal Summary"
    puts "  %5d Test Cases" % [@nTestCases]
    puts "  %5d Total Test" % [@nTotalPass + @nTotalFail]
    puts "  %5d Passed" % [@nTotalPass]
    puts "  %5d Failed" % [@nTotalFail]
  end

  def TestCase(msg)
    if @nPass > 0 || @nFail > 0
      summary
      @nPass=0
      @nFail=0
      puts ""
    end
    @nTestCases+=1
    puts msg
  end

  def Test(msg,result)
    rm=""
    if result
      rm="pass"
      @nPass+=1
    else
      rm="fail"
      @nFail+=1
    end
    puts "  #{msg} ... #{rm}"
  end

  def do_test(argv)
    if argv.size > 0
      argv.each do |i|
        if i.to_i < @tests.size
          @tests[i.to_i].call
        else
          puts "No test for #{i}"
        end
      end
    else
      @tests.each { |test_method|  test_method.call }
    end
    final_summary
  end

end
