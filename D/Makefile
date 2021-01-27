

TARGETS = test_fraction fraction_performance

all: ${TARGETS}

test_fraction: test_fraction.d Fraction.d TestHarness.d
	gdc -g ${DFLAGS} -o test_fraction test_fraction.d Fraction.d TestHarness.d

fraction_performance: fraction_performance.d Fraction.d
	gdc -o fraction_performance ${DFLAGS} -fversion=CALCULATE_LOOP_STATISTICS fraction_performance.d Fraction.d

clean:
	rm -f ${TARGETS}
