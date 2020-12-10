
TARGETS=test_fraction fraction_performance
CFLAGS+=-fms-extensions
LOADLIBES+=-lm
CC=gcc
all: ${TARGETS}

test_fraction: test_fraction.c fraction.c fraction.h
	${CC} -o test_fraction ${CFLAGS} test_fraction.c fraction.c -lm

fraction_performance: fraction_performance.c fraction.c fraction.h
	${CC} -o fraction_performance ${CFLAGS} -DCALCULATE_LOOP_STATISTICS fraction_performance.c fraction.c -lm

clean:
	rm -f ${TARGETS} *.o
