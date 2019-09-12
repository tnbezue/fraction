#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <stdlib.h>

typedef struct fraction_s fraction_t;
struct fraction_s
{
  int32_t numerator_;
  int32_t denominator_;
};
/*
 * Find greatest common divisor
 */
int64_t fraction_gcd(int64_t,int64_t);

/*
 * Set the numerator and denominator
 */
void fraction_set(fraction_t*,int64_t,int64_t);

/*
 * Set the numerator and denominator as mixed fraction, i.e. 3 1/2 -> set_mixed(f,3,1,2);
 */
#define fraction_set_mixed(f,w,n,d) fraction_set(f,(int64_t)w*(int64_t)d+(w<0 ? -1 : 1)*n,d)

/*
 * Set the fraction using the double value
*/
void fraction_set_double(fraction_t*,double);

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
 * Compares two fractions. Return -1 if first < second; 0 if equal; 1 if first > second
*/
int fraction_cmp(fraction_t,fraction_t);

/*
 * Absolute value of a fraction
*/
fraction_t fraction_abs(fraction_t);

/*
 * Compares if first fraction equal to second fraction
*/
#define fraction_eq_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) == 0)

/*
 * Compares if first fraction not equal to second fraction
*/
#define fraction_ne_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) != 0)

/*
 * Compares if first fraction less than to second fraction
*/
#define fraction_lt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <  0)

/*
 * Compares if first fraction less than or equal to second fraction
*/
#define fraction_le_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <= 0)

/*
 * Compares if first fraction greater than to second fraction
*/
#define fraction_gt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >  0)

/*
 * Compares if first fraction greater than or equal to second fraction
*/
#define fraction_ge_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >= 0)


/*
 * Tolerance used to determine if fraction is close enoough to consider equal
*/
extern double fraction_epsilon;

/*
 * Returns new fraction converted from double value provided
*/
fraction_t fraction_from_double(double);
#define double_to_fraction(d) fraction_from_double(d)

/*
 * Converts fraction to double precision value
*/
double fraction_to_double(fraction_t);

/*
 * Rounds fraction so that denominator is no larger than specified value
*/
void fraction_round(fraction_t*,int);

/*
 * Convert fraction to string.  Store in preallocated buffer of length n
*/
void fraction_to_s(fraction_t,char*,int n);

/*
 * Convert fraction to mixed string -- i.e., numerator=10, denominator=3, string = 3 1/3
*/
void fraction_to_mixed_s(fraction_t,char*,int n);

#endif
