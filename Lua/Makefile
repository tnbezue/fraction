CC=gcc
CFLAGS+=-Wall -fPIC -DCALCULATE_LOOP_STATISTICS
LD=${CC} -shared

all: Fraction.so perf_utils.so

Fraction.so: Fraction.o
	${LD} -o $@ $<

Fraction.o: Fraction.c

perf_utils.so: perf_utils.o
	${LD} -o $@ $<

perf_utils.o: perf_utils.c

clean:
	rm *.o *.so
