#ifndef __TEST_HARNESS_INCLUDED__
#define __TEST_HARNESS_INCLUDED__

#include <iostream>
#include <cstdlib>
typedef void(*test_function)(void);

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
int nFail = 0;
int nPass = 0;
int nTotalFail=0;
int nTotalPass=0;

#define SUMMARY  std::cout << "  Passed: " << nPass << " Failed: " << nFail << std::endl << std::endl
#define TEST(S,T) std::cout << "  " << S << " ... " << ((T) ? ( nPass++,"pass") : ( nFail++,"fail")) << std::endl
#define TESTCASE(S) if(nFail || nPass) SUMMARY; puts(S); \
	nTotalFail+=nFail;nTotalPass+=nPass; \
	nFail=0;nPass=0
#define FINAL_SUMMARY  if(nFail || nPass) SUMMARY; \
	nTotalFail+=nFail;nTotalPass+=nPass; \
	std::cout << nTotalPass << " Passed\n" << nTotalFail << " Failed\n"
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
