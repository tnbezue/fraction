
TARGETS=test_fraction fraction_performance

CC=${CXX}

all: ${TARGETS}

test_fraction: test_fraction.o fraction.o

fraction_performance: fraction_performance.o fraction.o

fraction.o: fraction.cc fraction.hh

test_fraction.o: test_fraction.cc fraction.hh

fraction_performance.o: fraction_performance.cc fraction.hh

clean:
	rm -f ${TARGETS} *.o
