#ifndef __FRACTION_INCLUDED__
#define __FRACTION_INCLUDED__

#include <stdlib.h>

typedef struct fraction_s fraction_t;
struct fraction_s
{
  int32_t numerator_;
  int32_t denominator_;
};

int64_t fraction_gcd(int64_t,int64_t);

fraction_t fraction_plus_fraction(fraction_t,fraction_t);
fraction_t fraction_minus_fraction(fraction_t,fraction_t);
fraction_t fraction_times_fraction(fraction_t,fraction_t);
fraction_t fraction_divided_by_fraction(fraction_t,fraction_t);

int fraction_cmp(fraction_t,fraction_t);

#define fraction_eq_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) == 0)
#define fraction_ne_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) != 0)
#define fraction_lt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <  0)
#define fraction_le_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) <= 0)
#define fraction_gt_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >  0)
#define fraction_ge_fraction(lhs,rhs) (fraction_cmp(lhs,rhs) >= 0)

extern double fraction_epsilon;
fraction_t fraction_from_double(double);

void fraction_to_s(fraction_t,char*,int n);
void fraction_as_mixed_fraction_to_s(fraction_t,char*,int n);
#endif
