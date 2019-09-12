## Fraction
Provide class and methods for fraction operations.

## Background
I started by looking for a method for converting a floating point number to a fraction.
After a short lived internet search, I decided to create my own.
Afterwards, I wanted to compare mine to what others had done.
However, I did not find any that used the same method that I used. So, I decided to share my solution.

I further decided to create a fraction class which allows adding, subtracting, etc.

## Goals
* Efficiently convert floating point numbers to fractions (convert 0.3 to 3/10, 0.33 to 33/100,
and 0.33333333333 to 1/3)
* Add, subtract, divide, and multiply fractions
* Compare fractions (==, !=, <, <=, >, >=)
* Support variuus languages (C, C++, Ruby, C#, Java, etc)

## Algorithm
The routine to convert a floating point to a fraction uses an iterative method. It works as follows:

1. The initial approximation is the numerator = 1 and the denominator = 1/fract.
For example, when converting 0.06 to a fraction, the denominator = 1/0.06 = 16.66666667 (truncated to 16),
thus initial approximation is 1/16.
2. The difference between the floating point value and the the current approximation is computed.
3. If the difference is less than the defined tolerance, then the interation is terminated.
4. Use the difference computed in step 2 to improve approximation of fraction.
Repeat steps 2 to 4 until solution found.

Some features of this method are:
* If the result is a fraction 1/anything, the first approximation will be exact. For example,
converting 0.25 to fraction, the first approximation will be 1/4. Thus further iterations are not needed.
* In majority (> 80%) of 1,000,000 test cases, convergance occures in 2 iteration or less.
* For all test cases, the maximum number of interations was 3.

## Testing and Performance

For each language, a test_fraction (tests all methods provided) and fraction performance
(measures converting from floating point to fraction speed) program are provided.

## Notes
* The default tolerance is 0.00000005. If a smaller tolerance is used, then the number of interations
may increase.
