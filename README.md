## Fraction
Provide class and methods for fraction operations.

## Background
Initially, I was looking for a method to convert a floating point number to a fraction.
After developing an algorithm for this, I expanded it to a class for adding, subtracting, etc
fractions.  I ported it to a few languages. My results are presented here.

## Goals
* Efficiently convert floating point numbers to fractions (convert 0.3 to 3/10, 0.33 to 33/100,
and 0.33333333333 to 1/3)
* Add, subtract, divide, and multiply fractions
* Compare fractions (==, !=, <, <=, >, >=)
* Support various languages (C, C++, C#, D, Java, Ruby)

## Algorithm

The routine to convert a floating point to a fraction uses an iterative method. It works as follows:

1. The initial approximation for the numerator is 1 and the denominator is 1 divided by the
fraction portion of the floating point value.
For example, when converting 0.06 to a fraction, the denominator = 1/0.06 = 16.66666667 (rounded to 17),
thus the initial approximation is 1/17.
2. The difference between the floating point value and the the current approximation is computed.
For the example, the difference is 1/17 - 0.06 = 0.058824 - 0.06 = -0.001176.
3. If the absolute value of the difference is less than the defined tolerance (0.000005 by default), then the iteration is terminated.
4. Use the difference computed in step 2 to improve approximation of fraction. This is done by converting the
difference into a fraction and adding (or subtracting) to the current approximation.  In the example,
a negative difference indicates a low approximation -- thus difference needs to be added to current approximation.
The difference fraction is the numerator = 1 and denominator = 1/0.001176 = 850 -- difference in fraction from is 1/850.
The new current approximation will be (1/17) + (1/850) = (850\*1 + 17\*1)/(850*17) = 867/14450.
5. Repeat steps 2 through 4 until solution found.
6. After solution found, the fraction is reduced.  For example, 867/14450 is exactly 0.06 and the iteration
process is terminated.  867/14450 is reduced to 3/50.

Some features of this method are:
* If the resulting fraction 1/anything, the first approximation will be exact. For example,
converting 0.25 to fraction, the first approximation will be 1/4. Thus further iterations are not needed.
* In majority (> 80%) of 1,000,000 test cases, convergence occurs in 2 iteration or less.
* For all test cases, the maximum number of iterations was 3.

## Updated Algorithm

The above algorithm has two shortcomings.
* Although algorithm converges quickly (2 or 3 iterations), finding the greatest common divisor for the numerator and denominator took longer
* For a smaller tolerance, the numerator and denominator can be very large (to large for 32 bit)

Due to these shortcomings, the algorithm was changed to the continued fraction method (https://en.wikipedia.org/wiki/Continued_fraction).
On average, the continued fraction method is about 100 ns fastered than original algorithm.

## Performance

For each language, a fraction performance program is provided.  It creates two frequency charts that
evaluate the floating point to fraction routine.  Tne first chart is for time (in hundreds of nanoseconds)
and the second is for the number of iterations.

Statistics can be gathered using a single denominator(N). Tests will be run from 1/N to (N-1)/N.
Statistics can also be gathered using various random denominators.  For each random denominator,
tests will be run from 1/N to (N-1)/N.  Use the "--help" option to get syntax.

If it is desired to compare the algorithms, in the C and C++ versions, defining FRACTION_ORIGINAL_ALGORITHM will compile using the original algorithm.
For example, in C++, use:

    make clean
    CPPFLAGS='-DFRACTION_ORIGINAL_ALGORITHM' make

## Notes
* The default tolerance is 0.000005. If a smaller tolerance is used, then the number of iterations
may increase.
