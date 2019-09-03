
TARGETS=test_fraction fraction_performance

LOADLIBES+=-lm

all: ${TARGETS}

test_fraction: test_fraction.o fraction.o

fraction_performance: fraction_performance.o fraction.o

test_fraction.o: test_fraction.c fraction.h

fraction_performance.o: fraction_performance.c fraction.h

clean:
	rm ${TARGETS} *.o
