/*
		Copyright (C) 2019-2020  by Terry N Bezue

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

#ifdef USE_32_BIT_FRACTION
typedef int32_t fraction_numerator_denominator_t;
#define PRIdND PRId32
#else
typedef int64_t fraction_numerator_denominator_t;
#define PRIdND PRId64
#endif

typedef struct fraction_s fraction_t;
struct fraction_s
{
  fraction_numerator_denominator_t numerator_;
  fraction_numerator_denominator_t denominator_;
};
/*
 * Find greatest common divisor
 */
fraction_numerator_denominator_t fraction_gcd(fraction_numerator_denominator_t,fraction_numerator_denominator_t);

/*
 * Set the numerator and denominator
 */
void fraction_set(fraction_t*,fraction_numerator_denominator_t,fraction_numerator_denominator_t);

/*
 * Set the numerator and denominator as mixed fraction, i.e. 3 1/2 -> set_mixed(f,3,1,2);
 */
void fraction_set_mixed(fraction_t*,fraction_numerator_denominator_t,fraction_numerator_denominator_t,fraction_numerator_denominator_t);

/*
 * Set the fraction using the double value
*/
void fraction_set_double(fraction_t*,double);

/*
 * Set the fraction using a string value
*/

void fraction_set_string(fraction_t*,const char*);

/*
 * A new fraction is created which is the sum of two fractions
*/
fraction_t fraction_plus_fraction(fraction_t,fraction_t);

/*
 * A new fraction is created which is the first fraction minus second fractions
*/
fraction_t fraction_minus_fraction(fraction_t,fraction_t);

/*
 * A new fraction is created which is first fraction times second fraction
*/
fraction_t fraction_times_fraction(fraction_t,fraction_t);

/*
 * A new fraction is created which first fraction divided by second fraction
*/
fraction_t fraction_divided_by_fraction(fraction_t,fraction_t);

/*
 * A fraction raised to power of fraction
 */
fraction_t fraction_power_fraction(fraction_t,fraction_t);

/*
 * A new fraction is created which is the sum a fraction and a double
*/
fraction_t fraction_plus_double(fraction_t,double);

/*
 * A new fraction is created which is the fraction minus double
*/
fraction_t fraction_minus_double(fraction_t,double);

/*
 * A new fraction is created which is fraction times double
*/
fraction_t fraction_times_double(fraction_t,double);

/*
 * A new fraction is created which fraction divided by double
*/
fraction_t fraction_divided_by_double(fraction_t,double);

/*
 * A fraction raised to power of fraction
 */
fraction_t fraction_power_double(fraction_t,double);

#define double_plus_fraction(d,f) (d + (double)f.numerator_/(double)f.denominator_)
#define double_minus_fraction(d,f) (d - (double)f.numerator_/(double)f.denominator_)
#define double_times_fraction(d,f) (d * (double)f.numerator_/(double)f.denominator_)
#define double_divided_by_fraction(d,f) (d * (double)f.denominator_/(double)f.numerator_)
#define double_power_fraction(d,f) (pow(d,(double)f.numerator_/(double)f.denominator_))

/*
 * Unary negative
*/
fraction_t fraction_neg(fraction_t f);

/*
 * Fraction reciprocal
*/
fraction_t fraction_reciprocal(fraction_t f);

/*
 * Compares two fractions. Return -1 if first < second; 0 if equal; 1 if first > second
*/
int fraction_cmp(fraction_t,fraction_t);

/*
 * Compares fraction to double. Return -1 if first < second; 0 if equal; 1 if first > second
*/
int fraction_cmp_double(fraction_t,double);

/*
 * Absolute value of a fraction
*/
fraction_t fraction_abs(fraction_t);

/*
 * Compares if fraction equal to fraction
*/
#define fraction_eq_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) == 0)

/*
 * Compares if fraction not equal to fraction
*/
#define fraction_ne_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) != 0)

/*
 * Compares if fraction less than to fraction
*/
#define fraction_lt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <  0)

/*
 * Compares if less than or equal to fraction
*/
#define fraction_le_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <= 0)

/*
 * Compares if fraction greater than to fraction
*/
#define fraction_gt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >  0)

/*
 * Compares if fraction greater than or equal to fraction
*/
#define fraction_ge_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >= 0)

/*
 * Compares if fraction equal to double
*/
#define fraction_eq_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) == 0)

/*
 * Compares if fraction not equal to double
*/
#define fraction_ne_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) != 0)

/*
 * Compares if fraction less than to double
*/
#define fraction_lt_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) <  0)

/*
 * Compares if fraction less than or double
*/
#define fraction_le_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) <= 0)

/*
 * Compares if fraction greater than to double
*/
#define fraction_gt_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) >  0)

/*
 * Compares if fraction greater than or equal to double
*/
#define fraction_ge_double(lhs,rhs) (fraction_cmp_double(lhs,rhs) >= 0)


/*
 * Compares if double equal to fraction
*/
#define double_eq_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) == 0)

/*
 * Compares if double not equal to fraction
*/
#define double_ne_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) != 0)

/*
 * Compares if double less than to fraction
*/
#define double_lt_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) > 0)

/*
 * Compares if double less than or equal to fraction
*/
#define double_le_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) >= 0)

/*
 * Compares if double greater than to fraction
*/
#define double_gt_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) <  0)

/*
 * Compares if double greater than or equal to fraction
*/
#define double_ge_fraction(lhs,rhs) (fraction_cmp_double(rhs,lhs) <= 0)

/*
 * Tolerance used to determine if fraction is close enoough to consider equal
*/
extern double fraction_epsilon;

/*
 * Converts fraction to double precision value
*/
double fraction_to_double(fraction_t);

/*
 * Rounds fraction so that denominator is no larger than specified value
*/
void fraction_round(fraction_t*,fraction_numerator_denominator_t);

/*
 * Convert fraction to string.  Store in preallocated buffer of length n
*/
const char* fraction_to_s(fraction_t);

/*
 * Convert fraction to mixed string -- i.e., numerator=10, denominator=3, string = 3 1/3
*/
const char* fraction_to_mixed_s(fraction_t);

#endif
