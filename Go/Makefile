
TARGETS=test_fraction fraction_performance

TEST_FRACTION_OBJS=fraction.o test_harness.o test_fraction.o
FRACTION_PERFORMANCE_OBJS=fraction_performance.o fraction.o
GO=gccgo

%.o: %.go
	$(GO) -c  $< -o $@

all: ${TARGETS}

test_fraction: ${TEST_FRACTION_OBJS}
	${GO} -o $@ ${TEST_FRACTION_OBJS}

fraction_performance: ${FRACTION_PERFORMANCE_OBJS}
	${GO} -o $@ ${FRACTION_PERFORMANCE_OBJS}

fraction.o: fraction.go

test_harness.o: test_harness.go fraction.o

test_fraction.o: test_fraction.go fraction.o test_harness.o

fraction_performance.o: fraction_performance.go fraction.o

clean:
	rm -f *.o ${TARGETS}
