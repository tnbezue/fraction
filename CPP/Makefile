
TARGETS=test_fraction fraction_performance

CXX=g++

all: ${TARGETS}

test_fraction: test_fraction.cc fraction.cc fraction.hh test_harness.hh
	${CXX} -o test_fraction ${CXXFLAGS} test_fraction.cc fraction.cc

fraction_performance: fraction_performance.cc fraction.cc fraction.hh
	${CXX} -o fraction_performance ${CXXFLAGS} -DCALCULATE_LOOP_STATISTICS fraction_performance.cc fraction.cc

clean:
	rm -f ${TARGETS} *.o
