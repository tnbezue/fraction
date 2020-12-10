

TARGETS = test_fraction fraction_performance

all: ${TARGETS}

test_fraction: test_fraction.d Fraction.d TestHarness.d
	gdc -g -o test_fraction test_fraction.d Fraction.d TestHarness.d

fraction_performance: fraction_performance.d Fraction.d
	gdc -o fraction_performance -fversion=CALCULATE_LOOP_STATISTICS fraction_performance.d Fraction.d

clean:
	rm -f ${TARGETS}
