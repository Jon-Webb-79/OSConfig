// ================================================================================
// ================================================================================
// - File:    test_suite.h
// - Purpose: Test suite declarations for prjct_name
//
// Source Metadata
// - Author:  Name
// - Date:    Month Day, Year
// - Version: 1.0
// - Copyright: Copyright Year, Company Inc.
// ================================================================================
// ================================================================================

#ifndef TEST_SUITE_H
#define TEST_SUITE_H

#include <stdarg.h>
#include <setjmp.h>
#include <stddef.h>
#include <cmocka.h>

#ifdef __cplusplus
extern "C" {
#endif

// ================================================================================
// ================================================================================
// TEST SUITE DECLARATIONS

extern const struct CMUnitTest test_example[];
extern const size_t test_example_count;

#ifdef __cplusplus
}
#endif

#endif /* TEST_SUITE_H */

// ================================================================================
// ================================================================================
// eof
