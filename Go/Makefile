
TARGETS=test_fraction fraction_performance

TEST_FRACTION_OBJS=fraction/fraction.o test_harness/test_harness.o test_fraction.o
FRACTION_PERFORMANCE_OBJS=fraction_performance.o fraction/fraction.o
GO=gccgo

%.o: %.go
	$(GO) -Ifraction -Itest_harness  -c  $< -o $@

all: ${TARGETS}

test_fraction: ${TEST_FRACTION_OBJS}
	${GO} -o $@ ${TEST_FRACTION_OBJS}

fraction_performance: ${FRACTION_PERFORMANCE_OBJS}
	${GO} -o $@ ${FRACTION_PERFORMANCE_OBJS}

fraction/fraction.o: fraction/fraction.go

test_harness/test_harness.o: test_harness/test_harness.go

test_fraction.o: test_fraction.go fraction/fraction.o test_harness/test_harness.o

fraction_performance.o: fraction_performance.go fraction/fraction.o

clean:
	rm -f ${TEST_FRACTION_OBJS} ${FRACTION_PERFORMANCE_OBJS} ${TARGETS}
