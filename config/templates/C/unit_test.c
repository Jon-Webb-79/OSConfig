// ================================================================================
// ================================================================================
// - File:    unit_test.c
// - Purpose: Describe the file purpose here
//
// Source Metadata
// - Author:  Name
// - Date:    Month Day, Year
// - Version: 1.0
// - Copyright: Copyright Year, Company Inc.
// ================================================================================
// ================================================================================
// Include modules here

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <stdint.h>
#include <cmocka.h>

#include "test.h"

// Begin code
int main(int argc, const char * argv[]) {
	const struct CMUnitTest test_one[] = {
		cmocka_unit_test(test_funct)
	};
	return cmocka_run_group_tests(test_one, NULL, NULL);
}
// ================================================================================
// ================================================================================
// eof

