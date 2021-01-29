/*
		Copyright (C) 2016-2021  by Terry N Bezue

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

#ifndef __TEST_HARNESS_INCLUDED__
#define __TEST_HARNESS_INCLUDED__

#include <iostream>
#include <iomanip>

typedef void(*test_function)(void);

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
int nFail = 0;
int nPass = 0;
int nTotalFail=0;
int nTotalPass=0;
int nTotalCases=0;

#define SUMMARY  std::cout << "Summary\n  Passed: " << nPass << "\n  Failed: " << nFail << std::endl << std::endl

#define TEST(S,T) std::cout << "  " << S << " ... " << ((T) ? ( nPass++,"pass") : ( nFail++,"fail")) << std::endl

#define TESTCASE(S) if(nFail || nPass) SUMMARY; puts(S); \
	nTotalFail+=nFail;nTotalPass+=nPass; \
	nFail=0;nPass=0;nTotalCases++

#define FINAL_SUMMARY  if(nFail || nPass) SUMMARY; \
	nTotalFail+=nFail;nTotalPass+=nPass; \
	std::cout << "Final Summary\n" << \
        std::setw(6) << nTotalCases << " Test Cases\n" << \
        std::setw(6) << (nTotalPass+nTotalFail) << " Total tests\n" << \
        std::setw(6) << nTotalPass << " Total Passed\n" << \
        std::setw(6) << nTotalFail << " Total Failed\n"

#define TEST_ALL(a) for(unsigned i=0;i<ntest;i++) a[i]()

void test_init();
#define TEST_MAIN(test_array) \
int main(int argc,char*argv[]) \
{ \
  test_init(); \
	int ntest=ARRAY_SIZE(test_array); \
	if(argc == 1) \
		TEST_ALL(test_array); \
	else { \
		for(int i=1;i<argc;i++) { \
			int itest=atoi(argv[i]); \
			if(itest >=0 && itest < ntest) \
				test_array[itest](); \
			else \
				printf("No test for %d\n",itest); \
		} \
	} \
	FINAL_SUMMARY; \
	return 0; \
}

#endif
