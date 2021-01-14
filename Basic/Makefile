
TARGETS=TestFraction FractionPerformance

BC=fbc
BFLAGS+=-O 2
CC=gcc
CFLAGS=-O2
TEST_FRACTION_OBJECTS=TestFraction.o  Fraction.o TestHarness.o
FRACTION_PERFORMANCE_OBJECTS=FractionPerformance.o Fraction.o clock.o

all: ${TARGETS}

%.o:%.bas
	${BC} -c ${BFLAGS} $< -o $@

TestFraction: ${TEST_FRACTION_OBJECTS}
	${BC} -x $@ ${TEST_FRACTION_OBJECTS}

FractionPerformance: ${FRACTION_PERFORMANCE_OBJECTS}
	${BC} -x $@ ${FRACTION_PERFORMANCE_OBJECTS}

Fraction.o: Fraction.bas Fraction.bi

TestHarness.o: TestHarness.bas TestHarness.bi

TestFraction.o: TestFraction.bas TestHarness.bi
	${BC} -m TestFraction ${BFLAGS} -c TestFraction.bas

FractionPerformance.o: FractionPerformance.bas TestHarness.bi
	${BC} -m FractionPerformance  ${BFLAGS} -c FractionPerformance.bas

clock.o: clock.c

clean:
	rm -f ${TARGETS} *.o
